import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dio_clients.dart';
import 'xrpc_client.dart';

part 'providers.g.dart';

/// Provides the public Dio client for unauthenticated API access.
///
/// This client is configured for the public AppView at public.api.bsky.app.
@Riverpod(keepAlive: true)
Dio dioPublic(Ref ref) {
  return createPublicDio();
}

/// Provides the PDS Dio client for authenticated API access.
///
/// This requires a logged-in user with a resolved PDS URL.
/// Returns null if no user is logged in.
@Riverpod(keepAlive: true)
Dio? dioPds(Ref ref) {
  // TODO: Implement session provider and wire up here
  // final session = ref.watch(sessionProvider);
  // if (session == null) return null;
  // return createPdsDio(
  //   pdsUrl: session.pdsUrl,
  //   getAccessToken: () async => session.accessToken,
  //   refreshToken: () async {
  //     // Trigger refresh and return new token
  //     await ref.read(sessionProvider.notifier).refresh();
  //     return ref.read(sessionProvider)?.accessToken;
  //   },
  // );
  return null;
}

/// Provides the XRPC client for making API requests.
///
/// This client automatically routes requests to the correct host
/// based on endpoint metadata in the registry.
@Riverpod(keepAlive: true)
XrpcClient xrpcClient(Ref ref) {
  return XrpcClient(publicDio: ref.watch(dioPublicProvider), pdsDio: ref.watch(dioPdsProvider));
}
