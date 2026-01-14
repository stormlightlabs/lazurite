import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/domain/tenor_gif.dart';
import 'package:lazurite/src/features/composer/infrastructure/tenor_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  test('TenorService can be created', () {
    final service = TenorService(apiKey: 'test-api-key', clientKey: 'test-client');

    expect(service, isA<TenorService>());
  });

  test('TenorGif parses complete object', () {
    final json = {
      'id': 'gif-123',
      'title': 'Funny Cat',
      'media_formats': {
        'gif': {
          'url': 'https://media.tenor.com/full.gif',
          'preview': 'https://media.tenor.com/preview.gif',
          'dims': {'width': 500, 'height': 500},
          'size': 1000000,
          'preview_size': 50000,
        },
      },
      'created': 1640000000,
      'tags': ['cat', 'funny'],
      'flags': ['trending'],
      'hasaudio': false,
    };

    final gif = TenorGif.fromJson(json);

    expect(gif.id, 'gif-123');
    expect(gif.title, 'Funny Cat');
    expect(gif.created, DateTime.fromMillisecondsSinceEpoch(1640000000000));
    expect(gif.tags, ['cat', 'funny']);
    expect(gif.flags, ['trending']);
    expect(gif.hasaudio, isFalse);
    expect(gif.mediaFormats, hasLength(1));
  });

  test('TenorMedia parses complete object', () {
    final json = {
      'url': 'https://example.com/full.gif',
      'preview': 'https://example.com/preview.gif',
      'dims': {'width': 500, 'height': 500},
      'size': 1000000,
      'preview_size': 50000,
    };

    final media = TenorMedia.fromJson(json);

    expect(media.url, 'https://example.com/full.gif');
    expect(media.previewUrl, 'https://example.com/preview.gif');
    expect(media.dims.width, 500);
    expect(media.dims.height, 500);
    expect(media.size, 1000000);
    expect(media.previewSize, 50000);
  });

  test('TenorSearchResponse parses complete object', () {
    final json = {
      'results': [
        {
          'id': 'gif-1',
          'title': 'GIF 1',
          'media_formats': {
            'mediumgif': {
              'url': 'https://example.com/1.gif',
              'dims': {'width': 400, 'height': 400},
            },
          },
        },
      ],
      'next': 'next-token-123',
    };

    final response = TenorSearchResponse.fromJson(json);

    expect(response.results, hasLength(1));
    expect(response.results.first.id, 'gif-1');
    expect(response.next, 'next-token-123');
  });

  group('TenorGif thumbnailUrl helpers', () {
    test('gets from tinygif', () {
      final json = {
        'id': 'gif-789',
        'title': 'Test',
        'media_formats': {
          'tinygif': {'preview': 'https://example.com/preview.gif'},
        },
      };

      final gif = TenorGif.fromJson(json);
      expect(gif.thumbnailUrl, 'https://example.com/preview.gif');
    });

    test('gets from mediumgif when tiny not available', () {
      final json = {
        'id': 'gif-789',
        'title': 'Test',
        'media_formats': {
          'mediumgif': {'preview': 'https://example.com/medium-preview.gif'},
        },
      };

      final gif = TenorGif.fromJson(json);
      expect(gif.thumbnailUrl, 'https://example.com/medium-preview.gif');
    });

    test('returns null when no previews', () {
      final json = {
        'id': 'gif-789',
        'title': 'Test',
        'media_formats': {
          'gif': {'url': 'https://example.com/gif.gif'},
        },
      };

      final gif = TenorGif.fromJson(json);
      expect(gif.thumbnailUrl, equals(null));
    });
  });

  group('TenorGif gifUrl helpers', () {
    test('gets from mediumgif', () {
      final json = {
        'id': 'gif-789',
        'title': 'Test',
        'media_formats': {
          'mediumgif': {'url': 'https://example.com/medium.gif'},
        },
      };

      final gif = TenorGif.fromJson(json);

      expect(gif.gifUrl, 'https://example.com/medium.gif');
    });

    test('gets from gif when medium not available', () {
      final json = {
        'id': 'gif-789',
        'title': 'Test',
        'media_formats': {
          'gif': {'url': 'https://example.com/gif.gif'},
        },
      };

      final gif = TenorGif.fromJson(json);

      expect(gif.gifUrl, 'https://example.com/gif.gif');
    });

    test('returns null when neither format available', () {
      final json = {'id': 'gif-789', 'title': 'Test', 'media_formats': {}};

      final gif = TenorGif.fromJson(json);

      expect(gif.gifUrl, equals(null));
    });
  });

  group('TenorService', () {
    late MockDio mockDio;
    late TenorService service;

    setUp(() {
      mockDio = MockDio();
      service = TenorService(apiKey: 'test-api-key', clientKey: 'test-client', dio: mockDio);
    });

    test('searchGifs returns correct results', () async {
      final responseJson = {
        'results': [
          {'id': 'gif-1', 'title': 'Test GIF', 'media_formats': {}},
        ],
      };

      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/search',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: responseJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/search'),
        ),
      );

      final response = await service.searchGifs(query: 'funny cats');

      expect(response.results, hasLength(1));
      expect(response.results.first.id, 'gif-1');
    });

    test('searchGifs respects pagination', () async {
      final responseJson = {'results': [], 'next': 'token-123'};

      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/search',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: responseJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/search'),
        ),
      );

      final response = await service.searchGifs(query: 'test', pos: 'token-123');

      expect(response.next, 'token-123');
    });

    test('getFeaturedGifs returns correct results', () async {
      final responseJson = {
        'results': [
          {'id': 'featured-1', 'title': 'Featured GIF', 'media_formats': {}},
        ],
      };

      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/featured',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: responseJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/featured'),
        ),
      );

      final response = await service.getFeaturedGifs();

      expect(response.results, hasLength(1));
      expect(response.results.first.id, 'featured-1');
    });

    test('downloadThumbnail downloads and saves file', () async {
      final bytes = [1, 2, 3, 4, 5];

      when(
        () => mockDio.get<List<int>>(
          'https://example.com/thumb.jpg',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<List<int>>(
          data: bytes,
          statusCode: 200,
          requestOptions: RequestOptions(path: 'https://example.com/thumb.jpg'),
        ),
      );

      final file = await service.downloadThumbnail('https://example.com/thumb.jpg');

      expect(file.existsSync(), isTrue);
      final readBytes = await file.readAsBytes();
      expect(readBytes, bytes);

      await file.delete();
    });

    test('downloadThumbnail throws exception on empty response', () async {
      when(
        () => mockDio.get<List<int>>(
          'https://example.com/thumb.jpg',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<List<int>>(
          data: [],
          statusCode: 200,
          requestOptions: RequestOptions(path: 'https://example.com/thumb.jpg'),
        ),
      );

      expect(
        () => service.downloadThumbnail('https://example.com/thumb.jpg'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
