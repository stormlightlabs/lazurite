import 'package:poptart_lex/com/atproto/moderation/defs.dart';
import 'package:poptart_core/poptart_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/shared/presentation/helpers/haptic_helper.dart';

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

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = widget._type == _ReportType.post ? l10n.labelReportPost : l10n.labelReportAccount;
    final target = widget.authorHandle;

    return AlertDialog(
      title: Text(l10n.formatProfileReportTitle(title, target)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.labelReportReason, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._reasonOptions(context).map((option) => _buildReasonOption(option)),
            if (_requiresExplanation) ...[
              const SizedBox(height: 16),
              Text(
                l10n.labelReportReasonExplanationRequired,
                style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText: l10n.messageReportExplanationHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isSubmitting ? null : () => Navigator.pop(context), child: Text(l10n.buttonCancel)),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.buttonSubmitReport),
        ),
      ],
    );
  }

  List<({ReasonType type, String label, String description})> _reasonOptions(BuildContext context) {
    final l10n = context.l10n;
    return [
      (
        type: const ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonSpam),
        label: l10n.labelReportReasonSpam,
        description: l10n.messageReportReasonSpamDescription,
      ),
      (
        type: const ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonViolation),
        label: l10n.labelReportReasonViolation,
        description: l10n.messageReportReasonViolationDescription,
      ),
      (
        type: const ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonMisleading),
        label: l10n.labelReportReasonMisleading,
        description: l10n.messageReportReasonMisleadingDescription,
      ),
      (
        type: const ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonSexual),
        label: l10n.labelReportReasonSexualContent,
        description: l10n.messageReportReasonSexualContentDescription,
      ),
      (
        type: const ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonRude),
        label: l10n.labelReportReasonHarassment,
        description: l10n.messageReportReasonHarassmentDescription,
      ),
      (
        type: const ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonOther),
        label: l10n.labelReportReasonOther,
        description: l10n.messageReportReasonOtherDescription,
      ),
    ];
  }

  Widget _buildReasonOption(({ReasonType type, String label, String description}) option) {
    final isSelected = _selectedReason == option.type;
    final theme = Theme.of(context);

    return InkWell(
      onTap: _isSubmitting
          ? null
          : () {
              HapticHelper.selectionClick();
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
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(context.l10n.labelReportSubmitted),
          ],
        ),
        content: Text(context.l10n.formatReportSubmitted(reportId)),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.buttonOk))],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(context.l10n.errorReportFailedTitle),
          ],
        ),
        content: Text(context.l10n.errorReportFailed),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.buttonOk))],
      ),
    );
  }
}
