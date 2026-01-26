import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/src/core/utils/error_message.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/scheduling/application/scheduling_providers.dart';
import 'package:lazurite/src/features/scheduling/domain/schedule.dart';

/// Screen for viewing and managing a scheduled post.
///
/// This screen is shown when a user taps on a scheduled post notification
/// or navigates to a scheduled draft directly. It provides options to:
/// - Post the draft now
/// - Edit the draft
/// - Cancel the schedule
class ScheduledPostDetailScreen extends ConsumerStatefulWidget {
  const ScheduledPostDetailScreen({required this.draftId, super.key});

  final String draftId;

  @override
  ConsumerState<ScheduledPostDetailScreen> createState() => _ScheduledPostDetailScreenState();
}

class _ScheduledPostDetailScreenState extends ConsumerState<ScheduledPostDetailScreen> {
  bool _isPublishing = false;
  bool _isCancelling = false;

  Future<void> _postNow() async {
    if (_isPublishing) return;

    setState(() => _isPublishing = true);

    try {
      final publisher = ref.read(postPublisherProvider);
      await publisher.publishDraft(widget.draftId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Posted successfully!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: ${errorMessage(e)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  Future<void> _edit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Scheduled Post'),
        content: const Text(
          'Editing will cancel the current schedule. You can set a new schedule after editing.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue to Edit'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final scheduler = ref.read(schedulerProvider);
      await scheduler.cancel(widget.draftId);

      if (mounted) {
        context.pushReplacement('/compose?draftId=${widget.draftId}');
      }
    }
  }

  Future<void> _cancelSchedule() async {
    if (_isCancelling) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Schedule?'),
        content: const Text('The draft will be saved but the schedule will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Keep Scheduled'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel Schedule'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);

    try {
      final scheduler = ref.read(schedulerProvider);
      await scheduler.cancel(widget.draftId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Schedule cancelled')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: ${errorMessage(e)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  Widget _buildErrorView(Object? err, ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
          const SizedBox(height: 16),
          Text('Failed to load scheduled post', style: textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(
            errorMessage(err),
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledTimeCard(Schedule schedule, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: colorScheme.onPrimaryContainer, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Scheduled for',
                  style: textTheme.labelMedium?.copyWith(color: colorScheme.onPrimaryContainer),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatScheduledTime(schedule.scheduledAtUtc),
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimeRemaining(schedule.scheduledAtUtc),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer.withAlpha(179),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftPreviewCard(Draft draft, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Draft Preview', style: textTheme.labelLarge),
            const SizedBox(height: 12),
            Text(draft.text),
            if (draft.media.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${draft.media.length} image(s) attached',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Post'),
        actions: [
          if (!_isPublishing)
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _edit, tooltip: 'Edit'),
        ],
      ),
      body: FutureBuilder<({Schedule schedule, Draft draft})>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error, colorScheme, textTheme);
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.not_interested, size: 48, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('Scheduled post not found', style: theme.textTheme.bodyLarge),
                ],
              ),
            );
          }

          final schedule = data.schedule;
          final draft = data.draft;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildScheduledTimeCard(schedule, colorScheme, textTheme),
                    const SizedBox(height: 16),
                    _buildDraftPreviewCard(draft, colorScheme, textTheme),
                  ],
                ),
              ),
              if (_isPublishing || _isCancelling)
                Container(
                  color: colorScheme.surface.withAlpha(200),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: _isPublishing || _isCancelling ? null : _postNow,
                icon: _isPublishing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send),
                label: Text(_isPublishing ? 'Posting...' : 'Post Now'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isPublishing || _isCancelling ? null : _cancelSchedule,
                icon: const Icon(Icons.cancel_outlined),
                label: Text(_isCancelling ? 'Cancelling...' : 'Cancel Schedule'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<({Schedule schedule, Draft draft})> _loadData() async {
    final scheduleRepo = ref.read(scheduleRepositoryProvider);
    final draftRepo = ref.read(draftRepositoryProvider);

    final schedule = await scheduleRepo.getSchedule(widget.draftId);
    if (schedule == null) {
      throw Exception('Schedule not found');
    }

    final draft = await draftRepo.getDraft(widget.draftId);
    return (schedule: schedule, draft: draft);
  }

  String _formatScheduledTime(DateTime utcDateTime) {
    final local = utcDateTime.toLocal();
    return DateFormat('MMM d, y • h:mm a').format(local);
  }

  String _formatTimeRemaining(DateTime utcDateTime) {
    final scheduled = utcDateTime;
    final now = DateTime.now();
    final difference = scheduled.difference(now);

    if (difference.isNegative) {
      return 'Past due';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return 'in $days day${days == 1 ? '' : 's'}';
    } else if (hours > 0) {
      return 'in $hours hour${hours == 1 ? '' : 's'}';
    } else if (minutes > 0) {
      return 'in $minutes minute${minutes == 1 ? '' : 's'}';
    } else {
      return 'due soon';
    }
  }
}
