import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/animation_controller.dart' as lazurite_anim;
import 'package:lazurite/src/core/animations/page_transitions.dart';
import 'package:lazurite/src/features/settings/domain/animation_preferences.dart';

class MockAnimationController extends lazurite_anim.AnimationController {
  MockAnimationController({required this.initialState});
  final lazurite_anim.AnimationState initialState;

  @override
  lazurite_anim.AnimationState build() => initialState;

  @override
  bool shouldDisableAnimations({required bool platformReduceMotion}) =>
      initialState.preferences.shouldDisableAnimations(platformReduceMotion: platformReduceMotion);

  @override
  Duration getEffectiveDuration(Duration baseDuration, {required bool platformReduceMotion}) =>
      initialState.preferences.getEffectiveDuration(
        baseDuration,
        platformReduceMotion: platformReduceMotion,
      );
}

void main() {
  Widget buildTestApp(LazuriteTransitionType type, lazurite_anim.AnimationController controller) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
          routes: [
            GoRoute(
              path: 'detail',
              pageBuilder: (context, state) => LazuritePageTransitions.build(
                key: state.pageKey,
                child: const Scaffold(body: Text('Detail')),
                type: type,
                state: state,
                controller: controller,
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group('LazuritePageTransitions', () {
    testWidgets('uses correct transition for sharedAxisHorizontal', (tester) async {
      final controller = MockAnimationController(
        initialState: const lazurite_anim.AnimationState(
          preferences: AnimationPreferences(mode: AnimationMode.full),
          isLoading: false,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [lazurite_anim.animationControllerProvider.overrideWith(() => controller)],
          child: buildTestApp(LazuriteTransitionType.sharedAxisHorizontal, controller),
        ),
      );

      final context = tester.element(find.text('Home'));
      context.go('/detail');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(SharedAxisTransition), findsOneWidget);
    });

    testWidgets('uses correct transition for fadeThrough', (tester) async {
      final controller = MockAnimationController(
        initialState: const lazurite_anim.AnimationState(
          preferences: AnimationPreferences(mode: AnimationMode.full),
          isLoading: false,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [lazurite_anim.animationControllerProvider.overrideWith(() => controller)],
          child: buildTestApp(LazuriteTransitionType.fadeThrough, controller),
        ),
      );

      final context = tester.element(find.text('Home'));
      context.go('/detail');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(FadeThroughTransition), findsOneWidget);
    });

    testWidgets('disables animations when mode is minimal', (tester) async {
      final controller = MockAnimationController(
        initialState: const lazurite_anim.AnimationState(
          preferences: AnimationPreferences(mode: AnimationMode.minimal),
          isLoading: false,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [lazurite_anim.animationControllerProvider.overrideWith(() => controller)],
          child: buildTestApp(LazuriteTransitionType.sharedAxisHorizontal, controller),
        ),
      );

      final context = tester.element(find.text('Home'));
      context.go('/detail');
      await tester.pump();
      expect(find.text('Detail'), findsOneWidget);
      expect(find.byType(SharedAxisTransition), findsNothing);
    });
  });
}
