import 'package:flutter/material.dart';


class Go {
  Go._();

  /// rpx → dp。
  static double r(num rpx) => rpx * 0.5;

  // ================= 主色系（低饱和紫 · 深色中性底） =================
  static const primary = Color(0xFF8B5CF6); // 品牌紫（仅小面积点缀）
  static const primary95 = Color(0xFF2A2338); // 选中态深紫底（压暗降饱和）
  static const primary90 = Color(0xFF322A44);
  static const primary80 = Color(0xFF3E3552);
  static const primary60 = Color(0xFF7565B8);
  static const primary40 = Color(0xFF8B5CF6);
  static const primary20 = Color(0xFF463A63);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryVariant = Color(0xFF241A38);
  static const onPrimaryContainer = Color(0xFFE2DBF2);

  static const secondary = Color(0xFF4FC6B8); // 柔和青（渐变副色）
  static const onSecondary = Color(0xFF08241F);
  static const secondaryContainer = Color(0xFF1B3532);
  static const onSecondaryContainer = Color(0xFFB7E6DF);

  static const tertiary = Color(0xFFD48AAE); // 柔和粉
  static const onTertiary = Color(0xFF2A111C);
  static const tertiaryContainer = Color(0xFF38222C);
  static const onTertiaryContainer = Color(0xFFEFD3E1);

  // ================= 中性 / 表面（墨色中性，只留极弱紫调） =================
  static const bg = Color(0xFF14131A); // 墨黑底：低饱和，久读不刺眼
  static const surface = Color(0xFF1B1A22); // 卡片 / 面板
  static const surface1 = Color(0xFF201F28);
  static const surface2 = Color(0xFF27262F);
  static const surfaceVariant = Color(0xFF302F39); // 进度轨道（暗但可见）
  static const surfaceRaised = Color(0xFF1C1B23);
  static const onSurface = Color(0xFFDCDAE3); // 正文：降低对比，减少炫光
  static const onSurface2 = Color(0xFFA8A5B2);
  static const onSurface3 = Color(0xFF817E8C);
  static const onSurfaceDisabled = Color(0xFF5B5866);
  static const outline = Color(0xFF34323D);
  static const outlineStrong = Color(0xFF4B4956);
  static const onBg = Color(0xFFDCDAE3);

  // ================= 语义色 =================
  static const success = Color(0xFF5FBF95);
  static const onSuccess = Color(0xFF06231A);
  static const warning = Color(0xFFD9AE5F);
  static const onWarning = Color(0xFF2A1F00);
  static const danger = Color(0xFFD98AA8);
  static const onDanger = Color(0xFF2A0A1B);
  static const error = Color(0xFFD98AA8);
  static const info = Color(0xFF4FC6B8);

  // ================= 选中态 / 强调 =================
  static const sel = Color(0x268B5CF6); // rgba(139,92,246,.15)
  static const selStrong = Color(0x408B5CF6); // .25
  static const selWord = Color(0x33E072B0); // .20

  static const glassBg = Color(0xB81A1922);
  static const glassBgStrong = Color(0xE61E1D26);
  static const glassBorder = Color(0x33FFFFFF);
  static const glassRadius = 10.0;

  static const List<BoxShadow> elev1 = [
    BoxShadow(color: Color(0x40000000), offset: Offset(0, 0.5), blurRadius: 1),
    BoxShadow(color: Color(0x55000000), offset: Offset(0, 1), blurRadius: 3),
  ];
  static const List<BoxShadow> elev2 = [
    BoxShadow(color: Color(0x55000000), offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(color: Color(0x66000000), offset: Offset(0, 4), blurRadius: 10),
  ];
  static const List<BoxShadow> shadow3 = [
    BoxShadow(color: Color(0x66000000), offset: Offset(0, 3), blurRadius: 8),
    BoxShadow(color: Color(0x73000000), offset: Offset(0, 8), blurRadius: 18),
  ];
  static const List<BoxShadow> navShadow = [
    BoxShadow(color: Color(0x99000000), offset: Offset(0, -2), blurRadius: 12),
  ];
  static const List<BoxShadow> glassShadow = [
    BoxShadow(color: Color(0x339080E0), offset: Offset(0, 6), blurRadius: 18),
    BoxShadow(color: Color(0x40000000), offset: Offset(0, 2), blurRadius: 6),
  ];
  static const List<BoxShadow> glowPrimary = [
    BoxShadow(color: Color(0x268B5CF6), blurRadius: 14, offset: Offset(0, 3)),
  ];
  static const List<BoxShadow> glowSecondary = [
    BoxShadow(color: Color(0x264FC6B8), blurRadius: 10, offset: Offset(0, 2)),
  ];

  static const scrim = Color(0x99000000);
  static const overlay = Color(0xD11E1D26);

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
}
