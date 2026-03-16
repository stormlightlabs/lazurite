import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lazurite/core/logging/app_file_log_printer.dart';
import 'package:lazurite/core/logging/daily_log_file_output.dart';

class AppLogger {
  AppLogger._();

  static final AppLogger _instance = AppLogger._();
  static AppLogger get instance => _instance;

  Logger? _consoleLogger;
  Logger? _fileLogger;
  DailyLogFileOutput? _fileOutput;
  String? _logDirectory;

  Future<void> initialize() async {
    await dispose();

    _logDirectory = await _getLogDirectory();
    _fileOutput = DailyLogFileOutput(directoryPath: _logDirectory!, retentionDays: 3);
    _fileLogger = Logger(
      filter: ProductionFilter(),
      printer: AppFileLogPrinter(),
      output: _fileOutput!,
      level: Level.trace,
    );

    final initFutures = <Future<void>>[_fileLogger!.init];

    if (kDebugMode) {
      _consoleLogger = Logger(
        filter: DevelopmentFilter(),
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
        output: ConsoleOutput(),
        level: Level.trace,
      );
      initFutures.add(_consoleLogger!.init);
    }

    await Future.wait(initFutures);
  }

  Future<String> _getLogDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return '${docsDir.path}/logs';
  }

  static String _todayFileName() {
    return DailyLogFileOutput.fileNameFor(DateTime.now());
  }

  void _log(Level level, dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    final logTime = time ?? DateTime.now();
    _fileLogger?.log(level, message, time: logTime, error: error, stackTrace: stackTrace);
    _consoleLogger?.log(level, message, time: logTime, error: error, stackTrace: stackTrace);
  }

  String? get logDirectory => _logDirectory;

  void t(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _log(Level.trace, message, time: time, error: error, stackTrace: stackTrace);
  }

  void d(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _log(Level.debug, message, time: time, error: error, stackTrace: stackTrace);
  }

  void i(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _log(Level.info, message, time: time, error: error, stackTrace: stackTrace);
  }

  void w(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _log(Level.warning, message, time: time, error: error, stackTrace: stackTrace);
  }

  void e(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _log(Level.error, message, time: time, error: error, stackTrace: stackTrace);
  }

  void f(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _log(Level.fatal, message, time: time, error: error, stackTrace: stackTrace);
  }

  Future<void> dispose() async {
    await _consoleLogger?.close();
    await _fileLogger?.close();
    _consoleLogger = null;
    _fileLogger = null;
    _fileOutput = null;
  }

  Future<List<File>> getLogFiles() async {
    if (_logDirectory == null) return [];

    final logDir = Directory(_logDirectory!);
    if (!await logDir.exists()) return [];

    final files = <File>[];
    await for (final entity in logDir.list()) {
      if (entity is File && entity.path.endsWith('.log')) {
        files.add(entity);
      }
    }

    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  Future<void> clearAllLogs() async {
    await _fileOutput?.clearAllLogs();
  }

  Future<File?> getTodaysLogFile() async {
    final files = await getLogFiles();
    final todayName = _todayFileName();
    for (final file in files) {
      if (file.uri.pathSegments.last == todayName) {
        return file;
      }
    }
    return null;
  }
}

final log = AppLogger.instance;
