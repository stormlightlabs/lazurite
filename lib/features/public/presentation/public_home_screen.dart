import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/public/presentation/public_route_state.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key, required this.providerKey, required this.contentTab});

  final String providerKey;
  final PublicContentTab contentTab;

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeProviderIndex = _providerIndex(widget.providerKey);
    final activeContentIndex = widget.contentTab.index;
    final activeIndex = activeProviderIndex * PublicContentTab.values.length + activeContentIndex;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/logo.svg',
                  height: 48,
                  colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.appTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.labelRoamTheAtmosphere,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  key: const ValueKey<String>('public-provider-switch'),
                  segments: const [
                    ButtonSegment<String>(
                      value: AppViewProviders.blueskyKey,
                      label: _ProviderLabel(assetPath: 'assets/bluesky.svg', name: 'BlueSky'),
                    ),
                    ButtonSegment<String>(
                      value: AppViewProviders.blackskyKey,
                      label: _ProviderLabel(assetPath: 'assets/blacksky.svg', name: 'BlackSky'),
                    ),
                  ],
                  selected: {widget.providerKey},
                  onSelectionChanged: (selection) => _go(context, providerKey: selection.first),
                ),
                const SizedBox(height: 12),
                SegmentedButton<PublicContentTab>(
                  key: const ValueKey<String>('public-content-switch'),
                  segments: [
                    ButtonSegment<PublicContentTab>(
                      value: PublicContentTab.discover,
                      label: Text(widget.providerKey == AppViewProviders.blackskyKey ? 'Trending' : 'Discover'),
                    ),
                    const ButtonSegment<PublicContentTab>(value: PublicContentTab.feeds, label: Text('Feeds')),
                  ],
                  selected: {widget.contentTab},
                  onSelectionChanged: (selection) => _go(context, contentTab: selection.first),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: PageStorage(
              bucket: _bucket,
              child: IndexedStack(
                key: const ValueKey<String>('public-home-indexed-stack'),
                index: activeIndex,
                children: const [
                  _PublicTabList(providerKey: AppViewProviders.blueskyKey, contentTab: PublicContentTab.discover),
                  _PublicTabList(providerKey: AppViewProviders.blueskyKey, contentTab: PublicContentTab.feeds),
                  _PublicTabList(providerKey: AppViewProviders.blackskyKey, contentTab: PublicContentTab.discover),
                  _PublicTabList(providerKey: AppViewProviders.blackskyKey, contentTab: PublicContentTab.feeds),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _providerIndex(String providerKey) => providerKey == AppViewProviders.blackskyKey ? 1 : 0;

  void _go(BuildContext context, {String? providerKey, PublicContentTab? contentTab}) {
    final route = PublicRouteState(
      providerKey: providerKey ?? widget.providerKey,
      contentTab: contentTab ?? widget.contentTab,
    );
    context.go(route.location);
  }
}

class _ProviderLabel extends StatelessWidget {
  const _ProviderLabel({required this.assetPath, required this.name});

  static const _blackSkyAssetPath = 'assets/blacksky.svg';
  static const _blackSkyDarkModeColor = Color(0xFF6868B6);

  final String assetPath;
  final String name;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SvgPicture.asset(
        assetPath,
        height: 16,
        colorFilter: assetPath == _blackSkyAssetPath && Theme.of(context).brightness == Brightness.dark
            ? const ColorFilter.mode(_blackSkyDarkModeColor, BlendMode.srcIn)
            : null,
      ),
      const SizedBox(width: 8),
      Text(name),
    ],
  );
}

class _PublicTabList extends StatelessWidget {
  const _PublicTabList({required this.providerKey, required this.contentTab});

  final String providerKey;
  final PublicContentTab contentTab;

  @override
  Widget build(BuildContext context) {
    final providerName = providerKey == AppViewProviders.blackskyKey ? 'BlackSky' : 'BlueSky';
    final label = contentTab == PublicContentTab.feeds
        ? '$providerName Feeds'
        : providerKey == AppViewProviders.blackskyKey
        ? '$providerName Trending'
        : '$providerName Discover';
    return ListView.builder(
      key: PageStorageKey<String>('public-$providerKey-${contentTab.routeValue}-scroll'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 36,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _PublicSectionHeader(label: label);
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            key: ValueKey<String>('public-$providerKey-${contentTab.routeValue}-item-$index'),
            leading: Icon(contentTab == PublicContentTab.feeds ? Icons.rss_feed : Icons.public),
            title: Text('$label item $index'),
            subtitle: const Text('Public browsing preview'),
          ),
        );
      },
    );
  }
}

class _PublicSectionHeader extends StatelessWidget {
  const _PublicSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}
