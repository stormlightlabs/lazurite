import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lazurite/src/infrastructure/auth/server_metadata.dart';

void main() {
  group('ServerMetadataRepository', () {
    late Dio dio;
    late DioAdapter adapter;
    late ServerMetadataRepository repository;

    setUp(() {
      dio = Dio();
      adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;
      repository = ServerMetadataRepository(dio: dio);
    });

    test('prefers shard host metadata for Bluesky PDS instances', () async {
      adapter.onGet(
        'https://foo.host.bsky.network/.well-known/oauth-authorization-server',
        (server) => server.reply(200, {
          'issuer': 'https://foo.host.bsky.network',
          'authorization_endpoint': 'https://foo.host.bsky.network/oauth/authorize',
          'token_endpoint': 'https://foo.host.bsky.network/oauth/token',
          'pushed_authorization_request_endpoint': 'https://foo.host.bsky.network/oauth/par',
        }),
      );

      final metadata = await repository.discover('https://foo.host.bsky.network');

      expect(metadata.issuer, 'https://foo.host.bsky.network');
    });

    test('falls back to bsky.social when shard metadata is unavailable', () async {
      adapter.onGet(
        'https://bar.host.bsky.network/.well-known/oauth-authorization-server',
        (server) => server.reply(404, {}),
      );

      adapter.onGet(
        'https://bsky.social/.well-known/oauth-authorization-server',
        (server) => server.reply(200, {
          'issuer': 'https://bsky.social',
          'authorization_endpoint': 'https://bsky.social/oauth/authorize',
          'token_endpoint': 'https://bsky.social/oauth/token',
          'pushed_authorization_request_endpoint': 'https://bsky.social/oauth/par',
        }),
      );

      final metadata = await repository.discover('https://bar.host.bsky.network');

      expect(metadata.issuer, 'https://bsky.social');
    });
  });
}
