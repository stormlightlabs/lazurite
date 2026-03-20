import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/theme/feed_architecture.dart';
import 'package:lazurite/features/feed/presentation/home_feed_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

const double _gridSpacing = 1;
const double _gridCardChromeHeight = 160;

/// Renders a scrollable list of items in either a responsive [SliverGrid]
/// (grid architecture) or a padded [ListView] (linear architecture), driven
/// by [SettingsCubit.feedArchitecture].
///
/// [gridItemBuilder] is used when the grid architecture is active.
/// [linearItemBuilder] is used when the linear architecture is active.
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
  });

  final int itemCount;
  final IndexedWidgetBuilder gridItemBuilder;
  final IndexedWidgetBuilder linearItemBuilder;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.feedArchitecture != curr.feedArchitecture,
      builder: (context, settingsState) {
        if (settingsState.feedArchitecture == FeedArchitecture.grid) {
          return _buildGrid(context);
        }
        return _buildLinear(context);
      },
    );
  }

  Widget _buildGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = feedColumnCount(width);
    final tileWidth = (width - ((columns - 1) * _gridSpacing)) / columns;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverGrid(
            delegate: SliverChildBuilderDelegate(gridItemBuilder, childCount: itemCount),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: _gridSpacing,
              mainAxisSpacing: _gridSpacing,
              // Grid cards have a square media region plus fixed author/body/footer chrome.
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

  Widget _buildLinear(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: itemCount + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == itemCount) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
            );
          }
          return Padding(padding: const EdgeInsets.only(bottom: 8), child: linearItemBuilder(context, index));
        },
      ),
    );
  }
}
