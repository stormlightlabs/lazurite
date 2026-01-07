import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/features/composer/application/draft_recovery_controller.dart';
import 'package:lazurite/src/features/composer/presentation/screens/draft_recovery_sheet.dart';

class DraftRecoveryListener extends ConsumerWidget {
  const DraftRecoveryListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(draftRecoveryControllerProvider, (previous, next) {
      next.whenData((drafts) {
        if (drafts.isNotEmpty) {
          Future.microtask(() {
            if (context.mounted) {
              DraftRecoverySheet.show(context, drafts.first);
            }
          });
        }
      });
    });

    return child;
  }
}
