import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:edge_tts/edge_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toneup_read/services/app_config_service.dart';

/// 朗读：优先 Edge 神经音色（在线合成 → 本地缓存 mp3 → MediaPlayer 播放），
/// 无网 / 接口失败 / 连续出错时回退系统 TTS。
///
/// 选型约束：App 体积不能变大。Edge 合成走纯 Dart 的 edge_tts（只依赖
/// crypto + flutter），播放复用 Android 原生 MediaPlayer（见 MainActivity），
/// 不引入任何音频插件，也不打包语音模型。
class TtsService {
  TtsService(this._config);

  final AppConfigService _config;
  final FlutterTts _tts = FlutterTts();

  /// 播放状态（true=正在朗读）。UI 应监听它，而不是自己猜。
  final ValueNotifier<bool> playing = ValueNotifier<bool>(false);

  static const _timeout = Duration(seconds: 4);
  static const _googleEngine = 'com.google.android.tts';

  /// 原生播放器通道（MainActivity.kt）。
  static const _player = MethodChannel('toneup/tts_player');

  static const _edgeVoice = 'en-US-AriaNeural';
  static const _edgeTimeout = Duration(seconds: 15);

  /// 缓存：mp3 很小，但也不能无限长，超出上限按最旧删除。
  static const _maxCacheFiles = 80;
  static const _maxCacheBytes = 12 * 1024 * 1024;

  /// 连续失败 3 次后把 Edge 停用 10 分钟，避免每次朗读都白等一次超时。
  int _edgeFails = 0;
  DateTime? _edgeOffUntil;

  /// 每次朗读/停止都 +1，用于丢弃过期的合成结果（防串音）。
  int _seq = 0;

  Directory? _cacheDir;

  /// 引擎/音色初始化只做一次；本地回退路径必须等它完成。
  late final Future<void> _ready;

  TtsService() {
    _player.setMethodCallHandler((call) async {
      if (call.method == 'completed') playing.value = false;
    });
    _tts.awaitSpeakCompletion(false);
    _tts.setCompletionHandler(() => playing.value = false);
    _tts.setCancelHandler(() => playing.value = false);
    _tts.setErrorHandler((_) => playing.value = false);
    // 提前在后台完成引擎/音色初始化，避免回退时念在低质量引擎上。
    _ready = _init();
  }

  Future<void> _init() async {
    // 1) 优先切换到 Google TTS：系统默认引擎经常是"电音"的根源。
    var switched = false;
    try {
      final engines = await _tts.getEngines;
      if (_hasEngine(engines, _googleEngine)) {
        await _tts.setEngine(_googleEngine);
        switched = true;
      }
    } catch (_) {}
    // 切引擎会异步重建 TextToSpeech 实例；等它真正可用再设置语言/音色。
    if (switched) await _waitEngineReady();

    // 2) 锁定英语（en-US），避免回落到中文引擎念英文；没有美音数据时退英音。
    try {
      final ok = await _tts.setLanguage('en-US');
      if (ok == 0 || ok == false) await _tts.setLanguage('en-GB');
    } catch (_) {}

    // 3) 选当前引擎里质量最高的英语音色。
    try {
      final voices = await _tts.getVoices;
      final voice = _bestEnglishVoice(voices);
      if (voice != null) {
        await _tts.setVoice({'name': voice.$1, 'locale': voice.$2});
      }
    } catch (_) {}

    try {
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(0.5);
    } catch (_) {}
  }

