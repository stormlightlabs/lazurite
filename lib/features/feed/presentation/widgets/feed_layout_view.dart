import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/shared/presentation/widgets/animated_refresh_indicator.dart';

/// Renders a scrollable list of items in either a padded [ListView]
/// (card layout) or a compact-styled [ListView] (compact layout), driven
/// by [SettingsCubit.feedLayout].
///
/// [linearItemBuilder] is used when the card layout is active.
/// [gridItemBuilder] is used when the compact layout is active.
/// This allows the caller to render the appropriate card variant for each mode.
class FeedLayoutView extends StatelessWidget {
  const FeedLayoutView({
    super.key,
    required this.itemCount,
    required this.gridItemBuilder,
    required this.linearItemBuilder,
    required this.scrollController,
    required this.isLoadingMore,
    required this.onRefresh,
    this.itemKeyBuilder,
    this.storageKey,
  });

  final int itemCount;
  final IndexedWidgetBuilder gridItemBuilder;
  final IndexedWidgetBuilder linearItemBuilder;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final RefreshCallback onRefresh;
  final Key? Function(int index)? itemKeyBuilder;
  final PageStorageKey<String>? storageKey;

  @override
  Widget build(BuildContext context) => BlocBuilder<SettingsCubit, SettingsState>(
    buildWhen: (prev, curr) => prev.feedLayout != curr.feedLayout,
    builder: (context, settingsState) {
      if (settingsState.feedLayout == FeedLayout.compact) {
        return _buildCompact(context);
      }
      return _buildCard(context);
    },
  );

  Widget _buildCompact(BuildContext context) {
    return AnimatedRefreshIndicator(
      onRefresh: onRefresh,
      showCornerSpinner: false,
      child: CustomScrollView(
        key: storageKey,
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            sliver: SliverList.separated(
              itemCount: itemCount,
              itemBuilder: (context, index) => _buildListItem(context, index, gridItemBuilder),
              separatorBuilder: (_, _) => const SizedBox(height: 2),
            ),
          ),
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return AnimatedRefreshIndicator(
      onRefresh: onRefresh,
      showCornerSpinner: false,
      child: ListView.builder(
        key: storageKey,
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: itemCount + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == itemCount) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
            );
          }
          return _buildListItem(
            context,
            index,
            (context, index) =>
                Padding(padding: const EdgeInsets.only(bottom: 4), child: linearItemBuilder(context, index)),
          );
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index, IndexedWidgetBuilder builder) {
    final child = RepaintBoundary(child: builder(context, index));
    final key = itemKeyBuilder?.call(index);
    if (key == null) {
      return child;
    }
    return KeyedSubtree(key: key, child: child);
  }
}
