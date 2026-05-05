import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/presentation/helpers/share_helper.dart';

void main() {
  testWidgets('sharePositionOriginForContext returns render box bounds when available', (tester) async {
    final key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(key: key, width: 140, height: 72, child: const SizedBox.shrink()),
        ),
      ),
    );

    final rect = ShareHelper.sharePositionOriginForContext(key.currentContext!);

    expect(rect, isNotNull);
    expect(rect.width, 140);
    expect(rect.height, 72);
  });

  testWidgets('sharePositionOriginForContext falls back when render box has empty size', (tester) async {
    Rect? rect;

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox.shrink(
          child: Builder(
            builder: (context) {
              rect = ShareHelper.sharePositionOriginForContext(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(rect, isNotNull);
    expect(rect!.width, greaterThan(0));
    expect(rect!.height, greaterThan(0));
  });
}
