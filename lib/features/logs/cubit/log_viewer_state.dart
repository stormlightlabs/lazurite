part of 'log_viewer_cubit.dart';

enum LogViewerStatus { initial, loading, loaded, error }

const _logViewerStateNoChange = Object();

class LogViewerState extends Equatable {
  const LogViewerState({
    this.status = LogViewerStatus.initial,
    this.entries = const [],
    this.filteredEntries = const [],
    this.enabledLevels = const {Level.trace, Level.debug, Level.info, Level.warning, Level.error, Level.fatal},
    this.searchQuery = '',
    this.hasOlderEntries = false,
    this.isLoadingOlderEntries = false,
    this.errorMessage,
  });

  factory LogViewerState.initial() => const LogViewerState();

  final LogViewerStatus status;
  final List<LogEntry> entries;
  final List<LogEntry> filteredEntries;
  final Set<Level> enabledLevels;
  final String searchQuery;
  final bool hasOlderEntries;
  final bool isLoadingOlderEntries;
  final String? errorMessage;

  LogViewerState copyWith({
    LogViewerStatus? status,
    List<LogEntry>? entries,
    List<LogEntry>? filteredEntries,
    Set<Level>? enabledLevels,
    String? searchQuery,
    bool? hasOlderEntries,
    bool? isLoadingOlderEntries,
    Object? errorMessage = _logViewerStateNoChange,
  }) {
    return LogViewerState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      enabledLevels: enabledLevels ?? this.enabledLevels,
      searchQuery: searchQuery ?? this.searchQuery,
      hasOlderEntries: hasOlderEntries ?? this.hasOlderEntries,
      isLoadingOlderEntries: isLoadingOlderEntries ?? this.isLoadingOlderEntries,
      errorMessage: identical(errorMessage, _logViewerStateNoChange) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    entries,
    filteredEntries,
    enabledLevels,
    searchQuery,
    hasOlderEntries,
    isLoadingOlderEntries,
    errorMessage,
  ];
}
