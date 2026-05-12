import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:poptart_core/poptart_core.dart' show Blob, BlobRef;
import 'package:poptart_lex/com/atproto/repo/upload_blob.dart';

import '../../../helpers/test_bluesky_client.dart';

void main() {
  group('ComposeRepository auth recovery', () {
    test('refreshes and retries blob uploads after unauthorized response', () async {
      final initialTransport = _UploadBlobTransport(throwUnauthorizedOnce: true);
      final refreshedTransport = _UploadBlobTransport();
      final initialClient = testBluesky(postClient: initialTransport.post);
      final refreshedClient = testBluesky(postClient: refreshedTransport.post);
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
      expect(initialTransport.uploadAttempts, 1);
      expect(refreshedTransport.uploadAttempts, 1);
      expect(blob, isNotNull);
      expect(blob!.mimeType, 'image/png');
      expect(blob.size, 3);
      expect(refreshedTransport.lastUploadedBytes, [1, 2, 3]);
      expect(refreshedTransport.lastUploadHeaders, containsPair('Content-Type', 'image/png'));
    });
  });
}

class _UploadBlobTransport {
  _UploadBlobTransport({this.throwUnauthorizedOnce = false});

  final bool throwUnauthorizedOnce;
  int uploadAttempts = 0;
  List<int>? lastUploadedBytes;
  Map<String, String>? lastUploadHeaders;

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    if (url.pathSegments.last != 'com.atproto.repo.uploadBlob') {
      return unexpectedPostClient(url, headers: headers, body: body, encoding: encoding);
    }

    uploadAttempts += 1;
    if (throwUnauthorizedOnce && uploadAttempts == 1) {
      return jsonResponse(url, 'POST', const {
        'error': 'Unauthorized',
        'message': '"exp" claim timestamp check failed',
      }, statusCode: 401);
    }

    final bytes = Uint8List.fromList((body as List<int>?) ?? const []);
    lastUploadedBytes = bytes.toList();
    lastUploadHeaders = headers;
    return jsonResponse(
      url,
      'POST',
      RepoUploadBlobOutput(
        blob: Blob(
          mimeType: headers?['Content-Type'] ?? 'image/jpeg',
          size: bytes.length,
          ref: const BlobRef(link: 'bafkreirefreshed'),
        ),
      ).toJson(),
    );
  }
}
