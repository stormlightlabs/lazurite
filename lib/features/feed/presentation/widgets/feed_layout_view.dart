import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/ads/ad_helper.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/ads/presentation/ad_slot.dart';
import 'package:lazurite/features/feed/presentation/home_feed_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

const double _gridSpacing = 1;
const double _gridCardChromeHeight = 160;

/// Renders a scrollable list of items in either a responsive [SliverGrid]
/// (card layout) or a padded [ListView] (compact layout), driven
/// by [SettingsCubit.feedLayout].
///
/// [gridItemBuilder] is used when the card layout is active.
/// [linearItemBuilder] is used when the compact layout is active.
/// This allows the caller to render the appropriate card variant for each mode.
///
/// When [adsRemoved] is false on [SettingsCubit], native ad slots are injected
/// automatically every [AdHelper.adInterval] posts, deferred by [adOffset].
class FeedLayoutView extends StatelessWidget {
  const FeedLayoutView({
    super.key,
    required this.itemCount,
    required this.gridItemBuilder,
    required this.linearItemBuilder,
    required this.scrollController,
    required this.isLoadingMore,
    required this.onRefresh,
    this.adOffset = 0,
  });

  final int itemCount;
  final IndexedWidgetBuilder gridItemBuilder;
  final IndexedWidgetBuilder linearItemBuilder;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final RefreshCallback onRefresh;

  /// Visual items before the first ad slot. Set to [AdHelper.profileAdOffset]
  ///
  /// For profile post tabs, leave at 0 for feeds.
  final int adOffset;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.feedLayout != curr.feedLayout || prev.adsRemoved != curr.adsRemoved,
      builder: (context, settingsState) {
        final adsRemoved = settingsState.adsRemoved;
        final effectiveCount = adsRemoved ? itemCount : AdHelper.visualItemCount(itemCount, offset: adOffset);

        final wrappedGrid = adsRemoved
            ? gridItemBuilder
            : (ctx, vi) {
                final di = AdHelper.dataIndexForVisualIndex(vi, offset: adOffset);
                return di != null ? gridItemBuilder(ctx, di) : AdSlot(key: ValueKey('ad_slot_$vi'), slotIndex: vi);
              };

        final wrappedLinear = adsRemoved
            ? linearItemBuilder
            : (ctx, vi) {
                final di = AdHelper.dataIndexForVisualIndex(vi, offset: adOffset);
                return di != null
                    ? linearItemBuilder(ctx, di)
                    : AdSlot(key: ValueKey('ad_slot_$vi'), slotIndex: vi, isLinear: true);
              };

        if (settingsState.feedLayout == FeedLayout.card) {
          return _buildGrid(context, effectiveCount, wrappedGrid);
        }
        return _buildLinear(context, effectiveCount, wrappedLinear);
      },
    );
  }

  Widget _buildGrid(BuildContext context, int count, IndexedWidgetBuilder builder) {
    final width = MediaQuery.of(context).size.width;
    final columns = feedColumnCount(width);
    if (columns == 1) {
      return _buildSingleColumnGrid(context, count, builder);
    }
    final tileWidth = (width - ((columns - 1) * _gridSpacing)) / columns;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverGrid(
            delegate: SliverChildBuilderDelegate(builder, childCount: count),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: _gridSpacing,
              mainAxisSpacing: _gridSpacing,
              mainAxisExtent: tileWidth + _gridCardChromeHeight,
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

  Widget _buildSingleColumnGrid(BuildContext context, int count, IndexedWidgetBuilder builder) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            sliver: SliverList.separated(
              itemCount: count,
              itemBuilder: builder,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
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

  Widget _buildLinear(BuildContext context, int count, IndexedWidgetBuilder builder) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: count + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == count) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
            );
          }
          return Padding(padding: const EdgeInsets.only(bottom: 4), child: builder(context, index));
        },
      ),
    );
  }
}
