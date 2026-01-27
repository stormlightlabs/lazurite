import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';
import 'package:lazurite/src/core/widgets/lazurite_image.dart';
import 'package:lazurite/src/features/profile/domain/profile.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/profile_labels.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/profile_relationship_indicator.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/verification_badge.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
    final joinedDate = profile.createdAt != null
        ? DateFormat.yMMMd().format(profile.createdAt!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            LazuriteImage(
              imageUrl: profile.banner ?? '',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: Container(color: colorScheme.primaryContainer),
              errorWidget: Container(color: colorScheme.primaryContainer),
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

        Padding(
          padding: const EdgeInsets.only(top: 8, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ProfileRelationshipIndicator(
                viewerMuted: profile.viewerMuted,
                viewerBlocked: profile.viewerBlockingUri != null,
                viewerBlockedBy: profile.viewerBlockedBy,
                viewerFollowedBy: profile.viewerFollowedBy,
                mutedByList: profile.viewerMutedByList,
                blockingByList: profile.viewerBlockingByList,
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.displayNameOrHandle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (profile.verificationStatus != null) ...[
                          const SizedBox(width: 4),
                          VerificationBadge(verificationStatus: profile.verificationStatus),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '@${profile.handle}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
                        if (profile.pronouns != null && profile.pronouns!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(profile.pronouns!, style: theme.textTheme.labelSmall),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (followButton != null) followButton!,
            ],
          ),
        ),

        if (profile.labels != null && profile.labels!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ProfileLabels(labels: profile.labels),
          ),

        if (profile.description != null && profile.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(profile.description!, style: theme.textTheme.bodyMedium),
          ),
        ],

        if (profile.website != null || joinedDate != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (profile.website != null) ...[
                  const Icon(Icons.link, size: 16),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => launchUrlString(profile.website!),
                    child: Text(
                      profile.website!,
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (joinedDate != null) ...[
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text('Joined $joinedDate', style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
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
