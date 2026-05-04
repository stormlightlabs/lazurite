import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  setUpAll(() {
    registerFallbackValue(FlutterErrorDetails(exception: Exception('fallback'), stack: StackTrace.empty));
  });

  late MockFirebaseCrashlytics crashlytics;
  late FirebaseCrashReportingService service;

  setUp(() {
    crashlytics = MockFirebaseCrashlytics();
    service = FirebaseCrashReportingService(crashlytics: crashlytics);

    when(() => crashlytics.setCrashlyticsCollectionEnabled(any())).thenAnswer((_) async {});
    when(() => crashlytics.recordError(any(), any(), fatal: any(named: 'fatal'))).thenAnswer((_) async {});
    when(() => crashlytics.recordFlutterFatalError(any())).thenAnswer((_) async {});
    when(() => crashlytics.sendUnsentReports()).thenAnswer((_) async {});
    when(() => crashlytics.deleteUnsentReports()).thenAnswer((_) async {});
  });

  test('setCollectionEnabled delegates to Firebase Crashlytics', () async {
    await service.setCollectionEnabled(true);
    verify(() => crashlytics.setCrashlyticsCollectionEnabled(true)).called(1);
  });

  test('setCollectionEnabled does not throw when plugin call fails', () async {
    when(() => crashlytics.setCrashlyticsCollectionEnabled(any())).thenThrow(Exception('boom'));
    await service.setCollectionEnabled(false);
    verify(() => crashlytics.setCrashlyticsCollectionEnabled(false)).called(1);
  });

  test('recordError does not throw when plugin call fails', () async {
    when(() => crashlytics.recordError(any(), any(), fatal: any(named: 'fatal'))).thenThrow(Exception('boom'));
    await service.recordError(Exception('error'), StackTrace.current, fatal: true);
    verify(() => crashlytics.recordError(any(), any(), fatal: true)).called(1);
  });

  test('recordFlutterFatalError does not throw when plugin call fails', () async {
    when(() => crashlytics.recordFlutterFatalError(any())).thenThrow(Exception('boom'));
    service.recordFlutterFatalError(FlutterErrorDetails(exception: Exception('fatal'), stack: StackTrace.current));
    await Future<void>.delayed(const Duration(milliseconds: 1));
    verify(() => crashlytics.recordFlutterFatalError(any())).called(1);
  });

  test('crash delegates to Firebase Crashlytics', () {
    when(() => crashlytics.crash()).thenReturn(null);
    service.crash();
    verify(() => crashlytics.crash()).called(1);
  });
}
