import 'package:flutter/material.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/features/profile/presentation/widgets/suggested_follows_list.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

class SuggestedFollowsSheet extends StatelessWidget {
  const SuggestedFollowsSheet({super.key, required this.actor});

  final String actor;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              context.l10n.labelSuggestedFollows,
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SuggestedFollowsList(
              actor: actor,
              scrollController: scrollController,
              onProfileTap: (profile) {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                navigateToProfile(context, profile.did);
              },
            ),
          ),
        ],
      ),
    );
  }
}
