import 'dart:async';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
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
