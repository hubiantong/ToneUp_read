import 'package:flutter/material.dart';

/// 尺寸 / 字号 / 间距 / 圆角等与亮度无关的设计 token。
///
/// 颜色统一走 [GoPalette]（[goDark] / [goLight]），通过 `context.go` 取当前主题的调色板。
class Go {
  Go._();

  /// rpx → dp。
  static double r(num rpx) => rpx * 0.5;

  // ================= 字体 =================
  static const fontRead = 'Songti SC'; // 阅读正文衬线（回退到系统衬线）
  static const fontMono = 'monospace';

  // ================= 字号 (rpx→dp) =================
  static const fsDisplay = 20.0; // 40
  static const fsH1 = 16.0; // 32
  static const fsH2 = 14.0; // 28
  static const fsTitle = 15.0; // 30
  static const fsBody = 15.0; // 30
  static const fsBodySm = 13.5; // 27
  static const fsLabel = 12.0; // 24
  static const fsMeta = 11.5; // 23
  static const fsCap = 10.5; // 21

  // ================= 行高 =================
  static const lhTight = 1.25;
  static const lhSnug = 1.4;
  static const lhNormal = 1.6;
  static const lhRelaxed = 1.75;

  // ================= 间距 (rpx→dp) =================
  static const sp1 = 2.0;
  static const sp2 = 4.0;
  static const sp3 = 6.0;
  static const sp4 = 8.0;
  static const sp5 = 10.0;
  static const sp6 = 12.0;
  static const sp8 = 16.0;
  static const sp10 = 20.0;
  static const sp12 = 24.0;
  static const sp16 = 32.0;

  // ================= 圆角 (rpx→dp) =================
  static const rXs = 4.0;
  static const rSm = 6.0;
  static const rMd = 8.0;
  static const rLg = 12.0;
  static const rXl = 16.0;
  static const rFull = 999.0;

  // ================= 布局 =================
  static const contentMax = 380.0; // 760rpx
  static const appbarH = 52.0; // 104rpx
  static const navH = 55.0; // 110rpx

  static const glassRadius = 10.0;
}

/// 语义调色板：深色 / 浅色各一份，字段名与旧 `Go.*` 颜色 token 保持一致。
class GoPalette {
  const GoPalette({
    required this.primary,
    required this.primary95,
    required this.primary90,
    required this.primary80,
    required this.primary60,
    required this.primary40,
    required this.primary20,
    required this.onPrimary,
    required this.onPrimaryVariant,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.bg,
    required this.surface,
    required this.surface1,
    required this.surface2,
    required this.surfaceVariant,
    required this.surfaceRaised,
    required this.onSurface,
    required this.onSurface2,
    required this.onSurface3,
    required this.onSurfaceDisabled,
    required this.outline,
    required this.outlineStrong,
    required this.onBg,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.danger,
    required this.onDanger,
    required this.error,
    required this.info,
    required this.sel,
    required this.selStrong,
    required this.selWord,
    required this.glassBg,
    required this.glassBgStrong,
    required this.glassBorder,
    required this.scrim,
    required this.overlay,
    required this.elev1,
    required this.elev2,
    required this.shadow3,
    required this.navShadow,
    required this.glassShadow,
    required this.glowPrimary,
    required this.glowSecondary,
  });

  final Color primary;
  final Color primary95;
  final Color primary90;
  final Color primary80;
  final Color primary60;
  final Color primary40;
  final Color primary20;
  final Color onPrimary;
  final Color onPrimaryVariant;
  final Color onPrimaryContainer;

  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  final Color bg;
  final Color surface;
  final Color surface1;
  final Color surface2;
  final Color surfaceVariant;
  final Color surfaceRaised;
  final Color onSurface;
  final Color onSurface2;
  final Color onSurface3;
  final Color onSurfaceDisabled;
  final Color outline;
  final Color outlineStrong;
  final Color onBg;

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color danger;
  final Color onDanger;
  final Color error;
  final Color info;

  final Color sel;
  final Color selStrong;
  final Color selWord;

  final Color glassBg;
  final Color glassBgStrong;
  final Color glassBorder;
  final Color scrim;
  final Color overlay;

  final List<BoxShadow> elev1;
  final List<BoxShadow> elev2;
  final List<BoxShadow> shadow3;
  final List<BoxShadow> navShadow;
  final List<BoxShadow> glassShadow;
  final List<BoxShadow> glowPrimary;
  final List<BoxShadow> glowSecondary;
}

