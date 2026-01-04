import 'package:flutter/material.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';

/// Profile header widget displaying user info, stats, and actions.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.profile,
    this.onFollowersPressed,
    this.onFollowingPressed,
    this.followButton,
    super.key,
  });

  final ProfileData profile;

  /// Callback when followers count is tapped.
  final VoidCallback? onFollowersPressed;

  /// Callback when following count is tapped.
  final VoidCallback? onFollowingPressed;

  /// Optional follow button to display.
  final Widget? followButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                image: profile.banner != null
                    ? DecorationImage(
                        image: NetworkImage(profile.banner!),
                        fit: BoxFit.cover,
                        onError: (_, _) {},
                      )
                    : null,
              ),
            ),
            Positioned(
              left: 16,
              bottom: -40,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 4),
                ),
                child: Avatar(
                  imageUrl: profile.avatar,
                  radius: 40,
                  heroTag: 'profile_avatar_${profile.did}',
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 48),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayNameOrHandle,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${profile.handle}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),
              if (followButton != null) followButton!,
            ],
          ),
        ),

        if (profile.description != null && profile.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(profile.description!, style: theme.textTheme.bodyMedium),
          ),
        ],

        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _StatButton(
                count: profile.followersCount,
                label: 'Followers',
                onPressed: onFollowersPressed,
              ),
              const SizedBox(width: 16),
              _StatButton(
                count: profile.followsCount,
                label: 'Following',
                onPressed: onFollowingPressed,
              ),
              const SizedBox(width: 16),
              _StatButton(count: profile.postsCount, label: 'Posts'),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const Divider(height: 1),
      ],
    );
  }
}

class _StatButton extends StatelessWidget {
  const _StatButton({required this.count, required this.label, this.onPressed});

  final int count;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatCount(count),
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
        ),
      ],
    );

    if (onPressed != null) {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: content),
      );
    }

    return content;
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
