import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';

bool animationsEnabledByUser(BuildContext context) {
  try {
    return context.select<SettingsCubit, bool>((cubit) => cubit.state.animationsEnabled);
  } catch (_) {
    return true;
  }
}

bool animationsAllowed(BuildContext context) {
  final platformReducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  final bindingName = WidgetsBinding.instance.runtimeType.toString();
  final runningInWidgetTest = bindingName.contains('TestWidgetsFlutterBinding');
  return !runningInWidgetTest && !platformReducedMotion && animationsEnabledByUser(context);
}

extension AnimateAccessibility on Widget {
  Widget animateIfAllowed(BuildContext context, {required List<Effect<dynamic>> effects, Duration? delay}) {
    if (animationsAllowed(context)) {
      return animate(effects: effects, delay: delay);
    }

    return this;
  }
}
