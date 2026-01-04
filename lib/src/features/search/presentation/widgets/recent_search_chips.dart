import 'package:flutter/material.dart';
import 'package:lazurite/src/features/search/application/search_providers.dart';

/// Horizontal list of recent search chips.
class RecentSearchChips extends StatelessWidget {
  const RecentSearchChips({required this.searches, this.onTap, this.onDelete, super.key});

  /// List of recent search items.
  final List<RecentSearchItem> searches;

  /// Callback when a chip is tapped.
  final ValueChanged<String>? onTap;

  /// Callback when a chip's delete button is pressed.
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: searches.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final search = searches[index];
          return InputChip(
            label: Text(search.query),
            onPressed: () => onTap?.call(search.query),
            onDeleted: onDelete != null ? () => onDelete!(search.query) : null,
            deleteIcon: const Icon(Icons.close, size: 18),
          );
        },
      ),
    );
  }
}
