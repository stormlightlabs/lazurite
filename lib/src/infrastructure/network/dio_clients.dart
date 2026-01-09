import 'package:dio/dio.dart';

import '../auth/dpop_nonce_store.dart';
import 'interceptors/interceptors.dart';

/// The base URL for the public Bluesky AppView API.
const publicApiBaseUrl = 'https://public.api.bsky.app';

/// Creates a Dio client configured for public API access.
///
/// This client is used for unauthenticated reads like fetching profiles, threads, and
/// search results.
///
/// The [listFormat] is set to [ListFormat.multi] to serialize array query
/// parameters as repeated parameter names (e.g., ?feeds=uri1&feeds=uri2), which is
/// the format expected by AT Protocol endpoints.
Dio createPublicDio({
  SessionGetter? getSession,
  SessionRefresher? refreshSession,
  DPoPNonceStore? nonceStore,
  SessionInvalidatedCallback? onSessionInvalidated,
  bool enableLogging = true,
  List<Interceptor> interceptors = const [],
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: publicApiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      listFormat: ListFormat.multi,
    ),
  );

  dio.interceptors.addAll([
    if (getSession != null && refreshSession != null)
      AuthInterceptor(
        getSession: getSession,
        refreshSession: refreshSession,
        nonceStore: nonceStore,
        onSessionInvalidated: onSessionInvalidated,
      ),
    if (enableLogging) LoggingInterceptor(),
    ...interceptors,
    RetryInterceptor(),
  ]);

  return dio;
}

/// Creates a Dio client configured for a user's PDS.
///
/// This client is used for authenticated operations and requires the PDS URL to be provided
/// (i.e. resolved from user's DID document).
///
/// The [listFormat] is set to [ListFormat.multi] to serialize array query
/// parameters as repeated parameter names (e.g., ?feeds=uri1&feeds=uri2), which is
/// the format expected by AT Protocol endpoints.
Dio createPdsDio({
  required String pdsUrl,
  required SessionGetter getSession,
  required SessionRefresher refreshSession,
  DPoPNonceStore? nonceStore,
  SessionInvalidatedCallback? onSessionInvalidated,
  bool enableLogging = true,
  List<Interceptor> interceptors = const [],
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: pdsUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      listFormat: ListFormat.multi,
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(
      getSession: getSession,
      refreshSession: refreshSession,
      nonceStore: nonceStore,
      onSessionInvalidated: onSessionInvalidated,
    ),
    if (enableLogging) LoggingInterceptor(),
    ProxyInterceptor(),
    ...interceptors,
    RetryInterceptor(),
  ]);

  return dio;
}
