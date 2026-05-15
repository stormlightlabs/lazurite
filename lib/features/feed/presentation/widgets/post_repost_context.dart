import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';

class PostRepostContext extends StatelessWidget {
  const PostRepostContext({super.key, required this.reason});

  final UFeedViewPostReason? reason;

  @override
  Widget build(BuildContext context) {
    final repost = reason?.reasonRepost;
    if (repost == null) {
      return const SizedBox.shrink();
    }

    final reposter = repost.by;
    final reposterLabel = reposter.displayName?.trim().isNotEmpty == true
        ? reposter.displayName!.trim()
        : '@${reposter.handle}';
    final labelStyle = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    final linkStyle = labelStyle?.copyWith(color: context.colorScheme.primary, fontWeight: FontWeight.w700);

    return Semantics(
      button: true,
      label: '${context.l10n.labelRepostedByCard} $reposterLabel',
      child: InkWell(
        key: const ValueKey('post_repost_context'),
        onTap: () => navigateToProfile(context, reposter.did),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(Icons.repeat, size: 15, color: context.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(context.l10n.labelRepostedByCard, maxLines: 1, overflow: TextOverflow.ellipsis, style: labelStyle),
              const SizedBox(width: 4),
              Flexible(
                child: Text(reposterLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: linkStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
