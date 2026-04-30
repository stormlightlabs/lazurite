import 'package:lazurite/core/network/app_bsky_routing_policy.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_router.dart';

class AppViewRequestContext {
  AppViewRequestContext({String? appViewProvider, String Function()? appViewProviderResolver})
    : _appViewProvider = AppViewProviders.normalizeSettingKey(appViewProvider),
      _appViewProviderResolver = appViewProviderResolver;

  final String _appViewProvider;
  final String Function()? _appViewProviderResolver;

  String publicServiceHost() => _routerForCurrentProvider().provider.publicBaseUrl.host;

  Map<String, String> appBskyHeaders([Map<String, String>? baseHeaders]) {
    final merged = <String, String>{...?baseHeaders};
    merged.addAll(_routerForCurrentProvider().appBskyProxyHeaders());
    return merged;
  }

  /// App headers for the given lexicon endpoint using the centralized AppView proxy policy map.
  Map<String, String> appBskyHeadersForEndpoint(String endpointId, [Map<String, String>? baseHeaders]) {
    if (AppBskyRoutingPolicy.shouldUseProxy(endpointId)) {
      return appBskyHeaders(baseHeaders);
    }
    return appBskyHeadersWithoutProxy(baseHeaders);
  }

  /// App headers with any AppView proxy override removed.
  ///
  /// Use this for endpoints that should remain PDS-routed and not be forced
  /// through an explicit AppView DID proxy.
  Map<String, String> appBskyHeadersWithoutProxy([Map<String, String>? baseHeaders]) {
    final headers = <String, String>{...?baseHeaders};
    headers.removeWhere((key, _) => key.toLowerCase() == 'atproto-proxy');
    return headers;
  }

  String resolveProviderKey() {
    final resolver = _appViewProviderResolver;
    if (resolver == null) {
      return _appViewProvider;
    }
    return AppViewProviders.normalizeSettingKey(resolver.call());
  }

  AppViewRouter _routerForCurrentProvider() {
    return AppViewRouter(provider: AppViewProviders.descriptorForSetting(resolveProviderKey()));
  }
}
