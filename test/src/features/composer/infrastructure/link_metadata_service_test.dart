import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/composer/infrastructure/link_metadata_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockLogger extends Mock implements Logger {}

void main() {
  group('LinkMetadataService', () {
    late MockDio mockDio;
    late MockLogger mockLogger;
    late LinkMetadataService service;

    setUp(() {
      mockDio = MockDio();
      mockLogger = MockLogger();
      service = LinkMetadataService(dio: mockDio, logger: mockLogger);
    });

    test('parses Open Graph metadata from HTML', () async {
      const url = 'https://example.com';
      const html = '''
        <html>
          <head>
            <meta property="og:title" content="Example Title" />
            <meta property="og:description" content="Example Description" />
            <meta property="og:image" content="https://example.com/image.jpg" />
            <meta property="og:site_name" content="Example Site" />
          </head>
        </html>
      ''';

      when(() => mockDio.get<String>(url, options: any(named: 'options'))).thenAnswer(
        (_) async => Response<String>(
          data: html,
          statusCode: 200,
          requestOptions: RequestOptions(path: url),
        ),
      );

      final metadata = await service.fetchMetadata(url);

      expect(metadata, isNotNull);
      expect(metadata!.url, equals(url));
      expect(metadata.title, equals('Example Title'));
      expect(metadata.description, equals('Example Description'));
      expect(metadata.imageUrl, equals('https://example.com/image.jpg'));
      expect(metadata.siteName, equals('Example Site'));
    });

    test('falls back to standard HTML tags when Open Graph tags missing', () async {
      const url = 'https://example.com';
      const html = '''
        <html>
          <head>
            <title>Fallback Title</title>
            <meta name="description" content="Fallback Description" />
          </head>
        </html>
      ''';

      when(() => mockDio.get<String>(url, options: any(named: 'options'))).thenAnswer(
        (_) async => Response<String>(
          data: html,
          statusCode: 200,
          requestOptions: RequestOptions(path: url),
        ),
      );

      final metadata = await service.fetchMetadata(url);

      expect(metadata, isNotNull);
      expect(metadata!.title, equals('Fallback Title'));
      expect(metadata.description, equals('Fallback Description'));
    });

    test('normalizes URL by adding https:// if missing', () async {
      const url = 'example.com';
      const normalizedUrl = 'https://example.com';
      const html = '<html><head><title>Test</title></head></html>';

      when(() => mockDio.get<String>(normalizedUrl, options: any(named: 'options'))).thenAnswer(
        (_) async => Response<String>(
          data: html,
          statusCode: 200,
          requestOptions: RequestOptions(path: normalizedUrl),
        ),
      );

      final metadata = await service.fetchMetadata(url);

      expect(metadata, isNotNull);
      expect(metadata!.url, equals(normalizedUrl));
      verify(() => mockDio.get<String>(normalizedUrl, options: any(named: 'options'))).called(1);
    });

    test('returns null for invalid URLs', () async {
      const url = ':::invalid:::';

      final metadata = await service.fetchMetadata(url);

      expect(metadata, isNull);
      verifyNever(() => mockDio.get<String>(any(), options: any(named: 'options')));
    });

    test('returns null when network request fails', () async {
      const url = 'https://example.com';

      when(() => mockDio.get<String>(url, options: any(named: 'options'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: url),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final metadata = await service.fetchMetadata(url);

      expect(metadata, isNull);
      verify(() => mockLogger.warning(any(), any())).called(1);
    });

    test('returns null for empty response', () async {
      const url = 'https://example.com';

      when(() => mockDio.get<String>(url, options: any(named: 'options'))).thenAnswer(
        (_) async => Response<String>(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: url),
        ),
      );

      final metadata = await service.fetchMetadata(url);

      expect(metadata, isNull);
    });

    test('hasContent returns true when metadata has title, description, or image', () async {
      const url = 'https://example.com';
      const html = '<html><head><title>Test</title></head></html>';

      when(() => mockDio.get<String>(url, options: any(named: 'options'))).thenAnswer(
        (_) async => Response<String>(
          data: html,
          statusCode: 200,
          requestOptions: RequestOptions(path: url),
        ),
      );

      final metadata = await service.fetchMetadata(url);

      expect(metadata, isNotNull);
      expect(metadata!.hasContent, isTrue);
    });
  });
}
