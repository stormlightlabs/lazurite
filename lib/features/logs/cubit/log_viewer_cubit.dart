import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/logs/data/log_entry.dart';

part 'log_viewer_state.dart';

class LogViewerCubit extends Cubit<LogViewerState> {
  LogViewerCubit({Duration refreshInterval = const Duration(seconds: 1)}) : super(LogViewerState.initial()) {
    unawaited(loadLogs());
    _refreshTimer = Timer.periodic(refreshInterval, (_) => unawaited(loadLogs(showLoading: false)));
  }

  Timer? _refreshTimer;
  bool _isLoading = false;

  Future<void> loadLogs({bool showLoading = true}) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    if (showLoading && state.status == LogViewerStatus.initial) {
      emit(state.copyWith(status: LogViewerStatus.loading, errorMessage: null));
    }

    try {
      final files = await log.getLogFiles();
      final entries = <LogEntry>[];

      for (final file in files) {
        final content = await file.readAsString();
        final lines = content.split('\n');
        for (final line in lines) {
          final entry = LogEntry.tryParse(line);
          if (entry != null) {
            entries.add(entry);
          }
        }
      }

      entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final nextState = state.copyWith(
        status: LogViewerStatus.loaded,
        entries: entries,
        filteredEntries: _applyFilters(entries, state.enabledLevels, state.searchQuery),
        errorMessage: null,
      );
      if (nextState != state) {
        emit(nextState);
      }
    } catch (e) {
      final nextState = state.copyWith(status: LogViewerStatus.error, errorMessage: e.toString());
      if (nextState != state) {
        emit(nextState);
      }
    } finally {
      _isLoading = false;
    }
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

  Future<File?> getTodaysLogFile() => log.getTodaysLogFile();

  Future<void> clearAllLogs() async {
    await log.clearAllLogs();
    await loadLogs(showLoading: false);
  }
}
