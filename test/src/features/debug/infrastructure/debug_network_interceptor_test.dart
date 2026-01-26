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
