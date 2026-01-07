import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/features/composer/application/draft_recovery_controller.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';

class DraftRecoverySheet extends ConsumerStatefulWidget {
  const DraftRecoverySheet({required this.draft, super.key});

  final Draft draft;

  static Future<void> show(BuildContext context, Draft draft) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => DraftRecoverySheet(draft: draft),
    );
  }

  @override
  ConsumerState<DraftRecoverySheet> createState() => _DraftRecoverySheetState();
}

class _DraftRecoverySheetState extends ConsumerState<DraftRecoverySheet> {
  bool _isProcessing = false;

  Future<void> _handleRetry() async {
    setState(() => _isProcessing = true);
    try {
      Navigator.of(context).pop();
      await ref.read(draftRecoveryControllerProvider.notifier).retry(widget.draft);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Retrying upload...')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Retry failed: $e')));
      }
    }
  }

  Future<void> _handleDelete() async {
    setState(() => _isProcessing = true);
    await ref.read(draftRecoveryControllerProvider.notifier).delete(widget.draft);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _handleDismiss() async {
    setState(() => _isProcessing = true);
    await ref.read(draftRecoveryControllerProvider.notifier).dismiss(widget.draft);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Post Upload Interrupted', style: theme.textTheme.titleLarge),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'A post failed to finish uploading when the app was last closed.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.draft.text.isEmpty ? '(Media only post)' : widget.draft.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (widget.draft.media.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${widget.draft.media.length} image attached',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: _handleRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Upload'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _handleDismiss,
                      child: const Text('Save as Draft & Close'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _handleDelete,
                      style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                      child: const Text('Delete Post'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
