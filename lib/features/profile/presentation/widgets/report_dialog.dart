import 'package:atproto/com_atproto_moderation_defs.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

enum _ReportType { post, actor }

class ReportDialog extends StatefulWidget {
  const ReportDialog.post({super.key, required this.postUri, required this.cid, required this.authorHandle})
    : actorDid = null,
      _type = _ReportType.post;

  const ReportDialog.actor({super.key, required String did, required this.authorHandle})
    : postUri = null,
      cid = null,
      actorDid = did,
      _type = _ReportType.actor;

  final AtUri? postUri;
  final String? cid;
  final String? actorDid;
  final String authorHandle;
  final _ReportType _type;

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _reasonController = TextEditingController();
  ReasonType? _selectedReason;
  bool _isSubmitting = false;

  static const _reasonOptions = [
    (
      type: ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonSpam),
      label: 'Spam',
      description: 'Spam or unsolicited content',
    ),
    (
      type: ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonViolation),
      label: 'Violation',
      description: 'Violates community guidelines',
    ),
    (
      type: ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonMisleading),
      label: 'Misleading',
      description: 'Misleading or deceptive content',
    ),
    (
      type: ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonSexual),
      label: 'Sexual Content',
      description: 'Unwanted sexual content',
    ),
    (
      type: ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonRude),
      label: 'Harassment',
      description: 'Harassment or rude behaviour',
    ),
    (
      type: ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonOther),
      label: 'Other',
      description: 'Other reason (requires explanation)',
    ),
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget._type == _ReportType.post ? 'Report Post' : 'Report Account';
    final target = widget.authorHandle;

    return AlertDialog(
      title: Text('$title by @$target'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reason', style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._reasonOptions.map((option) => _buildReasonOption(option)),
            if (_requiresExplanation) ...[
              const SizedBox(height: 16),
              Text(
                'Explanation (required)',
                style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                maxLength: 2000,
                decoration: const InputDecoration(
                  hintText: 'Please explain why you are reporting this...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isSubmitting ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Submit Report'),
        ),
      ],
    );
  }

  Widget _buildReasonOption(({ReasonType type, String label, String description}) option) {
    final isSelected = _selectedReason == option.type;
    final theme = Theme.of(context);

    return InkWell(
      onTap: _isSubmitting
          ? null
          : () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedReason = option.type;
              });
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  Text(
                    option.description,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _requiresExplanation {
    if (_selectedReason == null) return false;
    if (_selectedReason!.isNotKnownValue) return false;
    return _selectedReason!.knownValue == KnownReasonType.comAtprotoModerationDefsReasonOther;
  }

  bool get _canSubmit {
    if (_selectedReason == null) return false;
    if (_requiresExplanation && _reasonController.text.trim().isEmpty) return false;
    return !_isSubmitting;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _isSubmitting = true;
    });

    final cubit = context.read<ProfileActionCubit>();
    final reason = _reasonController.text.trim().isNotEmpty ? _reasonController.text.trim() : null;

    String? reportId;

    if (widget._type == _ReportType.post && widget.postUri != null && widget.cid != null) {
      reportId = await cubit.reportPost(
        postUri: widget.postUri!,
        cid: widget.cid!,
        reasonType: _selectedReason!,
        reason: reason,
      );
    } else if (widget._type == _ReportType.actor) {
      reportId = await cubit.reportActor(reasonType: _selectedReason!, reason: reason);
    }

    if (mounted) {
      Navigator.pop(context);

      if (reportId != null) {
        _showSuccessDialog(reportId);
      } else {
        _showErrorDialog();
      }
    }
  }

  void _showSuccessDialog(String reportId) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Report Submitted'),
          ],
        ),
        content: Text('Thank you. Your report (ID: $reportId) has been submitted.'),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Report Failed'),
          ],
        ),
        content: const Text('Unable to submit your report. Please try again later.'),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}
