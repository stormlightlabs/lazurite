class AppViewProviderDescriptor {
  const AppViewProviderDescriptor({
    required this.key,
    required this.serviceDid,
    required this.publicBaseUrl,
    required this.entrywayUrl,
    required this.webBaseUrl,
  });

  final String key;
  final String serviceDid;
  final Uri publicBaseUrl;
  final Uri entrywayUrl;
  final Uri webBaseUrl;
}

abstract final class AppViewProviders {
  static const String blueskyKey = 'bluesky';
  static const String blackskyKey = 'blacksky';
  static const String defaultKey = blueskyKey;
  static const Set<String> supportedKeys = {blueskyKey, blackskyKey};

  static final AppViewProviderDescriptor bluesky = AppViewProviderDescriptor(
    key: blueskyKey,
    serviceDid: 'did:web:api.bsky.app#bsky_appview',
    publicBaseUrl: Uri.https('public.api.bsky.app'),
    entrywayUrl: Uri.https('bsky.social'),
    webBaseUrl: Uri.https('bsky.app'),
  );

  static final AppViewProviderDescriptor blacksky = AppViewProviderDescriptor(
    key: blackskyKey,
    serviceDid: 'did:web:api.blacksky.community#bsky_appview',
    publicBaseUrl: Uri.https('api.blacksky.community'),
    entrywayUrl: Uri.https('blacksky.app'),
    webBaseUrl: Uri.https('blacksky.app'),
  );

  static final Map<String, AppViewProviderDescriptor> _builtIns = {blueskyKey: bluesky, blackskyKey: blacksky};

  static String normalizeSettingKey(String? rawKey) {
    final normalized = rawKey?.trim().toLowerCase();
    if (normalized == null || !supportedKeys.contains(normalized)) {
      return defaultKey;
    }
    return normalized;
  }

  static AppViewProviderDescriptor descriptorForSetting(String? rawKey) {
    final normalizedKey = normalizeSettingKey(rawKey);
    return _builtIns[normalizedKey] ?? bluesky;
  }
}
