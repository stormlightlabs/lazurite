import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';

import '../../../helpers/test_bluesky_client.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('getBlackskyAiPreferenceRecord reads community lexicon preference record', () async {
    final transport = _BlackskyAiPreferenceTransport(
      getResponse: {
        'uri': 'at://did:plc:test/${FeedRepository.blackskyAiPreferenceCollection}/self',
        'value': {
          r'$type': FeedRepository.blackskyAiPreferenceCollection,
          'preferences': {
            'training': {'allow': false, 'updatedAt': '2026-01-01T00:00:00.000Z'},
          },
        },
      },
    );
    final repository = FeedRepository(
      bluesky: testBluesky(getClient: transport.get),
      database: database,
      accountDid: 'did:plc:test',
    );

    final record = await repository.getBlackskyAiPreferenceRecord();

    expect(record?[r'$type'], FeedRepository.blackskyAiPreferenceCollection);
    expect(record?['preferences'], {
      'training': {'allow': false, 'updatedAt': '2026-01-01T00:00:00.000Z'},
    });
    expect(transport.lastGet?.queryParameters['collection'], FeedRepository.blackskyAiPreferenceCollection);
    expect(transport.lastGet?.queryParameters['rkey'], FeedRepository.blackskyAiPreferenceRkey);
  });

  test('getBlackskyAiPreferenceRecord returns null when the record is missing', () async {
    final transport = _BlackskyAiPreferenceTransport(
      getStatusCode: 400,
      getResponse: {'error': 'RecordNotFound', 'message': 'Could not locate record'},
    );
    final repository = FeedRepository(
      bluesky: testBluesky(getClient: transport.get),
      database: database,
      accountDid: 'did:plc:test',
    );

    expect(await repository.getBlackskyAiPreferenceRecord(), isNull);
  });

  test('putBlackskyAiPreferenceRecord writes community lexicon preference record', () async {
    final transport = _BlackskyAiPreferenceTransport(putResponse: {'uri': 'at://did:plc:test/record', 'cid': 'cid'});
    final repository = FeedRepository(
      bluesky: testBluesky(postClient: transport.post),
      database: database,
      accountDid: 'did:plc:test',
    );

    await repository.putBlackskyAiPreferenceRecord(
      record: {r'$type': FeedRepository.blackskyAiPreferenceCollection, 'preferences': const <String, dynamic>{}},
    );

    expect(transport.lastPost?.pathSegments.last, 'com.atproto.repo.putRecord');
    expect(transport.lastBody?['repo'], 'did:plc:test');
    expect(transport.lastBody?['collection'], FeedRepository.blackskyAiPreferenceCollection);
    expect(transport.lastBody?['rkey'], FeedRepository.blackskyAiPreferenceRkey);
    expect(transport.lastBody?['record'][r'$type'], FeedRepository.blackskyAiPreferenceCollection);
  });
}

class _BlackskyAiPreferenceTransport {
  _BlackskyAiPreferenceTransport({this.getResponse, this.putResponse, this.getStatusCode = 200});

  final Map<String, dynamic>? getResponse;
  final Map<String, dynamic>? putResponse;
  final int getStatusCode;
  Uri? lastGet;
  Uri? lastPost;
  Map<String, dynamic>? lastBody;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    lastGet = url;
    if (url.pathSegments.last != 'com.atproto.repo.getRecord') {
      return unexpectedGetClient(url, headers: headers);
    }
    return jsonResponse(url, 'GET', getResponse ?? const <String, dynamic>{}, statusCode: getStatusCode);
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    lastPost = url;
    if (url.pathSegments.last != 'com.atproto.repo.putRecord') {
      return unexpectedPostClient(url, headers: headers, body: body, encoding: encoding);
    }
    lastBody = jsonDecode(body! as String) as Map<String, dynamic>;
    return jsonResponse(url, 'POST', putResponse ?? const <String, dynamic>{});
  }
}
