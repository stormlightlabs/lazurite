import 'package:dio/dio.dart';

import 'interceptors/interceptors.dart';

/// The base URL for the public Bluesky AppView API.
const publicApiBaseUrl = 'https://public.api.bsky.app';

/// Creates a Dio client configured for public API access.
///
/// This client is used for unauthenticated reads like fetching profiles,
/// threads, and search results.
Dio createPublicDio({bool enableLogging = true}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: publicApiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([if (enableLogging) LoggingInterceptor(), RetryInterceptor()]);

  return dio;
}

/// Creates a Dio client configured for a user's PDS.
///
/// This client is used for authenticated operations and requires the PDS URL to
/// be provided (i.e. resolved from user's DID document).
Dio createPdsDio({
  required String pdsUrl,
  required TokenGetter getAccessToken,
  required TokenRefresher refreshToken,
  bool enableLogging = true,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: pdsUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    if (enableLogging) LoggingInterceptor(),
    AuthInterceptor(getAccessToken: getAccessToken, refreshToken: refreshToken),
    ProxyInterceptor(),
    RetryInterceptor(),
  ]);

  return dio;
}
