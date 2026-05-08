import 'package:bluesky/app_bsky_graph_defs.dart' as bsky_graph;
import 'package:flutter/material.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

/// A reusable tile for a single [bsky_graph.ListView] entry.
class ListRowTile extends StatelessWidget {
  const ListRowTile({super.key, required this.list, this.onTap, this.trailing});

  final bsky_graph.ListView list;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isMod = list.purpose.knownValue == bsky_graph.KnownListPurpose.appBskyGraphDefsModlist;
    final purposeLabel = isMod ? context.l10n.labelModerationShort : context.l10n.labelFeed.toUpperCase();
    final purposeColor = isMod ? colorScheme.error : colorScheme.primary;

    return ListTile(
      key: key,
      leading: ProfileAvatar(
        size: 40,
        imageUrl: list.avatar,
        fallbackText: list.name,
        fallbackBuilder: (_) => Icon(Icons.list, color: colorScheme.onSurfaceVariant),
      ),
      title: Text(list.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        context.l10n.formatMemberCount(list.listItemCount ?? 0),
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      trailing:
          trailing ??
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: purposeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: purposeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              purposeLabel,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: purposeColor, letterSpacing: 1),
            ),
          ),
      onTap: onTap,
    );
  }
}
