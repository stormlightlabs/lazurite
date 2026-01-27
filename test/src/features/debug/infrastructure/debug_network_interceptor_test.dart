import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/debug/infrastructure/debug_network_interceptor.dart';
import 'package:lazurite/src/infrastructure/db/daos/dev_tools_dao.dart';
import 'package:mocktail/mocktail.dart';

class MockDevToolsDao extends Mock implements DevToolsDao {}

void main() {
  late DebugNetworkInterceptor interceptor;
  late MockDevToolsDao mockDao;
  late Dio dio;

  setUp(() {
    mockDao = MockDevToolsDao();
    interceptor = DebugNetworkInterceptor(mockDao);
    dio = Dio()..interceptors.add(interceptor);

    registerFallbackValue('');
    when(
      () => mockDao.logRequest(
        uuid: any(named: 'uuid'),
        method: any(named: 'method'),
        url: any(named: 'url'),
        statusCode: any(named: 'statusCode'),
        durationMs: any(named: 'durationMs'),
        requestHeaders: any(named: 'requestHeaders'),
        responseHeaders: any(named: 'responseHeaders'),
        requestBody: any(named: 'requestBody'),
        responseBody: any(named: 'responseBody'),
        error: any(named: 'error'),
      ),
    ).thenAnswer((_) async {});
  });

  test('logs successful request', () async {
    dio.httpClientAdapter = IOHttpClientAdapter()
      ..createHttpClient = () {
        throw 'Should not be called with mocked adapter logic? No wait, use HttpClientAdapter';
      };

    dio.httpClientAdapter = _MockAdapter(
      (options) => ResponseBody.fromString(
        '{"key":"value"}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );

    await dio.get('https://example.com/api');

    verify(
      () => mockDao.logRequest(
        uuid: any(named: 'uuid'),
        method: 'GET',
        url: 'https://example.com/api',
        statusCode: 200,
        durationMs: any(named: 'durationMs'),
        requestHeaders: any(named: 'requestHeaders'),
        responseHeaders: any(named: 'responseHeaders'),
        requestBody: any(named: 'requestBody'),
        responseBody: any(named: 'responseBody'),
      ),
    ).called(1);
  });

  test('logs error request', () async {
    dio.httpClientAdapter = _MockAdapter(
      (options) => throw DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 404, data: 'Not Found'),
        type: DioExceptionType.badResponse,
      ),
    );

    try {
      await dio.get('https://example.com/404');
    } catch (_) {}

    verify(
      () => mockDao.logRequest(
        uuid: any(named: 'uuid'),
        method: 'GET',
        url: 'https://example.com/404',
        statusCode: 404,
        durationMs: any(named: 'durationMs'),
        requestHeaders: any(named: 'requestHeaders'),
        responseHeaders: any(named: 'responseHeaders'),
        requestBody: any(named: 'requestBody'),
        responseBody: any(named: 'responseBody'),
      ),
    ).called(1);
  });
  test('redacts sensitive headers', () async {
    dio.httpClientAdapter = _MockAdapter(
      (options) => ResponseBody.fromString(
        '{}',
        200,
        headers: {
          'Authorization': ['Bearer secret-token'],
          'DPoP': ['dpop-proof'],
          'X-Custom': ['public-info'],
        },
      ),
    );

    await dio.get(
      'https://example.com/redact',
      options: Options(
        headers: {'Authorization': 'Bearer my-token', 'DPoP': 'my-proof', 'X-Other': 'safe'},
      ),
    );

    final captured = verify(
      () => mockDao.logRequest(
        uuid: any(named: 'uuid'),
        method: 'GET',
        url: 'https://example.com/redact',
        statusCode: 200,
        durationMs: any(named: 'durationMs'),
        requestHeaders: captureAny(named: 'requestHeaders'),
        responseHeaders: captureAny(named: 'responseHeaders'),
        requestBody: any(named: 'requestBody'),
        responseBody: any(named: 'responseBody'),
      ),
    ).captured;

    final requestHeaders = jsonDecode(captured[0] as String) as Map<String, dynamic>;
    final responseHeaders = jsonDecode(captured[1] as String) as Map<String, dynamic>;

    expect(requestHeaders['Authorization'], 'Bearer ***');
    expect(requestHeaders['DPoP'], 'DPoP ***');
    expect(requestHeaders['X-Other'], 'safe');

    expect(responseHeaders['Authorization'], ['Bearer ***']);
    expect(responseHeaders['DPoP'], ['DPoP ***']);
    expect(responseHeaders['X-Custom'], ['public-info']);
  });
}

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter(this.handler);

  final dynamic Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future? cancelFuture,
  ) async {
    final result = handler(options);
    if (result is ResponseBody) return result;
    throw result;
  }

  @override
  void close({bool force = false}) {}
}
