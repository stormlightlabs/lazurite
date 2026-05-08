import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/logging/log_redactor.dart';
import 'package:lazurite/features/logs/data/log_entry.dart';
import 'package:lazurite/features/logs/data/log_repository.dart';

part 'log_viewer_state.dart';

class LogViewerCubit extends Cubit<LogViewerState> {
  LogViewerCubit({
    Duration refreshInterval = const Duration(seconds: 1),
    Future<List<File>> Function()? logFilesProvider,
    Future<File?> Function()? todaysLogFileProvider,
    Directory Function()? systemTempDirectoryProvider,
    LogRepository logRepository = const LogRepository(),
  }) : _logRepository = logRepository,
       _logFilesProvider = logFilesProvider ?? log.getLogFiles,
       _todaysLogFileProvider = todaysLogFileProvider ?? log.getTodaysLogFile,
       _systemTempDirectoryProvider = systemTempDirectoryProvider ?? (() => Directory.systemTemp),
       super(LogViewerState.initial()) {
    unawaited(loadLogs());
    _refreshTimer = Timer.periodic(refreshInterval, (_) => unawaited(loadLogs(showLoading: false)));
  }

  static const String _shareDirectoryName = 'lazurite_logs_share';
  static const int initialVisibleEntries = 1000;
  static const int paginationPageSize = 1000;
  static final RegExp _datedLogFilePattern = RegExp(r'(\d{4})-(\d{2})-(\d{2})');
  static const String _staleShareDirectoryPrefix = 'lazurite_logs_share_';

  final LogRepository _logRepository;
  final Future<List<File>> Function() _logFilesProvider;
  final Future<File?> Function() _todaysLogFileProvider;
  final Directory Function() _systemTempDirectoryProvider;
  Timer? _refreshTimer;
  bool _isLoading = false;
  String? _lastSnapshotKey;
  List<LogEntry> _parsedEntries = const [];
  int _visibleEntryCount = initialVisibleEntries;

  Future<void> loadLogs({bool showLoading = true}) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    if (showLoading && state.status == LogViewerStatus.initial) {
      emit(state.copyWith(status: LogViewerStatus.loading, errorMessage: null));
    }

