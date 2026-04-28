import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';

void main() {
  test('defines expected animation tokens', () {
    expect(Anim.fast, const Duration(milliseconds: 150));
    expect(Anim.normal, const Duration(milliseconds: 250));
    expect(Anim.slow, const Duration(milliseconds: 400));

    expect(Anim.feedItem, const Duration(milliseconds: 200));
    expect(Anim.screenTransition, const Duration(milliseconds: 300));
    expect(Anim.shimmerCycle, const Duration(milliseconds: 1200));

    expect(Anim.enter, Curves.easeOut);
    expect(Anim.exit, Curves.easeIn);
    expect(Anim.emphasis, Curves.easeOutBack);

    expect(Anim.staggerOffset, const Duration(milliseconds: 50));
    expect(Anim.maxStaggerItems, 10);
  });

  test('staggerFor clamps index to max range', () {
    expect(Anim.staggerFor(0), const Duration(milliseconds: 0));
    expect(Anim.staggerFor(1), const Duration(milliseconds: 50));
    expect(Anim.staggerFor(9), const Duration(milliseconds: 450));
    expect(Anim.staggerFor(50), const Duration(milliseconds: 450));
  });
}
