import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题偏好：跟随系统 / 浅色 / 深色。
enum ThemePref { system, light, dark }

class AppConfigService extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _secureOk = !Platform.environment.containsKey('FLUTTER_TEST');
  ThemePref _themePref = ThemePref.dark;
  // 阅读设置（对齐 store.reader）
  double _fontSize = 18;
  double _lineHeight = 1.8;
  // 朗读引擎：true=Edge 在线神经音色，false=系统 TTS（离线）。
  bool _ttsEdge = true;

  // 云端配置：地址与密钥全部内置在 App 里，用户既看不到也改不了（「我的」页已无服务配置入口）。
  // 密钥不落源码，构建时用 --dart-define 注入，见 tool/release.ps1。
  String _articleApiBase = defaultArticleApiBase;
  String _gatewayBase = defaultGatewayBase;
  String _gatewayModel = defaultGatewayModel;
  String _articleApiKey = defaultArticleApiKey;
  String _gatewayKey = defaultGatewayKey;

  static const defaultArticleApiBase = 'https://read.tu.lztfirefly.top';
  static const defaultGatewayBase = 'https://gateway.lztfirefly.top';
  static const defaultGatewayModel = 'tencent/Hunyuan-MT-7B';

  /// 构建时注入：`--dart-define=ARTICLE_API_KEY=xxx` / `--dart-define=GATEWAY_KEY=xxx`。
  /// 未注入时为空串，App 取不到云端数据——这是源码裸构建的预期行为。
  static const defaultArticleApiKey = String.fromEnvironment('ARTICLE_API_KEY');
  static const defaultGatewayKey = String.fromEnvironment('GATEWAY_KEY');

  static const _kArticleApiBase = 'article_api_base';
  static const _kGatewayBase = 'gateway_base';
  static const _kGatewayModel = 'gateway_model';

  // 密钥：secure 侧带 _v1 后缀，明文侧（Keystore 不可用时的兜底）不带。
  static const _sArticleApiKey = 'article_api_key_v1';
  static const _kArticleApiKey = 'article_api_key';
  static const _sGatewayKey = 'gateway_key_v1';
  static const _kGatewayKey = 'gateway_key';

  static const _secure = FlutterSecureStorage(aOptions: AndroidOptions());

  ThemePref get themePref => _themePref;
  double get fontSize => _fontSize;
  double get lineHeight => _lineHeight;

  /// true=Edge 在线神经音色（默认），false=系统 TTS。
  bool get ttsEdge => _ttsEdge;

  /// 云端文章接口（列表 / 详情 / 缓存正文）。
  String get articleApiBase => _articleApiBase;
  String get gatewayBase => _gatewayBase;
  String get gatewayModel => _gatewayModel;
  String get articleApiKey => _articleApiKey;
  String get gatewayKey => _gatewayKey;

  /// 写入云端服务配置（接口地址 / 模型名 / 密钥）。传 null 表示不改该项。
  Future<void> setRemote({
    String? articleApiBase,
    String? gatewayBase,
    String? gatewayModel,
    String? articleApiKey,
    String? gatewayKey,
  }) async {
    if (articleApiBase != null && articleApiBase.trim().isNotEmpty) {
      _articleApiBase = articleApiBase.trim();
      await _prefs?.setString(_kArticleApiBase, _articleApiBase);
    }
    if (gatewayBase != null && gatewayBase.trim().isNotEmpty) {
      _gatewayBase = gatewayBase.trim();
      await _prefs?.setString(_kGatewayBase, _gatewayBase);
    }
    if (gatewayModel != null && gatewayModel.trim().isNotEmpty) {
      _gatewayModel = gatewayModel.trim();
      await _prefs?.setString(_kGatewayModel, _gatewayModel);
    }
    if (articleApiKey != null) {
      _articleApiKey = articleApiKey;
      await _writeSecret(_sArticleApiKey, _kArticleApiKey, articleApiKey);
    }
    if (gatewayKey != null) {
      _gatewayKey = gatewayKey;
      await _writeSecret(_sGatewayKey, _kGatewayKey, gatewayKey);
    }
    notifyListeners();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs!.getString('theme_mode');
    if (savedTheme != null) {
      _themePref = ThemePref.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => ThemePref.dark,
      );
    } else {
      // 旧版本只有 dark_mode bool：true/缺省 → 深色，false → 浅色。
      final legacyDark = _prefs!.getBool('dark_mode');
      _themePref = legacyDark == false ? ThemePref.light : ThemePref.dark;
    }
    _fontSize = _prefs!.getDouble('reader_fontSize') ?? 18;
    _lineHeight = _prefs!.getDouble('reader_lineHeight') ?? 1.8;
    _ttsEdge = _prefs!.getBool('tts_edge') ?? true;

    _articleApiBase = _prefs!.getString(_kArticleApiBase) ?? defaultArticleApiBase;
    _gatewayBase = _prefs!.getString(_kGatewayBase) ?? defaultGatewayBase;
    _gatewayModel = _prefs!.getString(_kGatewayModel) ?? defaultGatewayModel;
    // 内置密钥优先。只有源码裸构建（未注入）时才回落到本机存的旧值。
    _articleApiKey = defaultArticleApiKey.isNotEmpty
        ? defaultArticleApiKey
        : (await _readSecret(_sArticleApiKey, _kArticleApiKey) ?? '');
    _gatewayKey = defaultGatewayKey.isNotEmpty
        ? defaultGatewayKey
        : (await _readSecret(_sGatewayKey, _kGatewayKey) ?? '');
  }

  Future<String?> _readSecret(String secureKey, String legacyKey) async {
    if (_secureOk) {
      try {
        final v = await _secure.read(key: secureKey);
        if (v != null) return v;
      } catch (_) {
        _secureOk = false;
      }
    }
    return _prefs?.getString(legacyKey);
  }

  Future<void> _writeSecret(String secureKey, String legacyKey, String value) async {
    if (_secureOk) {
      try {
        await _secure.write(key: secureKey, value: value);
        await _prefs?.remove(legacyKey);
        return;
      } catch (_) {
        _secureOk = false;
      }
    }
    await _prefs?.setString(legacyKey, value);
  }

  Future<void> setThemePref(ThemePref v) async {
    if (_themePref == v) return;
    _themePref = v;
    await _prefs!.setString('theme_mode', v.name);
    notifyListeners();
  }

  /// 兼容旧调用；等价于 [setThemePref]。
  Future<void> setDarkMode(bool v) => setThemePref(v ? ThemePref.dark : ThemePref.light);

  /// 切换朗读引擎：true=Edge 在线神经音色，false=系统 TTS。
  Future<void> setTtsEdge(bool v) async {
    if (_ttsEdge == v) return;
    _ttsEdge = v;
    await _prefs!.setBool('tts_edge', v);
    notifyListeners();
  }

  Future<void> setReader({double? fontSize, double? lineHeight}) async {
    if (fontSize != null) {
      _fontSize = fontSize;
      await _prefs!.setDouble('reader_fontSize', fontSize);
    }
    if (lineHeight != null) {
      _lineHeight = lineHeight;
      await _prefs!.setDouble('reader_lineHeight', lineHeight);
    }
    notifyListeners();
  }
}
