import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toneup_read/services/app_config_service.dart';
import 'package:toneup_read/services/update_controller.dart';
import 'package:toneup_read/providers/providers.dart';
import 'package:toneup_read/theme/go_tokens.dart';
import 'package:toneup_read/widgets/go_icon.dart';
import 'package:toneup_read/widgets/go_ui.dart';
import 'package:toneup_read/widgets/go_update_sheet.dart';

class MineScreen extends ConsumerStatefulWidget {
  const MineScreen({super.key});
  @override
  ConsumerState<MineScreen> createState() => _MineScreenState();
}

class _MineScreenState extends ConsumerState<MineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeUpdatePrompt();
    });
  }

  // —— 应用内更新 ——

  /// 入口行副标题：把状态机翻译成一句人话。
  String _updateSub(UpdateController c) => switch (c.phase) {
        UpdatePhase.checking => '正在检查…',
        UpdatePhase.available => '发现 v${c.info?.version ?? ''}',
        UpdatePhase.latest => '已是最新版本',
        UpdatePhase.failed => c.error ?? '检查失败',
        UpdatePhase.downloading => c.total > 0 ? '后台下载中 ${(c.progress * 100).toStringAsFixed(0)}%' : '后台下载中…',
        UpdatePhase.verifying => '正在校验…',
        UpdatePhase.ready => '已就绪，点击安装',
        UpdatePhase.installing => '等待安装确认',
        _ => c.installedLabel.isEmpty ? '当前版本' : '当前 ${c.installedLabel}',
      };

  DateTime? _lastManualCheck;

  Future<void> _checkUpdate() async {
    final now = DateTime.now();
    if (_lastManualCheck != null && now.difference(_lastManualCheck!) < const Duration(seconds: 30)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('刚检查过，稍等一会儿再试')));
      return;
    }
    _lastManualCheck = now;
    final c = ref.read(updateProvider);
    await c.checkNow();
    if (!mounted) return;
    switch (c.phase) {
      case UpdatePhase.latest:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已是最新版本')));
      case UpdatePhase.failed:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(c.error ?? '检查失败')));
      case UpdatePhase.available:
      case UpdatePhase.ready:
      case UpdatePhase.downloading:
        await showGoUpdateSheet(context, c);
      default:
        break;
    }
  }

  /// 启动时静默检查（每天最多一次）；同一版本只弹一次卡片，之后只留红点。
  Future<void> _maybeUpdatePrompt() async {
    final c = ref.read(updateProvider);
    await c.init();
    await c.autoCheck();
    if (!mounted) return;
    if (await c.shouldPrompt() && mounted) {
      await showGoUpdateSheet(context, c);
    }
  }

  Future<bool?> _confirm(String title, String content, {String confirmText = '确定'}) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(confirmText)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final update = ref.watch(updateProvider);
    final cfg = ref.watch(appConfigProvider);

    return GoPage(
      topPad: false,
      child: Column(
        children: [
          const GoAppBar(title: '我的', style: GoAppBarStyle.floating),
          Expanded(
            child: SingleChildScrollView(
              child: GoContent(
                child: GoStagger(
                  spacing: Go.sp8,
                  children: [
                    // —— 外观 ——
                    GoSection(
                      title: '外观',
                      children: [
                        GoCard(
                          padding: EdgeInsets.zero,
                          child: _navRow(
                            icon: 'settings',
                            title: '主题',
                            sub: _themeLabel(cfg.themePref),
                            onTap: _pickTheme,
                            divider: false,
                          ),
                        ),
                      ],
                    ),

                    // —— 朗读 ——
                    GoSection(
                      title: '朗读',
                      children: [
                        GoCard(
                          padding: EdgeInsets.zero,
                          child: _navRow(
                            icon: 'tts',
                            title: '朗读引擎',
                            sub: cfg.ttsEdge ? 'Edge 神经音色 · 需联网' : '系统语音 · 离线可用',
                            onTap: _pickTtsEngine,
                            divider: false,
                          ),
                        ),
                      ],
                    ),

                    // —— 数据管理 ——
                    GoSection(
                      title: '数据管理',
                      children: [
                        GoCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _navRow(
                                icon: 'trash',
                                title: '清除缓存',
                                sub: '清空已缓存的文章与词典，保留词汇与句子',
                                onTap: () async {
                                  final ok = await _confirm('清除缓存', '将清空已缓存的文章与词典，词汇与句子不受影响。');
                                  if (ok == true) await ref.read(dbProvider).clearCache();
                                  if (mounted) setState(() {});
                                },
                              ),
                              _navRow(
                                icon: 'alert',
                                title: '清空全部数据',
                                sub: '删除文章、词汇与句子',
                                danger: true,
                                onTap: () async {
                                  final ok = await _confirm(
                                    '清空全部数据',
                                    '将删除文章、词汇与句子，且不可恢复。',
                                    confirmText: '清空',
                                  );
                                  if (ok == true) await ref.read(dbProvider).clearAll();
                                  if (mounted) setState(() {});
                                },
                                divider: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // —— 关于 ——
                    GoSection(
                      title: '关于',
                      children: [
                        GoCard(
                          padding: EdgeInsets.zero,
                          child: _navRow(
                            icon: 'refresh',
                            title: '检查更新',
                            sub: _updateSub(update),
                            onTap: _checkUpdate,
                            spin: update.phase == UpdatePhase.checking,
                            dot: update.phase == UpdatePhase.available || update.phase == UpdatePhase.ready,
                            highlight: update.phase == UpdatePhase.available || update.phase == UpdatePhase.ready,
                            divider: false,
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: Go.sp8),
                      child: Column(
                        children: [
                          Text(
                            '一潼上岸·阅读 · By 潼潼',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: Go.fsCap, color: context.go.onSurfaceDisabled, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: Go.sp1),
                          Text(update.installedLabel, textAlign: TextAlign.center, style: TextStyle(fontSize: Go.fsCap, color: context.go.onSurfaceDisabled)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemePref pref) => switch (pref) {
        ThemePref.system => '跟随系统',
        ThemePref.light => '浅色',
        ThemePref.dark => '深色',
      };

  /// 选择主题：跟随系统 / 浅色 / 深色。
  Future<void> _pickTheme() async {
    final cfg = ref.read(appConfigProvider);
    final picked = await showModalBottomSheet<ThemePref>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: context.go.scrim,
      builder: (c) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(Go.sp6, Go.sp4, Go.sp6, Go.sp6),
          decoration: BoxDecoration(
            color: c.go.glassBgStrong,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Go.rXl)),
            border: Border(top: BorderSide(color: c.go.glassBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: Go.sp10,
                  height: 3,
                  decoration: BoxDecoration(color: c.go.outlineStrong, borderRadius: BorderRadius.circular(Go.rFull)),
                ),
              ),
              const SizedBox(height: Go.sp5),
              Text('主题', style: TextStyle(fontSize: Go.fsH2, fontWeight: FontWeight.w700, color: c.go.onSurface)),
              const SizedBox(height: Go.sp2),
              _engineOption(
                selected: cfg.themePref == ThemePref.system,
                title: '跟随系统',
                sub: '随系统的深色 / 浅色设置自动切换',
                onTap: () => Navigator.pop(c, ThemePref.system),
              ),
              _engineOption(
                selected: cfg.themePref == ThemePref.light,
                title: '浅色',
                sub: '白底深字，适合白天阅读',
                onTap: () => Navigator.pop(c, ThemePref.light),
              ),
              _engineOption(
                selected: cfg.themePref == ThemePref.dark,
                title: '深色',
                sub: '墨色底，适合夜间阅读',
                onTap: () => Navigator.pop(c, ThemePref.dark),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted || picked == cfg.themePref) return;
    ref.read(themeModeProvider.notifier).set(picked);
  }

  /// 选择朗读引擎：Edge（在线神经音色）/ 系统 TTS（离线）。
  Future<void> _pickTtsEngine() async {
    final cfg = ref.read(appConfigProvider);
    final picked = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: context.go.scrim,
      builder: (c) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(Go.sp6, Go.sp4, Go.sp6, Go.sp6),
          decoration: BoxDecoration(
            color: c.go.glassBgStrong,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Go.rXl)),
            border: Border(top: BorderSide(color: c.go.glassBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: Go.sp10,
                  height: 3,
                  decoration: BoxDecoration(color: c.go.outlineStrong, borderRadius: BorderRadius.circular(Go.rFull)),
                ),
              ),
              const SizedBox(height: Go.sp5),
              Text('朗读引擎', style: TextStyle(fontSize: Go.fsH2, fontWeight: FontWeight.w700, color: c.go.onSurface)),
              const SizedBox(height: Go.sp2),
              _engineOption(
                selected: cfg.ttsEdge,
                title: 'Edge 神经音色',
                sub: '在线合成，发音更自然；需要联网',
                onTap: () => Navigator.pop(c, true),
              ),
              _engineOption(
                selected: !cfg.ttsEdge,
                title: '系统语音',
                sub: '离线可用；部分机型音色偏机械',
                onTap: () => Navigator.pop(c, false),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    // 点的就是当前引擎：只关面板，不要打断正在念的声音。
    if (picked == cfg.ttsEdge) return;
    await ref.read(appConfigProvider).setTtsEdge(picked);
    // 换引擎时立刻停掉正在念的声音，避免两种音色叠着播。
    await ref.read(ttsProvider).stop();
  }

  Widget _engineOption({required bool selected, required String title, required String sub, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Go.rMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Go.sp3, horizontal: Go.sp2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Go.fsBodySm,
                      fontWeight: FontWeight.w600,
                      color: selected ? context.go.primary : context.go.onSurface,
                    ),
                  ),
                  const SizedBox(height: Go.sp1),
                  Text(sub, style: TextStyle(fontSize: Go.fsMeta, color: context.go.onSurface3)),
                ],
              ),
            ),
            if (selected) GoIcon('check', size: 18, color: context.go.primary),
          ],
        ),
      ),
    );
  }

  Widget _navRow({
    required String icon,
    required String title,
    String? sub,
    VoidCallback? onTap,
    bool danger = false,
    bool divider = true,
    bool highlight = false,
    bool dot = false,
    bool spin = false,
  }) {
    return Column(
      children: [
        if (divider) Divider(height: 0.5, thickness: 0.5, color: context.go.outline),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Go.sp5, vertical: Go.sp3),
            child: Row(
              children: [
                Container(
                  width: Go.r(64),
                  height: Go.r(64),
                  decoration: BoxDecoration(color: danger ? context.go.danger.withValues(alpha: 0.14) : context.go.primary95, borderRadius: BorderRadius.circular(Go.rSm)),
                  child: Center(child: GoIcon(icon, size: Go.r(48), color: danger ? context.go.danger : context.go.primary, spin: spin)),
                ),
                const SizedBox(width: Go.sp4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: Go.fsBodySm, fontWeight: FontWeight.w500, color: danger ? context.go.error : context.go.onSurface)),
                      if (sub != null) ...[
                        const SizedBox(height: 1),
                        Text(sub, style: TextStyle(fontSize: Go.fsMeta, color: highlight ? context.go.primary : context.go.onSurface3)),
                      ],
                    ],
                  ),
                ),
                if (dot)
                  Container(
                    width: Go.sp4,
                    height: Go.sp4,
                    margin: const EdgeInsets.only(right: Go.sp2),
                    decoration: BoxDecoration(color: context.go.primary, shape: BoxShape.circle),
                  ),
                Icon(Icons.chevron_right, size: 18, color: context.go.onSurfaceDisabled),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
