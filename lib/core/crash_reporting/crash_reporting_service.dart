import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:lazurite/core/logging/app_logger.dart';

abstract class CrashReportingService {
  void recordFlutterFatalError(FlutterErrorDetails details);

  Future<void> recordError(Object error, StackTrace stackTrace, {bool fatal});

  Future<void> setCollectionEnabled(bool enabled);

  Future<void> sendUnsentReports();

  Future<void> deleteUnsentReports();

  void crash();
}

class NoopCrashReportingService implements CrashReportingService {
  @override
  void recordFlutterFatalError(FlutterErrorDetails details) {}

  @override
  Future<void> recordError(Object error, StackTrace stackTrace, {bool fatal = false}) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> sendUnsentReports() async {}

  @override
  Future<void> deleteUnsentReports() async {}

  @override
  void crash() {
    log.w('Crashlytics test crash unavailable because Firebase is not initialized.');
  }
}

class FirebaseCrashReportingService implements CrashReportingService {
  FirebaseCrashReportingService({FirebaseCrashlytics? crashlytics})
    : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  void recordFlutterFatalError(FlutterErrorDetails details) {
    try {
      unawaited(
        _crashlytics.recordFlutterFatalError(details).catchError((Object error, StackTrace stackTrace) {
          log.w('Unable to record Flutter fatal error in Crashlytics', error: error, stackTrace: stackTrace);
        }),
      );
    } catch (error, stackTrace) {
      log.w('Unable to record Flutter fatal error in Crashlytics', error: error, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> recordError(Object error, StackTrace stackTrace, {bool fatal = false}) async {
    try {
      await _crashlytics.recordError(error, stackTrace, fatal: fatal);
    } catch (recordError, recordStackTrace) {
      log.w('Unable to record error in Crashlytics', error: recordError, stackTrace: recordStackTrace);
    }
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
    } catch (error, stackTrace) {
      log.w('Unable to set Crashlytics collection state', error: error, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> sendUnsentReports() async {
    try {
      await _crashlytics.sendUnsentReports();
    } catch (error, stackTrace) {
      log.w('Unable to send unsent Crashlytics reports', error: error, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> deleteUnsentReports() async {
    try {
      await _crashlytics.deleteUnsentReports();
    } catch (error, stackTrace) {
      log.w('Unable to delete unsent Crashlytics reports', error: error, stackTrace: stackTrace);
    }
  }

  @override
  void crash() {
    try {
      _crashlytics.crash();
    } catch (error, stackTrace) {
      log.w('Unable to trigger Crashlytics test crash', error: error, stackTrace: stackTrace);
    }
  }
}
