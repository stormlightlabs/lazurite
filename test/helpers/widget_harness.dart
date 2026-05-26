import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget testScaffoldApp(Widget child, {ThemeData? theme, ThemeData? darkTheme, Locale? locale}) => MaterialApp(
  theme: theme,
  darkTheme: darkTheme,
  locale: locale,
  home: Scaffold(body: child),
);

Widget testHomeApp(Widget home, {ThemeData? theme, ThemeData? darkTheme, Locale? locale}) =>
    MaterialApp(theme: theme, darkTheme: darkTheme, locale: locale, home: home);

Widget testRouterApp(GoRouter router, {ThemeData? theme, ThemeData? darkTheme, Locale? locale}) =>
    MaterialApp.router(theme: theme, darkTheme: darkTheme, locale: locale, routerConfig: router);

Future<void> pumpTestScaffoldApp(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  ThemeData? darkTheme,
  Locale? locale,
  bool settle = false,
}) async {
  await tester.pumpWidget(testScaffoldApp(child, theme: theme, darkTheme: darkTheme, locale: locale));
  if (settle) {
    await tester.pumpAndSettle();
  }
}

Future<void> pumpTestHomeApp(
  WidgetTester tester,
  Widget home, {
  ThemeData? theme,
  ThemeData? darkTheme,
  Locale? locale,
  bool settle = false,
}) async {
  await tester.pumpWidget(testHomeApp(home, theme: theme, darkTheme: darkTheme, locale: locale));
  if (settle) {
    await tester.pumpAndSettle();
  }
}

Future<void> pumpTestRouterApp(
  WidgetTester tester,
  GoRouter router, {
  ThemeData? theme,
  ThemeData? darkTheme,
  Locale? locale,
  bool settle = true,
}) async {
  await tester.pumpWidget(testRouterApp(router, theme: theme, darkTheme: darkTheme, locale: locale));
  if (settle) {
    await tester.pumpAndSettle();
  }
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