/// 深色（墨色中性底 · 低饱和紫）。
const goDark = GoPalette(
  primary: Color(0xFF8B5CF6),
  primary95: Color(0xFF2A2338),
  primary90: Color(0xFF322A44),
  primary80: Color(0xFF3E3552),
  primary60: Color(0xFF7565B8),
  primary40: Color(0xFF8B5CF6),
  primary20: Color(0xFF463A63),
  onPrimary: Color(0xFFFFFFFF),
  onPrimaryVariant: Color(0xFF241A38),
  onPrimaryContainer: Color(0xFFE2DBF2),
  secondary: Color(0xFF4FC6B8),
  onSecondary: Color(0xFF08241F),
  secondaryContainer: Color(0xFF1B3532),
  onSecondaryContainer: Color(0xFFB7E6DF),
  tertiary: Color(0xFFD48AAE),
  onTertiary: Color(0xFF2A111C),
  tertiaryContainer: Color(0xFF38222C),
  onTertiaryContainer: Color(0xFFEFD3E1),
  bg: Color(0xFF14131A),
  surface: Color(0xFF1B1A22),
  surface1: Color(0xFF201F28),
  surface2: Color(0xFF27262F),
  surfaceVariant: Color(0xFF302F39),
  surfaceRaised: Color(0xFF1C1B23),
  onSurface: Color(0xFFDCDAE3),
  onSurface2: Color(0xFFA8A5B2),
  onSurface3: Color(0xFF817E8C),
  onSurfaceDisabled: Color(0xFF5B5866),
  outline: Color(0xFF34323D),
  outlineStrong: Color(0xFF4B4956),
  onBg: Color(0xFFDCDAE3),
  success: Color(0xFF5FBF95),
  onSuccess: Color(0xFF06231A),
  warning: Color(0xFFD9AE5F),
  onWarning: Color(0xFF2A1F00),
  danger: Color(0xFFD98AA8),
  onDanger: Color(0xFF2A0B1B),
  error: Color(0xFFD98AA8),
  info: Color(0xFF4FC6B8),
  sel: Color(0x268B5CF6),
  selStrong: Color(0x408B5CF6),
  selWord: Color(0x33E072B0),
  glassBg: Color(0xB81A1922),
  glassBgStrong: Color(0xE61E1D26),
  glassBorder: Color(0x33FFFFFF),
  scrim: Color(0x99000000),
  overlay: Color(0xD11E1D26),
  elev1: [
    BoxShadow(color: Color(0x40000000), offset: Offset(0, 0.5), blurRadius: 1),
    BoxShadow(color: Color(0x55000000), offset: Offset(0, 1), blurRadius: 3),
  ],
  elev2: [
    BoxShadow(color: Color(0x55000000), offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(color: Color(0x66000000), offset: Offset(0, 4), blurRadius: 10),
  ],
  shadow3: [
    BoxShadow(color: Color(0x66000000), offset: Offset(0, 3), blurRadius: 8),
    BoxShadow(color: Color(0x73000000), offset: Offset(0, 8), blurRadius: 18),
  ],
  navShadow: [
    BoxShadow(color: Color(0x99000000), offset: Offset(0, -2), blurRadius: 12),
  ],
  glassShadow: [
    BoxShadow(color: Color(0x339080E0), offset: Offset(0, 6), blurRadius: 18),
    BoxShadow(color: Color(0x40000000), offset: Offset(0, 2), blurRadius: 6),
  ],
  glowPrimary: [
    BoxShadow(color: Color(0x268B5CF6), blurRadius: 14, offset: Offset(0, 3)),
  ],
  glowSecondary: [
    BoxShadow(color: Color(0x264FC6B8), blurRadius: 10, offset: Offset(0, 2)),
  ],
);

/// 浅色（白底 · 压暗品牌色保证对比度）。
const goLight = GoPalette(
  primary: Color(0xFF6D3FD1),
  primary95: Color(0xFFEFE9FC),
  primary90: Color(0xFFE7DFFA),
  primary80: Color(0xFFD8CBF6),
  primary60: Color(0xFF8B5CF6),
  primary40: Color(0xFFA78BFA),
  primary20: Color(0xFFC9B8F0),
  onPrimary: Color(0xFFFFFFFF),
  onPrimaryVariant: Color(0xFF2B1B4A),
  onPrimaryContainer: Color(0xFF2B1B4A),
  secondary: Color(0xFF0F857A),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD5F1ED),
  onSecondaryContainer: Color(0xFF083B36),
  tertiary: Color(0xFFA84574),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFF9E1EA),
  onTertiaryContainer: Color(0xFF4A1730),
  bg: Color(0xFFF6F5F9),
  surface: Color(0xFFFFFFFF),
  surface1: Color(0xFFFBFAFD),
  surface2: Color(0xFFF0EEF5),
  surfaceVariant: Color(0xFFDDD9E7),
  surfaceRaised: Color(0xFFFFFFFF),
  onSurface: Color(0xFF1C1A23),
  onSurface2: Color(0xFF4E4A59),
  onSurface3: Color(0xFF74707F),
  onSurfaceDisabled: Color(0xFFA7A3B2),
  outline: Color(0xFFE4E1EB),
  outlineStrong: Color(0xFFC9C5D5),
  onBg: Color(0xFF1C1A23),
  success: Color(0xFF1E7F57),
  onSuccess: Color(0xFFFFFFFF),
  warning: Color(0xFF8A6100),
  onWarning: Color(0xFFFFFFFF),
  danger: Color(0xFFB93B63),
  onDanger: Color(0xFFFFFFFF),
  error: Color(0xFFB93B63),
  info: Color(0xFF0F857A),
  sel: Color(0x1F6D3FD1),
  selStrong: Color(0x336D3FD1),
  selWord: Color(0x26B93B63),
  glassBg: Color(0xCCFFFFFF),
  glassBgStrong: Color(0xF2FFFFFF),
  glassBorder: Color(0x14000000),
  scrim: Color(0x66000000),
  overlay: Color(0xF2FFFFFF),
  elev1: [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 0.5), blurRadius: 1),
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 1), blurRadius: 3),
  ],
  elev2: [
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(color: Color(0x29000000), offset: Offset(0, 4), blurRadius: 10),
  ],
  shadow3: [
    BoxShadow(color: Color(0x29000000), offset: Offset(0, 3), blurRadius: 8),
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 8), blurRadius: 18),
  ],
  navShadow: [
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, -2), blurRadius: 12),
  ],
  glassShadow: [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 6), blurRadius: 18),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 6),
  ],
  glowPrimary: [
    BoxShadow(color: Color(0x266D3FD1), blurRadius: 14, offset: Offset(0, 3)),
  ],
  glowSecondary: [
    BoxShadow(color: Color(0x260F857A), blurRadius: 10, offset: Offset(0, 2)),
  ],
);

extension GoPaletteX on BuildContext {
  /// 当前主题对应的语义调色板；深浅切换时自动生效。
  GoPalette get go =>
      Theme.of(this).brightness == Brightness.dark ? goDark : goLight;
}
