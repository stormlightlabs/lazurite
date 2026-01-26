import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/debug/application/system_info_provider.dart';
import 'package:lazurite/src/features/debug/presentation/system_info_tab.dart';

void main() {
  testWidgets('SystemInfoTab displays version info', (tester) async {
    const systemInfo = SystemInfo(
      flutterVersion: '3.0.0',
      buildMode: 'Test',
      platform: 'TestOS',
      osVersion: '1.0',
      screenSize: Size(100, 200),
      pixelRatio: 1.0,
      safeAreaInsets: EdgeInsets.zero,
      appVersion: '9.9.9',
      buildNumber: '888',
      gitVersion: 'v1.2.3-git',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [systemInfoProvider.overrideWith((ref) => Future.value(systemInfo))],
        child: const MaterialApp(home: Scaffold(body: SystemInfoTab())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Apps Version'), findsOneWidget);
    expect(find.text('9.9.9+888'), findsOneWidget);
    expect(find.text('Git Version'), findsOneWidget);
    expect(find.text('v1.2.3-git'), findsOneWidget);
  });
}
