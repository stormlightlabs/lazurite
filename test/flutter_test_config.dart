import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

// FIXME: Bundle Lora, Public Sans, and JetBrains Mono fonts as assets
// so we can test full theme creation. Currently AppTheme.light/dark tests
// fail because google_fonts tries to fetch fonts over HTTP.
// See: https://pub.dev/packages/google_fonts#bundling-fonts-when-releasing

/// Global test configuration that runs before all tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
