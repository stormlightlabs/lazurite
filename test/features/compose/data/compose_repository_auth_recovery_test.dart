import 'dart:typed_data';

import 'package:poptart_core/poptart_core.dart'
    show Blob, BlobRef, HttpMethod, HttpStatus, RateLimit, UnauthorizedException, XRPCError, XRPCRequest, XRPCResponse;
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';

void main() {
  group('ComposeRepository auth recovery', () {
    test('refreshes and retries blob uploads after unauthorized response', () async {
      final initialClient = _FakeBlueskyClient(
        atproto: _FakeAtprotoService(repo: _FakeRepoService(throwUnauthorizedOnce: true)),
      );
      final refreshedClient = _FakeBlueskyClient(atproto: _FakeAtprotoService(repo: _FakeRepoService()));
      var recoveryCalls = 0;

      final repository = ComposeRepository(
        bluesky: initialClient,
        onUnauthorized: () async {
          recoveryCalls += 1;
          return const AuthTokens(
            accessToken: 'fresh-access',
            refreshToken: 'fresh-refresh',
            did: 'did:plc:test',
            handle: 'test.bsky.social',
          );
        },
        blueskyClientFactory: (_) => refreshedClient,
      );

      final blob = await repository.uploadBlobRecord([1, 2, 3], mimeType: 'image/png');

      expect(recoveryCalls, 1);
      expect(initialClient.atproto.repo.uploadAttempts, 1);
      expect(refreshedClient.atproto.repo.uploadAttempts, 1);
      expect(blob, isNotNull);
      expect(blob!.mimeType, 'image/png');
      expect(blob.size, 3);
      expect(refreshedClient.atproto.repo.lastUploadedBytes, [1, 2, 3]);
      expect(refreshedClient.atproto.repo.lastUploadHeaders, {'Content-Type': 'image/png'});
    });
  });
}

class _FakeBlueskyClient {
  const _FakeBlueskyClient({required this.atproto});

  final _FakeAtprotoService atproto;
}

class _FakeAtprotoService {
  const _FakeAtprotoService({required this.repo});

  final _FakeRepoService repo;
}

class _FakeRepoService {
  _FakeRepoService({this.throwUnauthorizedOnce = false});

  final bool throwUnauthorizedOnce;
  int uploadAttempts = 0;
  List<int>? lastUploadedBytes;
  Map<String, String>? lastUploadHeaders;

  Future<_FakeResponse<_FakeUploadBlobData>> uploadBlob({
    required Uint8List bytes,
    Map<String, String>? $headers,
  }) async {
    uploadAttempts += 1;
    if (throwUnauthorizedOnce && uploadAttempts == 1) {
      throw _unauthorizedException();
    }

    lastUploadedBytes = bytes.toList();
    lastUploadHeaders = $headers;
    return _FakeResponse(
      _FakeUploadBlobData(
        Blob(
          mimeType: $headers?['Content-Type'] ?? 'image/jpeg',
          size: bytes.length,
          ref: const BlobRef(link: 'bafkreirefreshed'),
        ),
      ),
    );
  }
}

class _FakeResponse<T> {
  const _FakeResponse(this.data);

  final T data;
}

class _FakeUploadBlobData {
  const _FakeUploadBlobData(this.blob);

  final Blob blob;
}

UnauthorizedException _unauthorizedException() {
  return UnauthorizedException(
    XRPCResponse<XRPCError>(
      headers: const {},
      status: HttpStatus.unauthorized,
      request: XRPCRequest(
        method: HttpMethod.post,
        url: Uri.parse('https://example.com/xrpc/com.atproto.repo.uploadBlob'),
      ),
      rateLimit: RateLimit.unlimited(),
      data: const XRPCError(error: 'Unauthorized', message: '"exp" claim timestamp check failed'),
    ),
  );
}
