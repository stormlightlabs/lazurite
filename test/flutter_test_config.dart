import 'dart:async';

import 'package:lazurite/core/theme/typography.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTypography.disableFontsForTests();

  await runZoned(
    () async {
      await testMain();
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        if (_isKnownSvgWarning(line)) {
          return;
        }
        parent.print(zone, line);
      },
    ),
  );
}

bool _isKnownSvgWarning(String line) {
  return line.contains('unhandled element') && (line.contains('<filter />') || line.contains('<sodipodi:namedview />'));
}
