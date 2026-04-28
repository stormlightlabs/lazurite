import 'package:flutter/animation.dart';

abstract final class Anim {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Duration feedItem = Duration(milliseconds: 200);
  static const Duration screenTransition = Duration(milliseconds: 300);
  static const Duration shimmerCycle = Duration(milliseconds: 1200);
  static const Duration actionBounceIn = Duration(milliseconds: 120);
  static const Duration actionBounceOut = Duration(milliseconds: 100);
  static const Duration refreshComplete = Duration(milliseconds: 200);

  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve emphasis = Curves.easeOutBack;

  static const Duration staggerOffset = Duration(milliseconds: 50);
  static const int maxStaggerItems = 10;

  static Duration staggerFor(int index) {
    final clampedIndex = index.clamp(0, maxStaggerItems - 1);
    return Duration(milliseconds: staggerOffset.inMilliseconds * clampedIndex);
  }
}
