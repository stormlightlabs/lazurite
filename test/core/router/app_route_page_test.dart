import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/router/app_route_page.dart';

class _FakeGoRouterState extends Fake implements GoRouterState {
  @override
  ValueKey<String> get pageKey => const ValueKey<String>('page-key');
}

void main() {
  late GoRouterState state;

  setUp(() {
    state = _FakeGoRouterState();
  });

  test('useCupertinoRoutePage returns true only for iOS', () {
    expect(useCupertinoRoutePage(TargetPlatform.iOS), isTrue);
    expect(useCupertinoRoutePage(TargetPlatform.android), isFalse);
    expect(useCupertinoRoutePage(TargetPlatform.macOS), isFalse);
  });

  testWidgets('buildAppRoutePage uses CupertinoPage on iOS', (tester) async {
    late Page<void> page;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: Builder(
          builder: (context) {
            page = buildAppRoutePage<void>(context, state, const SizedBox());
            return const SizedBox();
          },
        ),
      ),
    );

    expect(page, isA<CupertinoPage<void>>());
  });

  testWidgets('buildAppRoutePage uses CustomTransitionPage on Android', (tester) async {
    late Page<void> page;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Builder(
          builder: (context) {
            page = buildAppRoutePage<void>(context, state, const SizedBox());
            return const SizedBox();
          },
        ),
      ),
    );

    expect(page, isA<CustomTransitionPage<void>>());
  });
}
