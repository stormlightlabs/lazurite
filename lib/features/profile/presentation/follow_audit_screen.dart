import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/profile/cubit/follow_audit_cubit.dart';
import 'package:lazurite/features/profile/data/follow_audit_repository.dart';

class FollowAuditScreen extends StatelessWidget {
  const FollowAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Followers')),
      body: BlocBuilder<FollowAuditCubit, FollowAuditState>(
        builder: (context, state) {
          final visibleEntries = _visibleEntries(state);
          final countsByStatus = _countsByStatus(state.results);
          final selectedCount = state.selectedResults.length;
          final isBusy = _isBusy(state.status);

          return Column(
            children: [
              _HeaderCard(totalFollows: state.totalFollows),
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
                      '${state.failedProfiles} profile(s) could not be loaded.',
                      key: const Key('follow_audit_failed_warning'),
                      style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                ),
              if (state.status == FollowAuditStatus.error)
                _ErrorBanner(message: state.errorMessage ?? 'Failed to complete follow audit.'),
              if (state.status == FollowAuditStatus.complete && state.unfollowedCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Unfollowed ${state.unfollowedCount} account(s)',
                      key: const Key('follow_audit_complete_message'),
                      style: Theme.of(context).textTheme.titleMedium,
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
                        VerticalDivider(width: 1, color: Theme.of(context).colorScheme.outlineVariant),
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
  const _HeaderCard({required this.totalFollows});

  final int totalFollows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUDIT FOLLOWERS',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1),
          ),
          const SizedBox(height: 6),
          Text(
            totalFollows > 0
                ? '$totalFollows follows scanned for problematic accounts'
                : 'Scan your follows for deleted, suspended, blocked, and hidden accounts.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _AuditActionButton extends StatelessWidget {
  const _AuditActionButton({required this.status, required this.selectedCount, required this.isBusy});

  final FollowAuditStatus status;
  final int selectedCount;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    if (status == FollowAuditStatus.initial ||
        status == FollowAuditStatus.fetching ||
        status == FollowAuditStatus.classifying) {
      return FilledButton.icon(
        key: const Key('follow_audit_scan_button'),
        onPressed: isBusy ? null : () => context.read<FollowAuditCubit>().audit(),
        icon: const Icon(Icons.manage_search_outlined),
        label: const Text('Scan'),
      );
    }

    return FilledButton.tonalIcon(
      key: const Key('follow_audit_unfollow_button'),
      onPressed: selectedCount == 0 || isBusy ? null : () => context.read<FollowAuditCubit>().confirmUnfollow(),
      icon: const Icon(Icons.person_remove_outlined),
      label: Text('Unfollow Selected ($selectedCount)'),
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
    final value = (progress / shownTotal).clamp(0.0, 1.0);
    final label = status == FollowAuditStatus.fetching
        ? 'Fetching follows: $progress/$shownTotal'
        : 'Classifying: $progress/$shownTotal';

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
        border: Border.all(color: Theme.of(context).colorScheme.error),
        color: Theme.of(context).colorScheme.errorContainer,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('follow_audit_retry_button'),
                  onPressed: () => context.read<FollowAuditCubit>().audit(),
                  child: const Text('Retry'),
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
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                  child: Text(
                    'FILTERS',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(letterSpacing: 1.0, fontWeight: FontWeight.w700),
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
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _labelForStatus(status).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('$count', style: Theme.of(context).textTheme.labelSmall),
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
                tooltip: isVisible ? 'Hide ${_labelForStatus(status)}' : 'Show ${_labelForStatus(status)}',
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
                  'Select All',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _labelForStatus(FollowStatus status) {
    switch (status) {
      case FollowStatus.deleted:
        return 'Deleted';
      case FollowStatus.deactivated:
        return 'Deactivated';
      case FollowStatus.suspended:
        return 'Suspended';
      case FollowStatus.blockedBy:
        return 'Blocked by';
      case FollowStatus.blocking:
        return 'Blocking';
      case FollowStatus.mutualBlock:
        return 'Mutual block';
      case FollowStatus.hidden:
        return 'Hidden';
      case FollowStatus.selfFollow:
        return 'Self-follow';
    }
  }
}

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({required this.state, required this.visibleEntries});

  final FollowAuditState state;
  final List<({int index, ClassifiedFollow item})> visibleEntries;

  @override
  Widget build(BuildContext context) {
    if (state.status == FollowAuditStatus.initial) {
      return const Center(child: Text('Tap Scan to audit your follow list.'));
    }

    if (state.results.isEmpty &&
        (state.status == FollowAuditStatus.ready || state.status == FollowAuditStatus.complete)) {
      return const Center(child: Text('No problematic follows found', key: Key('follow_audit_empty_message')));
    }

    if (visibleEntries.isEmpty && state.results.isNotEmpty) {
      return const Center(child: Text('No results visible for the current filters.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: visibleEntries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = visibleEntries[index];
        return _ResultRow(index: entry.index, item: entry.item);
      },
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.index, required this.item});

  final int index;
  final ClassifiedFollow item;

  @override
  Widget build(BuildContext context) {
    final selectedTint = Theme.of(context).colorScheme.error.withValues(alpha: 0.08);

    return Container(
      key: Key('follow_audit_row_${item.record.rkey}'),
      color: item.selected ? selectedTint : Theme.of(context).colorScheme.surfaceContainerLowest,
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
                          context.push('/profile/view?actor=${Uri.encodeComponent(item.record.subjectDid)}');
                        },
                        child: Text(
                          item.handle ?? item.record.subjectDid,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: item.record.subjectDid));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('DID copied to clipboard'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Text(
                          _truncateDid(item.record.subjectDid),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'JetBrains Mono',
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Chip(label: Text(item.statusLabel), visualDensity: VisualDensity.compact),
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
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Text(
        'Selected: $selectedCount/$total',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
