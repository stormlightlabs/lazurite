import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/logs/cubit/log_viewer_cubit.dart';
import 'package:lazurite/features/logs/data/log_entry.dart';
import 'package:lazurite/shared/presentation/helpers/share_helper.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => LogViewerCubit(), child: const _LogsScreenContent());
  }
}

class _LogsScreenContent extends StatefulWidget {
  const _LogsScreenContent();

  @override
  State<_LogsScreenContent> createState() => _LogsScreenContentState();
}

class _LogsScreenContentState extends State<_LogsScreenContent> {
  late final ScrollController _scrollController;
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final isAtBottom = _scrollController.offset >= (maxScrollExtent - 24);
    if (isAtBottom != _autoScroll) {
      setState(() => _autoScroll = isAtBottom);
    }
  }

  void _scrollToBottom({bool animated = false}) {
    if (!_scrollController.hasClients) {
      return;
    }

    final targetOffset = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(targetOffset, duration: const Duration(milliseconds: 180), curve: Curves.easeOut);
    } else {
      _scrollController.jumpTo(targetOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogViewerCubit, LogViewerState>(
      listenWhen: (previous, current) =>
          previous.filteredEntries != current.filteredEntries || previous.status != current.status,
      listener: (context, state) {
        if (!_autoScroll || state.status != LogViewerStatus.loaded) {
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Logs'),
          actions: [
            IconButton(icon: const Icon(Icons.share_outlined), tooltip: 'Share log file', onPressed: _shareLogs),
            IconButton(
              icon: Icon(Icons.delete_outline, color: context.colorScheme.error),
              tooltip: 'Clear all logs',
              onPressed: () => _confirmClearLogs(context),
            ),
          ],
        ),
        body: Column(
          children: [
            _SearchBar(),
            _LevelFilterChips(),
            Expanded(child: _LogList(controller: _scrollController)),
            _AutoScrollIndicator(
              isActive: _autoScroll,
              onTap: () {
                setState(() => _autoScroll = true);
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animated: true));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareLogs() async {
    final cubit = context.read<LogViewerCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final shareOrigin = ShareHelper.sharePositionOriginForContext(context);

    final file = await cubit.getTodaysLogFile();
    if (!mounted) {
      return;
    }

    if (file == null || !await file.exists()) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(const SnackBar(content: Text('No log file available')));
      return;
    }

    if (!mounted) {
      return;
    }

    try {
      await ShareHelper.shareFilePathsAtOrigin(shareOrigin, [file.path], subject: 'Lazurite logs');
    } catch (error, stackTrace) {
      log.e('LogsScreen: Failed to open share sheet for log file', error: error, stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(const SnackBar(content: Text('Unable to open share sheet. Please try again.')));
    }
  }

  Future<void> _confirmClearLogs(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all logs?'),
        content: const Text('This will permanently delete all log files. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear', style: TextStyle(color: context.colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<LogViewerCubit>().clearAllLogs();
    }
  }
}

class _AutoScrollIndicator extends StatelessWidget {
  const _AutoScrollIndicator({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isActive ? colorScheme.primary : colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                'Auto-scroll',
                style: TextStyle(fontSize: 12, color: isActive ? colorScheme.primary : colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Filter logs...',
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13, color: context.colorScheme.onSurface),
        onChanged: (query) => context.read<LogViewerCubit>().setSearchQuery(query),
      ),
    );
  }
}

class _LevelFilterChips extends StatelessWidget {
  static const _levels = [
    (Level.fatal, 'Fatal', Colors.orange),
    (Level.error, 'Error', Colors.red),
    (Level.warning, 'Warning', Colors.yellow),
    (Level.info, 'Info', Colors.blue),
    (Level.debug, 'Debug', Colors.green),
    (Level.trace, 'Trace', Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogViewerCubit, LogViewerState>(
      buildWhen: (prev, curr) => prev.enabledLevels != curr.enabledLevels,
      builder: (context, state) {
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _levels.length,
            separatorBuilder: (context, index) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final (level, label, color) = _levels[index];
              final isEnabled = state.enabledLevels.contains(level);
              return FilterChip(
                label: Text(label),
                selected: isEnabled,
                onSelected: (selected) => context.read<LogViewerCubit>().toggleLevel(level),
                avatar: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? context.colorScheme.onPrimary : null,
                ),
                selectedColor: context.colorScheme.primary,
                backgroundColor: context.colorScheme.surface,
                side: BorderSide(color: context.colorScheme.outlineVariant),
                showCheckmark: false,
              );
            },
          ),
        );
      },
    );
  }
}

class _LogList extends StatelessWidget {
  const _LogList({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogViewerCubit, LogViewerState>(
      builder: (context, state) {
        if (state.status == LogViewerStatus.loading) {
          return const LoadingState();
        }

        if (state.status == LogViewerStatus.error) {
          return ErrorState(
            title: 'Failed to load logs',
            message: state.errorMessage ?? 'Unknown error',
            onRetry: () => context.read<LogViewerCubit>().loadLogs(),
          );
        }

        if (state.filteredEntries.isEmpty) {
          return const EmptyState(
            message: 'No logs yet',
            subtitle: 'Log entries will appear here',
            icon: Icons.description_outlined,
          );
        }

        return ListView.separated(
          controller: controller,
          itemCount: state.filteredEntries.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: context.colorScheme.outlineVariant),
          itemBuilder: (context, index) {
            return _LogEntryTile(entry: state.filteredEntries[index]);
          },
        );
      },
    );
  }
}

class _LogEntryTile extends StatefulWidget {
  const _LogEntryTile({required this.entry});

  final LogEntry entry;

  @override
  State<_LogEntryTile> createState() => _LogEntryTileState();
}

class _LogEntryTileState extends State<_LogEntryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor(context, widget.entry.level);
    final badgeColor = _getBadgeColor(context, widget.entry.level);

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.entry.formatTimestamp(),
              style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: context.colorScheme.outline),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(3)),
              child: Text(
                widget.entry.levelPrefix,
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _isFatalOrError(widget.entry.level) ? Colors.white : levelColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.entry.message,
                    style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: context.colorScheme.onSurface),
                    maxLines: _expanded ? null : 2,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                  ),
                  if (widget.entry.source != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        widget.entry.source!,
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 11,
                          color: context.colorScheme.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(BuildContext context, Level level) {
    final colorScheme = context.colorScheme;
    switch (level) {
      case Level.fatal:
      case Level.error:
        return colorScheme.error;
      case Level.warning:
        return Colors.orange;
      case Level.info:
        return colorScheme.primary;
      default:
        return colorScheme.outline;
    }
  }

  Color _getBadgeColor(BuildContext context, Level level) {
    final colorScheme = context.colorScheme;
    switch (level) {
      case Level.fatal:
        return colorScheme.error;
      case Level.error:
        return colorScheme.error.withAlpha(38);
      case Level.warning:
        return Colors.orange.withAlpha(38);
      case Level.info:
        return colorScheme.primary.withAlpha(25);
      case Level.debug:
        return colorScheme.surfaceContainerHighest;
      default:
        return colorScheme.surface;
    }
  }

  bool _isFatalOrError(Level level) => level == Level.fatal || level == Level.error;
}
