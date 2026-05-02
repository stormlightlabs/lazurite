import 'dart:async';
import 'dart:convert';

import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/search/cubit/semantic_index_cubit.dart';
import 'package:lazurite/features/search/cubit/semantic_search_cubit.dart';
import 'package:lazurite/features/search/data/semantic_search_result.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

/// The "Search" tab inside the saved posts screen.
///
/// Renders a search input, scope chips, and a results list backed by [SemanticSearchCubit].
/// Requires [SemanticSearchCubit], [SemanticIndexCubit], [PostActionRepository],
/// [PostActionCache], and a [String] account DID to be available in the widget tree.
class SemanticSearchTab extends StatefulWidget {
  const SemanticSearchTab({super.key});

  @override
  State<SemanticSearchTab> createState() => _SemanticSearchTabState();
}

class _SemanticSearchTabState extends State<SemanticSearchTab> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final settings = context.read<SettingsCubit>().state;
        context.read<SemanticSearchCubit>().setMaxResults(settings.semanticSearchMaxResults);
        unawaited(context.read<SemanticSearchCubit>().setScope(settings.searchScope));
        context.read<SemanticIndexCubit>().loadCount();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          previous.searchScope != current.searchScope ||
          previous.semanticSearchMaxResults != current.semanticSearchMaxResults,
      listener: (context, settingsState) {
        context.read<SemanticSearchCubit>().setMaxResults(settingsState.semanticSearchMaxResults);
        unawaited(context.read<SemanticSearchCubit>().setScope(settingsState.searchScope));
      },
      child: Column(
        children: [
          BlocBuilder<SemanticIndexCubit, SemanticIndexState>(
            builder: (context, indexState) {
              return _SearchInputRow(
                controller: _controller,
                focusNode: _searchFocusNode,
                onChanged: (query) => context.read<SemanticSearchCubit>().search(query),
                onClear: () {
                  _controller.clear();
                  context.read<SemanticSearchCubit>().clearResults();
                },
                indexState: indexState,
              );
            },
          ),
          BlocBuilder<SemanticIndexCubit, SemanticIndexState>(
            builder: (context, indexState) {
              return BlocSelector<SemanticSearchCubit, SemanticSearchState, SearchScope>(
                selector: (state) => state.scope,
                builder: (context, selectedScope) {
                  return _ScopeRow(
                    selected: selectedScope,
                    indexState: indexState,
                    onSelected: (scope) async {
                      await context.read<SemanticSearchCubit>().setScope(scope);
                      if (context.mounted) {
                        unawaited(context.read<SettingsCubit>().setSearchScope(scope));
                      }
                    },
                  );
                },
              );
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<SemanticSearchCubit, SemanticSearchState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status ||
                  previous.results != current.results ||
                  previous.errorMessage != current.errorMessage,
              builder: (context, state) => _ResultsView(state: state),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchInputRow extends StatelessWidget {
  const _SearchInputRow({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.indexState,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final SemanticIndexState indexState;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _SearchBar(controller: controller, focusNode: focusNode, onChanged: onChanged, onClear: onClear),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<_IndexMenuAction>(
            tooltip: 'Search index actions',
            icon: const Icon(Icons.more_vert),
            onSelected: (action) => unawaited(_onMenuSelected(context, action)),
            itemBuilder: (context) => [
              const PopupMenuItem<_IndexMenuAction>(
                value: _IndexMenuAction.semanticSettings,
                child: Text('Semantic settings'),
              ),
              const PopupMenuItem<_IndexMenuAction>(
                value: _IndexMenuAction.refreshCount,
                child: Text('Refresh indexed count'),
              ),
              PopupMenuItem<_IndexMenuAction>(
                value: _IndexMenuAction.reindex,
                enabled: !indexState.isBackfilling,
                child: const Text('Re-index posts'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onMenuSelected(BuildContext context, _IndexMenuAction action) async {
    final cubit = context.read<SemanticIndexCubit>();
    switch (action) {
      case _IndexMenuAction.semanticSettings:
        await showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (sheetContext) => const _SemanticSettingsSheet(),
        );
        break;
      case _IndexMenuAction.refreshCount:
        cubit.loadCount();
        break;
      case _IndexMenuAction.reindex:
        unawaited(cubit.reindex());
        break;
    }
  }
}

class _ScopeRow extends StatelessWidget {
  const _ScopeRow({required this.selected, required this.onSelected, required this.indexState});

  final SearchScope selected;
  final ValueChanged<SearchScope> onSelected;
  final SemanticIndexState indexState;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final scopeOrder = [SearchScope.both, SearchScope.saved, SearchScope.liked];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
      child: Row(
        children: [
          for (var index = 0; index < scopeOrder.length; index++) ...[
            _ScopeChip(
              label: _ScopeChips.labels[scopeOrder[index]]!,
              isSelected: selected == scopeOrder[index],
              onTap: () => onSelected(scopeOrder[index]),
            ),
            if (index < scopeOrder.length - 1) const SizedBox(width: 8),
          ],
          const Spacer(),
          Text(
            indexState.isBackfilling
                ? 'Indexing ${indexState.backfillCompleted ?? 0}/${indexState.backfillTotal ?? 0}'
                : '${indexState.indexedCount} indexed',
            style: context.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.focusNode, required this.onChanged, required this.onClear});

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return TextField(
      focusNode: focusNode,
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search saved and liked posts...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: onClear, tooltip: 'Clear')
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide(color: scheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        isDense: true,
      ),
    );
  }
}

class _ScopeChips {
  static const labels = {SearchScope.both: 'Both', SearchScope.saved: 'Saved', SearchScope.liked: 'Liked'};
}

enum _IndexMenuAction { semanticSettings, refreshCount, reindex }

class _SemanticSettingsSheet extends StatelessWidget {
  const _SemanticSettingsSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Semantic settings', style: context.textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                  'Semantic search is always enabled for saved and liked posts.',
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text('Default scope', style: context.textTheme.titleSmall),
                const SizedBox(height: 8),
                DropdownButtonFormField<SearchScope>(
                  initialValue: settingsState.searchScope,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: SearchScope.both, child: Text('Saved + Liked')),
                    DropdownMenuItem(value: SearchScope.saved, child: Text('Saved only')),
                    DropdownMenuItem(value: SearchScope.liked, child: Text('Liked only')),
                  ],
                  onChanged: (scope) async {
                    if (scope == null) return;
                    await context.read<SettingsCubit>().setSearchScope(scope);
                    if (context.mounted) {
                      await context.read<SemanticSearchCubit>().setScope(scope);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Max results', style: context.textTheme.titleSmall),
                    const Spacer(),
                    Text(
                      '${settingsState.semanticSearchMaxResults}',
                      style: context.textTheme.titleSmall?.copyWith(fontFamily: 'JetBrains Mono'),
                    ),
                  ],
                ),
                Slider(
                  value: settingsState.semanticSearchMaxResults.toDouble(),
                  min: 10,
                  max: 50,
                  divisions: 8,
                  onChanged: (v) {
                    final value = v.round();
                    context.read<SettingsCubit>().setSemanticSearchMaxResults(value);
                    context.read<SemanticSearchCubit>().setMaxResults(value);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: isSelected ? scheme.primary : scheme.outlineVariant, width: 1.5),
        ),
        child: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({required this.state});

  final SemanticSearchState state;

  @override
  Widget build(BuildContext context) => switch (state.status) {
    SemanticSearchStatus.initial => const _EmptyQueryView(),
    SemanticSearchStatus.searching => const Center(child: CircularProgressIndicator()),
    SemanticSearchStatus.loaded when state.results.isEmpty => const _NoResultsView(),
    SemanticSearchStatus.loaded => _ResultsList(results: state.results),
    SemanticSearchStatus.error => _ErrorView(message: state.errorMessage),
  };
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results});

  final List<SemanticSearchResult> results;

  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: results.length,
    itemBuilder: (context, index) {
      final result = results[index];
      return _ResultCard(result: result);
    },
  );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final SemanticSearchResult result;

  FeedViewPost? _toFeedViewPost() {
    try {
      final json = jsonDecode(result.postJson) as Map<String, dynamic>;
      if (result.source == 'liked') {
        return FeedViewPost.fromJson(json);
      }
      return FeedViewPost(post: PostView.fromJson(json));
    } catch (e) {
      log.e('Failed to deserialize semantic search result', error: e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedViewPost = _toFeedViewPost();
    final accountDid = context.read<String>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              _RelevanceBadge(score: result.score),
              const SizedBox(width: 8),
              _SourceTag(source: result.source),
            ],
          ),
        ),
        if (feedViewPost != null)
          PostCardWithActions(feedViewPost: feedViewPost, accountDid: accountDid)
        else
          _FallbackCard(postUri: result.postUri),
        const Divider(height: 1),
      ],
    );
  }
}

class _RelevanceBadge extends StatelessWidget {
  const _RelevanceBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = _colors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(
        '${score.round()}%',
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontFamily: 'JetBrains Mono',
        ),
      ),
    );
  }

  (Color, Color) _colors(BuildContext context) {
    if (score >= 75) return (Colors.green.shade700, Colors.green.shade50);
    if (score >= 50) return (Colors.orange.shade700, Colors.orange.shade50);
    return (Colors.grey.shade600, Colors.grey.shade100);
  }
}

class _SourceTag extends StatelessWidget {
  const _SourceTag({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final (icon, label) = source == 'saved' ? (Icons.bookmark_outline, 'Saved') : (Icons.favorite_outline, 'Liked');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: scheme.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(label, style: context.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _FallbackCard extends StatelessWidget {
  const _FallbackCard({required this.postUri});

  final String postUri;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.article_outlined),
    title: const Text('Post'),
    subtitle: Text(postUri, maxLines: 1, overflow: TextOverflow.ellipsis),
  );
}

class _EmptyQueryView extends StatelessWidget {
  const _EmptyQueryView();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.travel_explore_outlined, size: 64, color: scheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Search your saved & liked posts',
                    style: context.textTheme.headlineSmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find posts by handle, text, and semantic similarity',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 64, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              'No similar posts found',
              style: context.textTheme.headlineSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or a broader scope',
              style: context.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.grey),
        const SizedBox(height: 16),
        Text(message ?? 'Search failed. Please try again.'),
        const SizedBox(height: 16),
        FilledButton(onPressed: () => context.read<SemanticSearchCubit>().clearResults(), child: const Text('Clear')),
      ],
    ),
  );
}
