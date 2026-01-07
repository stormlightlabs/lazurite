import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theme.dart';

void main() {
  group('AppColors', () {
    test('dark background is correct oxocarbon color', () {
      expect(AppColors.darkBackground, const Color(0xFF161616));
    });

    test('dark surface is correct oxocarbon color', () {
      expect(AppColors.darkSurface, const Color(0xFF262626));
    });

    test('light background is correct oxocarbon color', () {
      expect(AppColors.lightBackground, const Color(0xFFF2F4F8));
    });

    test('primary color is BlueSky blue', () {
      expect(AppColors.primary, const Color(0xFF0085FF));
    });

    test('secondary color is correct', () {
      expect(AppColors.secondary, const Color(0xFF78A9FF));
    });

    test('error color is correct', () {
      expect(AppColors.error, const Color(0xFFEE5396));
    });

    test('success color is correct', () {
      expect(AppColors.success, const Color(0xFF42BE65));
    });

    test('tertiary color is correct', () {
      expect(AppColors.tertiary, const Color(0xFF33B1FF));
    });

    test('purple color is correct', () {
      expect(AppColors.purple, const Color(0xFFBE95FF));
    });
  });
}
