import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// 截图驱动：把 integration_test 的截图写到 docs/screenshots/。
///
/// 运行：
///   flutter drive --driver=test_driver/screenshot_driver.dart \
///     --target=integration_test/screenshot_test.dart
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('docs/screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      return true;
    },
  );
}
