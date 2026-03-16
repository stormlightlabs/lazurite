import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  AppLogger._();

  static final AppLogger _instance = AppLogger._();
  static AppLogger get instance => _instance;

  Logger? _logger;
  String? _logDirectory;

  Future<void> initialize() async {
    _logDirectory = await _getLogDirectory();
    final logDir = Directory(_logDirectory!);
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    await _cleanupOldLogs();

    _logger = Logger(
      filter: DevelopmentFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        AdvancedFileOutput(
          path: _logDirectory!,
          maxFileSizeKB: -1,
          fileNameFormatter: _dailyFileNameFormatter,
          latestFileName: _todayFileName(),
          maxRotatedFilesCount: 3,
          overrideExisting: false,
        ),
      ]),
    );

    await _logger!.init;
  }

  Future<String> _getLogDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return '${docsDir.path}/logs';
  }

  static String _dailyFileNameFormatter(DateTime timestamp) {
    return 'lazurite_${_formatDate(timestamp)}.log';
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _todayFileName() {
    return _dailyFileNameFormatter(DateTime.now());
  }

  Future<void> _cleanupOldLogs() async {
    if (_logDirectory == null) return;

    final logDir = Directory(_logDirectory!);
    if (!await logDir.exists()) return;

    const retentionDays = 3;
    final cutoffDate = DateTime.now().subtract(const Duration(days: retentionDays));

    await for (final entity in logDir.list()) {
      if (entity is File && entity.path.endsWith('.log')) {
        final fileName = entity.uri.pathSegments.last;
        final dateMatch = RegExp(r'lazurite_(\d{4}-\d{2}-\d{2})\.log').firstMatch(fileName);
        if (dateMatch != null) {
          final fileDate = DateTime.parse(dateMatch.group(1)!);
          if (fileDate.isBefore(cutoffDate)) {
            await entity.delete();
          }
        }
      }
    }
  }

  String? get logDirectory => _logDirectory;

  void t(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _logger?.t(message, time: time, error: error, stackTrace: stackTrace);
  }

  void d(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _logger?.d(message, time: time, error: error, stackTrace: stackTrace);
  }

  void i(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _logger?.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  void w(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _logger?.w(message, time: time, error: error, stackTrace: stackTrace);
  }

  void e(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _logger?.e(message, time: time, error: error, stackTrace: stackTrace);
  }

  void f(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _logger?.f(message, time: time, error: error, stackTrace: stackTrace);
  }

  Future<void> dispose() async {
    await _logger?.close();
    _logger = null;
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
    if (_logDirectory == null) return;

    final logDir = Directory(_logDirectory!);
    if (!await logDir.exists()) return;

    await for (final entity in logDir.list()) {
      if (entity is File && entity.path.endsWith('.log')) {
        await entity.delete();
      }
    }
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