    try {
      final files = await _logFilesProvider();
      final snapshotKey = await _logRepository.snapshotKey(files);
      if (!showLoading && state.status == LogViewerStatus.loaded && snapshotKey == _lastSnapshotKey) {
        return;
      }

      _lastSnapshotKey = snapshotKey;
      _parsedEntries = await _logRepository.readEntries(files);
      _visibleEntryCount = _nextVisibleCountForRefresh();

      _emitLoadedState(errorMessage: null);
    } catch (e) {
      final nextState = state.copyWith(status: LogViewerStatus.error, errorMessage: e.toString());
      if (nextState != state) {
        emit(nextState);
      }
    } finally {
      _isLoading = false;
    }
  }

  int _nextVisibleCountForRefresh() {
    if (_parsedEntries.length <= initialVisibleEntries) {
      return _parsedEntries.length;
    }

    final currentVisibleCount = state.entries.isEmpty ? initialVisibleEntries : state.entries.length;
    return currentVisibleCount.clamp(initialVisibleEntries, _parsedEntries.length);
  }

  Future<void> loadOlderEntries() async {
    if (state.status != LogViewerStatus.loaded || state.isLoadingOlderEntries || !state.hasOlderEntries) {
      return;
    }

    emit(state.copyWith(isLoadingOlderEntries: true));
    _visibleEntryCount = (_visibleEntryCount + paginationPageSize).clamp(0, _parsedEntries.length);
    _emitLoadedState(errorMessage: null);
  }

  void _emitLoadedState({Object? errorMessage = _logViewerStateNoChange}) {
    final visibleEntries = _visibleEntries();
    final nextState = state.copyWith(
      status: LogViewerStatus.loaded,
      entries: visibleEntries,
      filteredEntries: _applyFilters(visibleEntries, state.enabledLevels, state.searchQuery),
      hasOlderEntries: _visibleEntryCount < _parsedEntries.length,
      isLoadingOlderEntries: false,
      errorMessage: errorMessage,
    );
    if (nextState != state) {
      emit(nextState);
    }
  }

  List<LogEntry> _visibleEntries() {
    if (_parsedEntries.isEmpty) {
      return const [];
    }

    final start = (_parsedEntries.length - _visibleEntryCount).clamp(0, _parsedEntries.length);
    return List.unmodifiable(_parsedEntries.sublist(start));
  }

  @override
  Future<void> close() async {
    _refreshTimer?.cancel();
    await super.close();
  }

  void toggleLevel(Level level) {
    final newLevels = Set<Level>.from(state.enabledLevels);
    if (newLevels.contains(level)) {
      newLevels.remove(level);
    } else {
      newLevels.add(level);
    }

    final nextState = state.copyWith(
      enabledLevels: newLevels,
      filteredEntries: _applyFilters(state.entries, newLevels, state.searchQuery),
    );
    if (nextState != state) {
      emit(nextState);
    }
  }

  void setSearchQuery(String query) {
    final nextState = state.copyWith(
      searchQuery: query,
      filteredEntries: _applyFilters(state.entries, state.enabledLevels, query),
    );
    if (nextState != state) {
      emit(nextState);
    }
  }

  List<LogEntry> _applyFilters(List<LogEntry> entries, Set<Level> enabledLevels, String searchQuery) {
    var filtered = entries.where((entry) => enabledLevels.contains(entry.level)).toList();

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((entry) {
        return entry.message.toLowerCase().contains(query) || (entry.source?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  Future<File?> getTodaysLogFile() async {
    final rawFile = await _todaysLogFileProvider();
    if (rawFile == null || !await rawFile.exists()) {
      return null;
    }

    final systemTempDirectory = _systemTempDirectoryProvider();
    await _cleanupStaleShareTempDirectories(systemTempDirectory);

    final content = await rawFile.readAsString();
    final redactedLines = content.split('\n').map(LogRedactor.redact).join('\n');
    final shareDirectory = Directory('${systemTempDirectory.path}/$_shareDirectoryName');
    if (!await shareDirectory.exists()) {
      await shareDirectory.create(recursive: true);
    }

    final shareFileName = _buildShareFileName(rawFile);
    final redactedFile = File('${shareDirectory.path}/$shareFileName');
    await redactedFile.writeAsString(redactedLines, flush: true);
    return redactedFile;
  }

  String _buildShareFileName(File sourceFile) {
    final basename = p.basename(sourceFile.path);
    final match = _datedLogFilePattern.firstMatch(basename);
    if (match != null) {
      return 'lazurite_logs_${match.group(1)}_${match.group(2)}_${match.group(3)}_share.log';
    }

    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return 'lazurite_logs_${year}_${month}_${day}_share.log';
  }

  Future<void> _cleanupStaleShareTempDirectories(Directory systemTempDirectory) async {
    if (!await systemTempDirectory.exists()) {
      return;
    }

    await for (final entity in systemTempDirectory.list(followLinks: false)) {
      if (entity is! Directory) {
        continue;
      }

      final name = entity.uri.pathSegments.isNotEmpty
          ? entity.uri.pathSegments[entity.uri.pathSegments.length - 2]
          : '';
      if (!name.startsWith(_staleShareDirectoryPrefix)) {
        continue;
      }

      try {
        await entity.delete(recursive: true);
      } catch (error, stackTrace) {
        log.d(
          'LogViewerCubit: could not remove stale temp share directory ${entity.path}.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> clearAllLogs() async {
    await log.clearAllLogs();
    _lastSnapshotKey = null;
    _parsedEntries = const [];
    _visibleEntryCount = initialVisibleEntries;
    await loadLogs(showLoading: false);
  }
}
