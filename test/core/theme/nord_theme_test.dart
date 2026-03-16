import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/nord_theme.dart';

void main() {
  group('NordTheme', () {
    group('Color values', () {
      test('nord0 is #2e3440', () {
        expect(NordTheme.nord0, const Color(0xFF2e3440));
      });

      test('nord1 is #3b4252', () {
        expect(NordTheme.nord1, const Color(0xFF3b4252));
      });

      test('nord2 is #434c5e', () {
        expect(NordTheme.nord2, const Color(0xFF434c5e));
      });

      test('nord3 is #4c566a', () {
        expect(NordTheme.nord3, const Color(0xFF4c566a));
      });

      test('nord4 is #d8dee9', () {
        expect(NordTheme.nord4, const Color(0xFFd8dee9));
      });

      test('nord5 is #e5e9f0', () {
        expect(NordTheme.nord5, const Color(0xFFe5e9f0));
      });

      test('nord6 is #eceff4', () {
        expect(NordTheme.nord6, const Color(0xFFeceff4));
      });

      test('nord7 is #8fbcbb', () {
        expect(NordTheme.nord7, const Color(0xFF8fbcbb));
      });

      test('nord8 is #88c0d0', () {
        expect(NordTheme.nord8, const Color(0xFF88c0d0));
      });

      test('nord9 is #81a1c1', () {
        expect(NordTheme.nord9, const Color(0xFF81a1c1));
      });

      test('nord10 is #5e81ac', () {
        expect(NordTheme.nord10, const Color(0xFF5e81ac));
      });

      test('nord11 is #bf616a', () {
        expect(NordTheme.nord11, const Color(0xFFbf616a));
      });

      test('nord12 is #d08770', () {
        expect(NordTheme.nord12, const Color(0xFFd08770));
      });

      test('nord13 is #ebcb8b', () {
        expect(NordTheme.nord13, const Color(0xFFebcb8b));
      });

      test('nord14 is #a3be8c', () {
        expect(NordTheme.nord14, const Color(0xFFa3be8c));
      });

      test('nord15 is #b48ead', () {
        expect(NordTheme.nord15, const Color(0xFFb48ead));
      });
    });
  });
}
