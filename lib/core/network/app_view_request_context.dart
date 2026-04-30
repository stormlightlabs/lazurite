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

  String resolveProviderKey() {
    final resolver = _appViewProviderResolver;
    if (resolver == null) {
      return _appViewProvider;
    }
    return AppViewProviders.normalizeSettingKey(resolver.call());
  }

  AppViewRouter _routerForCurrentProvider() {
    final provider = AppViewProviders.descriptorForSetting(resolveProviderKey());
    return AppViewRouter(provider: provider);
  }
}
