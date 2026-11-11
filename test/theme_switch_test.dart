import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:toneup_read/app.dart';
import 'package:toneup_read/providers/providers.dart';
import 'package:toneup_read/services/app_config_service.dart';
import 'package:toneup_read/widgets/bottom_nav.dart';

import 'fake_db.dart';

/// 主题偏好：旧 dark_mode 迁移 + 三档切换。
///
/// 页面有常驻动画（辉光 / 地球 / 依次浮入），一律固定时长 pump，不用 pumpAndSettle。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('旧数据 dark_mode=false 迁移为浅色，缺省为深色', () async {
    SharedPreferences.setMockInitialValues({'dark_mode': false});
    final light = AppConfigService();
    await light.init();
    expect(light.themePref, ThemePref.light);

    SharedPreferences.setMockInitialValues({});
    final dark = AppConfigService();
    await dark.init();
    expect(dark.themePref, ThemePref.dark);
  });

  test('theme_mode 优先于旧的 dark_mode', () async {
    SharedPreferences.setMockInitialValues({
      'dark_mode': false,
      'theme_mode': 'system',
    });
    final cfg = AppConfigService();
    await cfg.init();
    expect(cfg.themePref, ThemePref.system);
  });

  testWidgets('我的 → 主题 → 浅色 / 跟随系统', (tester) async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
    });
    final cfg = AppConfigService();
    await cfg.init();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(FakeDb()),
        appConfigProvider.overrideWith((ref) => cfg),
      ],
      child: const MyApp(),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);

    // 切到「我的」Tab（底部导航里唯一一个「我的」）。
    await tester.tap(find.descendant(of: find.byType(BottomNav), matching: find.text('我的')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // GoStagger 动画结束

    expect(find.text('主题'), findsOneWidget);
    await tester.tap(find.text('主题'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('浅色'), findsOneWidget);
    await tester.tap(find.text('浅色'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(cfg.themePref, ThemePref.light);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.light);

    // 再切换为跟随系统。
    await tester.tap(find.text('主题'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('跟随系统'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(cfg.themePref, ThemePref.system);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.system);
  });
}
