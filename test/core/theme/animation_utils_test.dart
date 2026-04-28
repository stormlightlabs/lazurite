import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class _AnimatedProbe extends StatelessWidget {
  const _AnimatedProbe();

  @override
  Widget build(BuildContext context) {
    return const Text('probe').animateIfAllowed(context, effects: const [FadeEffect(duration: Anim.fast)]);
  }
}

void main() {
  Widget wrap(Widget child, {bool disableAnimations = false, SettingsCubit? settingsCubit}) {
    final base = MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(body: Center(child: child)),
      ),
    );

    if (settingsCubit == null) {
      return base;
    }

    return BlocProvider<SettingsCubit>.value(value: settingsCubit, child: base);
  }

  testWidgets('animateIfAllowed is disabled under widget tests', (tester) async {
    await tester.pumpWidget(wrap(const _AnimatedProbe()));
    await tester.pumpAndSettle();

    expect(find.byType(Animate), findsNothing);
    expect(find.text('probe'), findsOneWidget);
  });

  testWidgets('animateIfAllowed skips when platform reduced motion is enabled', (tester) async {
    await tester.pumpWidget(wrap(const _AnimatedProbe(), disableAnimations: true));
    await tester.pumpAndSettle();

    expect(find.byType(Animate), findsNothing);
    expect(find.text('probe'), findsOneWidget);
  });

  testWidgets('animateIfAllowed skips when user disables animations', (tester) async {
    final settingsCubit = MockSettingsCubit();
    const state = SettingsState(
      themePalette: AppThemePalette.oxocarbon,
      themeVariant: AppThemeVariant.dark,
      useSystemTheme: false,
      animationsEnabled: false,
    );

    when(() => settingsCubit.state).thenReturn(state);
    whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: state);

    await tester.pumpWidget(wrap(const _AnimatedProbe(), settingsCubit: settingsCubit));
    await tester.pumpAndSettle();

    expect(find.byType(Animate), findsNothing);
    expect(find.text('probe'), findsOneWidget);
  });
}
