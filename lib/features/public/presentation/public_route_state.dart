import 'package:lazurite/core/network/app_view_provider.dart';

enum PublicContentTab {
  discover('discover'),
  feeds('feeds');

  const PublicContentTab(this.routeValue);

  final String routeValue;

  static PublicContentTab fromRouteValue(String? rawValue) {
    final normalized = rawValue?.trim().toLowerCase();
    return PublicContentTab.values.firstWhere(
      (tab) => tab.routeValue == normalized,
      orElse: () => PublicContentTab.discover,
    );
  }
}

class PublicRouteState {
  const PublicRouteState({required this.providerKey, required this.contentTab});

  final String providerKey;
  final PublicContentTab contentTab;

  String get location => '/public/$providerKey/${contentTab.routeValue}';

  static PublicRouteState parse({required String? provider, required String? tab}) {
    return PublicRouteState(providerKey: normalizeProvider(provider), contentTab: PublicContentTab.fromRouteValue(tab));
  }

  static String normalizeProvider(String? rawProvider) => AppViewProviders.normalizeSettingKey(rawProvider);

  static bool isSupportedProvider(String? rawProvider) {
    final normalized = rawProvider?.trim().toLowerCase();
    return normalized != null && AppViewProviders.supportedKeys.contains(normalized);
  }
}
