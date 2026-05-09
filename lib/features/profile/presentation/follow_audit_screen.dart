import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/profile/cubit/follow_audit_cubit.dart';
import 'package:lazurite/features/profile/data/follow_audit_repository.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/shared/presentation/widgets/staggered_entrance.dart';

class FollowAuditScreen extends StatelessWidget {
  const FollowAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.labelAuditFollowers)),
      body: BlocBuilder<FollowAuditCubit, FollowAuditState>(
        builder: (context, state) {
          final visibleEntries = _visibleEntries(state);
          final countsByStatus = _countsByStatus(state.results);
          final selectedCount = state.selectedResults.length;
          final isBusy = _isBusy(state.status);

          return Column(
            children: [
              _HeaderCard(scannedFollows: state.progress, totalFollows: state.totalFollows, status: state.status),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _AuditActionButton(status: state.status, selectedCount: selectedCount, isBusy: isBusy),
                    ),
                  ],
                ),
              ),
              _ProgressSection(status: state.status, progress: state.progress, totalFollows: state.totalFollows),
              if (state.failedProfiles > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.formatProfilesFailedToLoad(state.failedProfiles),
                      key: const Key('follow_audit_failed_warning'),
                      style: TextStyle(color: context.colorScheme.tertiary),
                    ),
                  ),
                ),
              if (state.status == FollowAuditStatus.error)
                _ErrorBanner(message: state.errorMessage ?? context.l10n.errorFollowAuditFailed),
              if (state.status == FollowAuditStatus.complete && state.unfollowedCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.formatUnfollowedAccounts(state.unfollowedCount),
                      key: const Key('follow_audit_complete_message'),
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 600;
                    final filters = _FilterControls(state: state, countsByStatus: countsByStatus, isNarrow: isNarrow);

                    if (isNarrow) {
                      return Column(
                        children: [
                          filters,
                          const SizedBox(height: 8),
                          Expanded(
                            child: _ResultsPanel(state: state, visibleEntries: visibleEntries),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        SizedBox(width: 280, child: filters),
                        VerticalDivider(width: 1, color: context.colorScheme.outlineVariant),
                        Expanded(
                          child: _ResultsPanel(state: state, visibleEntries: visibleEntries),
                        ),
                      ],
                    );
                  },
                ),
              ),
              _SummaryFooter(selectedCount: selectedCount, total: state.results.length),
            ],
          );
        },
      ),
    );
  }

  bool _isBusy(FollowAuditStatus status) {
    return status == FollowAuditStatus.fetching ||
        status == FollowAuditStatus.classifying ||
        status == FollowAuditStatus.unfollowing;
  }

  List<({int index, ClassifiedFollow item})> _visibleEntries(FollowAuditState state) {
    final entries = <({int index, ClassifiedFollow item})>[];
    for (var i = 0; i < state.results.length; i++) {
      final item = state.results[i];
      if (state.visibleStatuses.contains(item.status)) {
        entries.add((index: i, item: item));
      }
    }
    return entries;
  }

  Map<FollowStatus, int> _countsByStatus(List<ClassifiedFollow> results) {
    final map = <FollowStatus, int>{for (final status in FollowStatus.values) status: 0};
    for (final item in results) {
      map[item.status] = (map[item.status] ?? 0) + 1;
    }
    return map;
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.scannedFollows, required this.totalFollows, required this.status});

  final int scannedFollows;
  final int totalFollows;
  final FollowAuditStatus status;

  @override
  Widget build(BuildContext context) {
    final subtitle = _subtitle(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.labelAuditFollowers.toUpperCase(),
            style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _subtitle(BuildContext context) {
    if (status == FollowAuditStatus.fetching) {
      return context.l10n.messageGettingFollowCount;
    }
    if (status == FollowAuditStatus.complete && totalFollows > 0) {
      return context.l10n.formatFollowAuditPromptWithCount(totalFollows);
    }
    if (totalFollows > 0 && scannedFollows <= 0) {
      return context.l10n.formatFollowAuditPromptWithCount(totalFollows);
    }
    if (totalFollows <= 0 && scannedFollows <= 0) {
      return context.l10n.messageFollowAuditIntro;
    }
    if (status == FollowAuditStatus.classifying && totalFollows > 0) {
      return context.l10n.formatClassifyingProgress(scannedFollows, totalFollows);
    }
    return context.l10n.formatFollowsScanned(scannedFollows);
  }
}

class _AuditActionButton extends StatelessWidget {
  const _AuditActionButton({required this.status, required this.selectedCount, required this.isBusy});

  final FollowAuditStatus status;
  final int selectedCount;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    if (status == FollowAuditStatus.initial) {
      return FilledButton.icon(
        key: const Key('follow_audit_scan_button'),
        onPressed: isBusy ? null : () => context.read<FollowAuditCubit>().audit(),
        icon: const Icon(Icons.manage_search_outlined),
        label: Text(context.l10n.buttonScan),
      );
    }

    if (status == FollowAuditStatus.fetching || status == FollowAuditStatus.classifying) {
      return OutlinedButton.icon(
        key: const Key('follow_audit_cancel_button'),
        onPressed: () => context.read<FollowAuditCubit>().cancelAudit(),
        icon: const Icon(Icons.stop_circle_outlined),
        label: Text(context.l10n.buttonCancel),
      );
    }

    return FilledButton.tonalIcon(
      key: const Key('follow_audit_unfollow_button'),
      onPressed: selectedCount == 0 || isBusy ? null : () => context.read<FollowAuditCubit>().confirmUnfollow(),
      icon: const Icon(Icons.person_remove_outlined),
      label: Text(context.l10n.buttonUnfollowSelected(selectedCount)),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.status, required this.progress, required this.totalFollows});

  final FollowAuditStatus status;
  final int progress;
  final int totalFollows;

  @override
  Widget build(BuildContext context) {
    if (status != FollowAuditStatus.fetching && status != FollowAuditStatus.classifying) {
      return const SizedBox.shrink();
    }

    final shownTotal = totalFollows > 0 ? totalFollows : math.max(progress, 1);
    final isFetchingCount = status == FollowAuditStatus.fetching;
    final value = isFetchingCount ? null : (progress / shownTotal).clamp(0.0, 1.0);
    final label = isFetchingCount
        ? context.l10n.messageGettingFollowCount
        : context.l10n.formatClassifyingProgress(progress, shownTotal);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          LinearProgressIndicator(key: const Key('follow_audit_progress'), value: value),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(label, key: const Key('follow_audit_progress_label')),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.error),
        color: context.colorScheme.errorContainer,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: context.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: TextStyle(color: context.colorScheme.onErrorContainer)),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('follow_audit_retry_button'),
                  onPressed: () => context.read<FollowAuditCubit>().audit(),
                  child: Text(context.l10n.buttonRetry),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterControls extends StatelessWidget {
  const _FilterControls({required this.state, required this.countsByStatus, required this.isNarrow});

  final FollowAuditState state;
  final Map<FollowStatus, int> countsByStatus;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final content = isNarrow
        ? SingleChildScrollView(
            key: const Key('follow_audit_filter_chips'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final status in FollowStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterTile(
                      status: status,
                      count: countsByStatus[status] ?? 0,
                      records: state.results.where((item) => item.status == status).toList(),
                      visibleStatuses: state.visibleStatuses,
                      compact: true,
                    ),
                  ),
              ],
            ),
          )
        : Container(
            key: const Key('follow_audit_filter_sidebar'),
            color: context.colorScheme.surfaceContainerLowest,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                  child: Text(
                    context.l10n.labelFilters.toUpperCase(),
                    style: context.textTheme.labelMedium?.copyWith(letterSpacing: 1.0, fontWeight: FontWeight.w700),
                  ),
                ),
                for (final status in FollowStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FilterTile(
                      status: status,
                      count: countsByStatus[status] ?? 0,
                      records: state.results.where((item) => item.status == status).toList(),
                      visibleStatuses: state.visibleStatuses,
                      compact: false,
                    ),
                  ),
              ],
            ),
          );

    return SizedBox(height: isNarrow ? 112 : null, child: content);
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.status,
    required this.count,
    required this.records,
    required this.visibleStatuses,
    required this.compact,
  });

  final FollowStatus status;
  final int count;
  final List<ClassifiedFollow> records;
  final Set<FollowStatus> visibleStatuses;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final allSelected = records.isNotEmpty && records.every((item) => item.selected);
    final someSelected = records.any((item) => item.selected);
    final isVisible = visibleStatuses.contains(status);

    return Container(
      width: compact ? 220 : null,
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _labelForStatus(context, status).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('$count', style: context.textTheme.labelSmall),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                key: Key('follow_audit_visibility_${status.name}'),
                visualDensity: VisualDensity.compact,
                icon: Icon(isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => context.read<FollowAuditCubit>().toggleVisibility(status),
                tooltip: isVisible
                    ? context.l10n.formatHideStatus(_labelForStatus(context, status))
                    : context.l10n.formatShowStatus(_labelForStatus(context, status)),
              ),
              Checkbox(
                key: Key('follow_audit_select_all_${status.name}'),
                value: allSelected,
                tristate: someSelected && !allSelected,
                onChanged: count == 0
                    ? null
                    : (value) {
                        if (value == true) {
                          context.read<FollowAuditCubit>().selectAllByStatus(status);
                          return;
                        }
                        context.read<FollowAuditCubit>().deselectAllByStatus(status);
                      },
              ),
              Expanded(
                child: Text(
                  context.l10n.labelSelectAll,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultsPanel extends StatefulWidget {
  const _ResultsPanel({required this.state, required this.visibleEntries});

  final FollowAuditState state;
  final List<({int index, ClassifiedFollow item})> visibleEntries;

  @override
  State<_ResultsPanel> createState() => _ResultsPanelState();
}

class _ResultsPanelState extends State<_ResultsPanel> {
  final Set<String> _seenRows = <String>{};

  @override
  Widget build(BuildContext context) {
    if (widget.state.status == FollowAuditStatus.initial) {
      return Center(child: Text(context.l10n.messageFollowAuditStartPrompt));
    }

    if (widget.state.status == FollowAuditStatus.fetching) {
      return _CenteredAuditSpinner(message: context.l10n.messageGettingFollowCount);
    }

    if (widget.state.results.isEmpty &&
        (widget.state.status == FollowAuditStatus.ready || widget.state.status == FollowAuditStatus.complete)) {
      return Center(
        child: Text(
          widget.state.status == FollowAuditStatus.complete && widget.state.totalFollows > 0
              ? context.l10n.formatFollowAuditPromptWithCount(widget.state.totalFollows)
              : context.l10n.messageNoProblematicFollows,
          key: const Key('follow_audit_empty_message'),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (widget.state.results.isEmpty && widget.state.status == FollowAuditStatus.classifying) {
      return _CenteredAuditSpinner(
        key: const Key('follow_audit_streaming_empty_message'),
        message: context.l10n.formatClassifyingProgress(widget.state.progress, math.max(widget.state.totalFollows, 1)),
      );
    }

    if (widget.visibleEntries.isEmpty && widget.state.results.isNotEmpty) {
      return Center(child: Text(context.l10n.messageNoResultsForFilters));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: widget.visibleEntries.length + (widget.state.status == FollowAuditStatus.classifying ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= widget.visibleEntries.length) {
          return _ScanningFooter(state: widget.state);
        }
        final entry = widget.visibleEntries[index];
        final rowKey = '${entry.item.record.subjectDid}:${entry.item.record.rkey}';
        return StaggeredEntrance(
          itemKey: rowKey,
          index: index,
          seenKeys: _seenRows,
          child: _ResultRow(index: entry.index, item: entry.item),
        );
      },
    );
  }
}

class _CenteredAuditSpinner extends StatelessWidget {
  const _CenteredAuditSpinner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ScanningFooter extends StatelessWidget {
  const _ScanningFooter({required this.state});

  final FollowAuditState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              context.l10n.formatClassifyingProgress(state.progress, math.max(state.totalFollows, 1)),
              key: const Key('follow_audit_scanning_footer'),
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.index, required this.item});

  final int index;
  final ClassifiedFollow item;

  @override
  Widget build(BuildContext context) {
    final selectedTint = context.colorScheme.error.withValues(alpha: 0.08);

    return Container(
      key: Key('follow_audit_row_${item.record.rkey}'),
      color: item.selected ? selectedTint : context.colorScheme.surfaceContainerLowest,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.read<FollowAuditCubit>().toggleSelection(index),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  key: Key('follow_audit_checkbox_${item.record.rkey}'),
                  value: item.selected,
                  onChanged: (_) => context.read<FollowAuditCubit>().toggleSelection(index),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        key: Key('follow_audit_handle_${item.record.rkey}'),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                        onPressed: () {
                          navigateToProfile(context, item.record.subjectDid);
                        },
                        child: Text(
                          item.handle ?? item.record.subjectDid,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: item.record.subjectDid));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.formatDidCopied),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Text(
                          _truncateDid(item.record.subjectDid),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontFamily: 'JetBrains Mono',
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Chip(label: Text(_labelForStatus(context, item.status)), visualDensity: VisualDensity.compact),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _truncateDid(String did) {
    if (did.length <= 24) {
      return did;
    }

    final prefix = did.substring(0, 14);
    final suffix = did.substring(did.length - 8);
    return '$prefix...$suffix';
  }
}

class _SummaryFooter extends StatelessWidget {
  const _SummaryFooter({required this.selectedCount, required this.total});

  final int selectedCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('follow_audit_summary'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colorScheme.outlineVariant)),
      ),
      child: Text(
        context.l10n.formatSelectedCount(selectedCount, total),
        style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _labelForStatus(BuildContext context, FollowStatus status) {
  final l10n = context.l10n;
  return switch (status) {
    FollowStatus.deleted => l10n.statusDeleted,
    FollowStatus.deactivated => l10n.statusDeactivated,
    FollowStatus.suspended => l10n.statusSuspended,
    FollowStatus.blockedBy => l10n.statusBlockedBy,
    FollowStatus.blocking => l10n.statusBlocking,
    FollowStatus.mutualBlock => l10n.statusMutualBlock,
    FollowStatus.hidden => l10n.statusHidden,
    FollowStatus.selfFollow => l10n.statusSelfFollow,
  };
}
