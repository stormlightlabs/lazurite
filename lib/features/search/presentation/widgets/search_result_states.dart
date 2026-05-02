import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/search/bloc/search_bloc.dart';

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key, required this.tab});

  final SearchTab tab;

  @override
  Widget build(BuildContext context) {
    final (title, message) = switch (tab) {
      SearchTab.posts => (
        'Search posts',
        'Find conversations and keywords across posts.\nUse Jump to profile to quickly open a user.',
      ),
      SearchTab.actors => (
        'Search people',
        'Look up accounts by handle or name.\nUse Jump to profile when you know the exact handle.',
      ),
      SearchTab.feeds => ('Search feeds', 'Discover custom feeds by topic, creator, or keyword.'),
      SearchTab.starterPacks => ('Search starter packs', 'Find curated starter packs to discover accounts and feeds.'),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: context.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchNoResultsState extends StatelessWidget {
  const SearchNoResultsState({super.key, required this.tab, required this.query});

  final SearchTab tab;
  final String query;

  @override
  Widget build(BuildContext context) {
    final safeQuery = query.trim();
    final (title, message) = switch (tab) {
      SearchTab.posts => (
        'No posts found',
        'Try broader keywords or a shorter phrase${safeQuery.isEmpty ? '' : ' for "$safeQuery"'}.',
      ),
      SearchTab.actors => (
        'No people found',
        'Try a handle, display name, or fewer terms${safeQuery.isEmpty ? '' : ' for "$safeQuery"'}.',
      ),
      SearchTab.feeds => (
        'No feeds found',
        'Try searching by topic or feed creator${safeQuery.isEmpty ? '' : ' for "$safeQuery"'}.',
      ),
      SearchTab.starterPacks => (
        'No starter packs found',
        'Try another topic or broader keyword${safeQuery.isEmpty ? '' : ' for "$safeQuery"'}.',
      ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 44, color: context.colorScheme.outline),
            const SizedBox(height: 12),
            Text(title, style: context.textTheme.bodyLarge),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
