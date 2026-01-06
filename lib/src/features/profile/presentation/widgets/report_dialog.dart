// ignore_for_file: deprecated_member_use
// FIXME: Remove the ignore and address deprecation
import 'package:flutter/material.dart';

enum ReportReason {
  spam('com.atproto.moderation.defs#reasonSpam', 'Spam'),
  violation('com.atproto.moderation.defs#reasonViolation', 'Violation'),
  misleading('com.atproto.moderation.defs#reasonMisleading', 'Misleading'),
  sexual('com.atproto.moderation.defs#reasonSexual', 'Sexual Content'),
  rude('com.atproto.moderation.defs#reasonRude', 'Rude'),
  other('com.atproto.moderation.defs#reasonOther', 'Other');

  const ReportReason(this.value, this.label);

  final String value;
  final String label;
}

class ReportDialog extends StatefulWidget {
  const ReportDialog({required this.actorDid, super.key});

  final String actorDid;

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportReason? _selectedReason;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report Account'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Why are you reporting this account?'),
            const SizedBox(height: 16),
            ...ReportReason.values.map(
              (reason) => RadioListTile<ReportReason>(
                title: Text(reason.label),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Additional Details (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _selectedReason == null
              ? null
              : () {
                  Navigator.of(context).pop(
                    ReportRequest(
                      reasonType: _selectedReason!.value,
                      reason: _reasonController.text,
                    ),
                  );
                },
          child: const Text('Report'),
        ),
      ],
    );
  }
}

class ReportRequest {
  const ReportRequest({required this.reasonType, this.reason});
  final String reasonType;
  final String? reason;
}