  /// 轮询新引擎是否已初始化并能说英语（最多约 1 秒）。
  Future<void> _waitEngineReady() async {
    for (var i = 0; i < 8; i++) {
      try {
        final us = await _tts.isLanguageAvailable('en-US');
        if (us == true || us == 1) return;
        final gb = await _tts.isLanguageAvailable('en-GB');
        if (gb == true || gb == 1) return;
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }

  static bool _hasEngine(dynamic raw, String name) {
    if (raw is! List) return false;
    for (final e in raw) {
      final s = e is Map ? '${e['name'] ?? ''}' : '$e';
      if (s == name) return true;
    }
    return false;
  }

  /// 从 [getVoices] 的返回值里挑英语音色：优先 en-US，其次 en-GB，再其他 en；
  /// 同语言下按 quality 取高（Google TTS 的 en-us-x-* 音色明显更自然）。
  /// 返回 (name, locale)，没有可用英语音色时返回 null。
  static (String, String)? _bestEnglishVoice(dynamic raw) {
    if (raw is! List) return null;
    Map<String, dynamic>? best;
    var bestScore = -1;
    for (final e in raw) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      final name = '${m['name'] ?? ''}';
      if (name.isEmpty) continue;
      final locale = '${m['locale'] ?? ''}'.toLowerCase().replaceAll('_', '-');
      if (!locale.startsWith('en')) continue;
      var score = 0;
      if (locale == 'en-us') {
        score += 60;
      } else if (locale.startsWith('en-us')) {
        score += 50;
      } else if (locale.startsWith('en-gb')) {
        score += 40;
      } else {
        score += 20;
      }
      // quality 在 Android 上是数值；解析失败按 0 处理。
      final q = m['quality'];
      score += (q is num ? q.toInt() : (int.tryParse('${q ?? ''}') ?? 0)) ~/ 10;
      // 网络音色更自然，但离线不可用，只给很小的权重。
      if ('${m['network_required']}'.toLowerCase() == 'true') score += 5;
      if (score > bestScore) {
        bestScore = score;
        best = m;
      }
    }
    if (best == null) return null;
    return ('${best['name']}', '${best['locale'] ?? 'en-US'}');
  }

  bool get isPlaying => playing.value;

  bool get _edgeEnabled {
    final off = _edgeOffUntil;
    return off == null || DateTime.now().isAfter(off);
  }

  void _edgeFailed() {
    _edgeFails++;
    if (_edgeFails >= 3) {
      _edgeOffUntil = DateTime.now().add(const Duration(minutes: 10));
      _edgeFails = 0;
    }
  }

  /// flutter_tts 的 0.5 约等于正常语速，映射到 Edge 的百分比；
  /// 略微放慢，更适合精读/跟读场景。
  static String _edgeRate(double rate) {
    final pct = ((rate - 0.5) * 50).round().clamp(-40, 60);
    return pct >= 0 ? '+$pct%' : '$pct%';
  }

  Future<void> stop() async {
    _seq++;
    playing.value = false;
    try {
      await _player.invokeMethod<void>('stop');
    } catch (_) {}
    try {
      await _tts.stop().timeout(_timeout);
    } catch (_) {}
  }

  /// 立即返回（不等待朗读结束）；完成/取消/出错由回调维护 [playing]。
  Future<void> speak(String text, {double rate = 0.5}) async {
    final input = text.trim();
    if (input.isEmpty) throw Exception('没有可朗读的文本');
    await stop();
    final seq = ++_seq;
    playing.value = true;

    if (_config.ttsEdge && _edgeEnabled) {
      final edgeRate = _edgeRate(rate);
      try {
        final file = await _edgeFile(input, edgeRate).timeout(_edgeTimeout);
        // 合成期间用户可能已经点了别的词，丢弃过期结果。
        if (seq != _seq) return;
        await _player.invokeMethod<void>('play', file.path);
        _edgeFails = 0;
        _edgeOffUntil = null;
        return;
      } catch (_) {
        _edgeFailed();
        if (seq != _seq) return;
        playing.value = true;
      }
    }

    await _speakLocal(input, rate: rate, seq: seq);
  }

  /// 本地系统 TTS 回退。任何一步失败都不抛异常，最多不出声。
  Future<void> _speakLocal(String input, {required double rate, required int seq}) async {
    try {
      await _ready.timeout(_timeout);
    } catch (_) {}
    if (seq != _seq) return;
    try {
      await _tts.stop().timeout(_timeout);
    } catch (_) {}
    try {
      await _tts.setSpeechRate(rate).timeout(_timeout);
    } catch (_) {}
    if (seq != _seq) return;
    playing.value = true;
    unawaited(_tts.speak(input).catchError((_) {
      playing.value = false;
      return 0;
    }));
  }

  /// 取（必要时合成）这段文本的 mp3，命中缓存直接返回。
  Future<File> _edgeFile(String text, String rate) async {
    final dir = await _cacheDirectory();
    final key = sha256.convert(utf8.encode('$_edgeVoice|$rate|$text')).toString();
    final file = File('${dir.path}${Platform.pathSeparator}$key.mp3');
    if (await file.exists() && await file.length() > 0) return file;

    // 先写 .part 再 rename：合成中断不会留下半个文件被当成缓存。
    final tmp = File('${file.path}.part');
    try {
      await Communicate(text: text, voice: _edgeVoice, rate: rate).save(tmp.path);
      if (await tmp.length() == 0) throw Exception('empty audio');
      await tmp.rename(file.path);
    } catch (_) {
      try {
        await tmp.delete();
      } catch (_) {}
      rethrow;
    }
    unawaited(_prune(dir, file));
    return file;
  }

  Future<Directory> _cacheDirectory() async {
    final cached = _cacheDir;
    if (cached != null && await cached.exists()) return cached;
    final temp = await getTemporaryDirectory();
    final dir = Directory('${temp.path}${Platform.pathSeparator}tts_edge');
    if (!await dir.exists()) await dir.create(recursive: true);
    _cacheDir = dir;
    return dir;
  }

  /// 控制缓存体积：文件数或总大小超限时，删最旧的（本次刚合成的除外）。
  Future<void> _prune(Directory dir, File keep) async {
    try {
      final entries = <MapEntry<File, FileStat>>[];
      await for (final e in dir.list()) {
        if (e is! File || e.path == keep.path) continue;
        entries.add(MapEntry(e, await e.stat()));
      }
      entries.sort((a, b) => a.value.modified.compareTo(b.value.modified));
      var count = entries.length + 1;
      var total = await keep.length();
      for (final e in entries) {
        if (count <= _maxCacheFiles && total <= _maxCacheBytes) break;
        count--;
        total -= e.value.size;
        try {
          await e.key.delete();
        } catch (_) {}
      }
    } catch (_) {}
  }
}
