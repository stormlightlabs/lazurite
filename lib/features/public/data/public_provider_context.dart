import 'package:lazurite/core/network/app_view_provider.dart';

class PublicProviderContext {
  const PublicProviderContext({required this.providerKey});

  final String providerKey;

  static PublicProviderContext fromRoute({String? pathProvider, String? queryProvider, String? fallbackProvider}) {
    final query = _supportedOrNull(queryProvider);
    if (query != null) {
      return PublicProviderContext(providerKey: query);
    }

    final path = _supportedOrNull(pathProvider);
    if (path != null) {
      return PublicProviderContext(providerKey: path);
    }

    return PublicProviderContext(providerKey: AppViewProviders.normalizeSettingKey(fallbackProvider));
  }

  Uri appendTo(Uri uri) {
    final query = Map<String, String>.from(uri.queryParameters);
    query['provider'] = providerKey;
    return uri.replace(queryParameters: query);
  }

  static String? _supportedOrNull(String? rawProvider) {
    final normalized = rawProvider?.trim().toLowerCase();
    if (normalized == null || !AppViewProviders.supportedKeys.contains(normalized)) {
      return null;
    }
    return normalized;
  }
}
