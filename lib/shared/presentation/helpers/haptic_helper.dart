import 'dart:async';

import 'package:flutter/services.dart';

abstract final class HapticHelper {
  static void selectionClick() {
    unawaited(HapticFeedback.selectionClick());
  }

  static Future<void> lightImpact() => HapticFeedback.lightImpact();

  static void mediumImpact() {
    unawaited(HapticFeedback.mediumImpact());
  }

  static void heavyImpact() {
    unawaited(HapticFeedback.heavyImpact());
  }
}
