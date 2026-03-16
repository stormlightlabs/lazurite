import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/logs/data/log_entry.dart';

part 'log_viewer_state.dart';

class LogViewerCubit extends Cubit<LogViewerState> {
  LogViewerCubit() : super(LogViewerState.initial()) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    emit(state.copyWith(status: LogViewerStatus.loading));

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

      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(
        state.copyWith(
          status: LogViewerStatus.loaded,
          entries: entries,
          filteredEntries: _applyFilters(entries, state.enabledLevels, state.searchQuery),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: LogViewerStatus.error, errorMessage: e.toString()));
    }
  }

  void toggleLevel(Level level) {
    final newLevels = Set<Level>.from(state.enabledLevels);
    if (newLevels.contains(level)) {
      newLevels.remove(level);
    } else {
      newLevels.add(level);
    }
    emit(
      state.copyWith(
        enabledLevels: newLevels,
        filteredEntries: _applyFilters(state.entries, newLevels, state.searchQuery),
      ),
    );
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query, filteredEntries: _applyFilters(state.entries, state.enabledLevels, query)));
  }

  List<LogEntry> _applyFilters(List<LogEntry> entries, Set<Level> enabledLevels, String searchQuery) {
    var filtered = entries.where((e) => enabledLevels.contains(e.level)).toList();

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        return e.message.toLowerCase().contains(query) || (e.source?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  Future<File?> getTodaysLogFile() => log.getTodaysLogFile();

  Future<void> clearAllLogs() async {
    await log.clearAllLogs();
    emit(state.copyWith(entries: [], filteredEntries: []));
    await loadLogs();
  }
}
