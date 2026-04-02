import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/profile/presentation/widgets/suggested_follows_list.dart';

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
              'Suggested Follows',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SuggestedFollowsList(
              actor: actor,
              scrollController: scrollController,
              onProfileTap: (profile) {
                final router = GoRouter.of(context);
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                router.push('/profile/view?actor=${Uri.encodeComponent(profile.did)}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
