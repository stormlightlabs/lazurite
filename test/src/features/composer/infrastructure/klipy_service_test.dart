import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/domain/klipy_gif.dart';
import 'package:lazurite/src/features/composer/infrastructure/klipy_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  test('KlipyService can be created', () {
    final service = KlipyService(apiKey: 'test-api-key');

    expect(service, isA<KlipyService>());
  });

  test('KlipyGif parses complete object', () {
    final Map<String, dynamic> json = {
      'id': 123,
      'slug': 'funny-cat-abc123',
      'title': 'Funny Cat',
      'file': {
        'hd': {
          'gif': {'url': 'https://media.klipy.com/hd.gif', 'width': 1920, 'height': 1080},
          'webp': {'url': 'https://media.klipy.com/hd.webp', 'width': 1920, 'height': 1080},
        },
        'md': {
          'gif': {'url': 'https://media.klipy.com/md.gif', 'width': 640, 'height': 360},
        },
        'sm': {
          'gif': {'url': 'https://media.klipy.com/sm.gif', 'width': 320, 'height': 180},
          'webp': {'url': 'https://media.klipy.com/sm.webp', 'width': 320, 'height': 180},
        },
      },
      'tags': ['cat', 'funny'],
      'type': 'gif',
      'blur_preview': 'base64encodeddata',
    };

    final gif = KlipyGif.fromJson(json);

    expect(gif.id, 123);
    expect(gif.slug, 'funny-cat-abc123');
    expect(gif.title, 'Funny Cat');
    expect(gif.tags, ['cat', 'funny']);
    expect(gif.type, 'gif');
    expect(gif.blurPreview, 'base64encodeddata');
  });

  test('KlipyMediaFormat parses complete object', () {
    final json = {
      'url': 'https://example.com/full.gif',
      'width': 500,
      'height': 400,
      'size': 1000000,
    };

    final format = KlipyMediaFormat.fromJson(json);

    expect(format.url, 'https://example.com/full.gif');
    expect(format.width, 500);
    expect(format.height, 400);
    expect(format.size, 1000000);
  });

  test('KlipySearchResponse parses complete object', () {
    final json = {
      'result': true,
      'data': {
        'data': [
          {
            'id': 1,
            'slug': 'gif-1',
            'title': 'GIF 1',
            'file': {
              'md': {
                'gif': {'url': 'https://example.com/1.gif', 'width': 400, 'height': 400},
              },
            },
          },
        ],
        'current_page': 1,
        'per_page': 24,
        'has_next': true,
      },
    };

    final response = KlipySearchResponse.fromApiResponse(json);

    expect(response.results, hasLength(1));
    expect(response.results.first.slug, 'gif-1');
    expect(response.currentPage, 1);
    expect(response.perPage, 24);
    expect(response.hasNext, isTrue);
    expect(response.nextPage, 2);
  });

  group('KlipyGif thumbnailUrl helpers', () {
    test('gets from sm webp', () {
      final json = {
        'id': 789,
        'slug': 'test-gif',
        'title': 'Test',
        'file': {
          'sm': {
            'webp': {'url': 'https://example.com/sm.webp', 'width': 320, 'height': 180},
          },
        },
      };

      final gif = KlipyGif.fromJson(json);
      expect(gif.thumbnailUrl, 'https://example.com/sm.webp');
    });

    test('gets from sm gif when webp not available', () {
      final json = {
        'id': 789,
        'slug': 'test-gif',
        'title': 'Test',
        'file': {
          'sm': {
            'gif': {'url': 'https://example.com/sm.gif', 'width': 320, 'height': 180},
          },
        },
      };

      final gif = KlipyGif.fromJson(json);
      expect(gif.thumbnailUrl, 'https://example.com/sm.gif');
    });

    test('falls back to xs when sm not available', () {
      final json = {
        'id': 789,
        'slug': 'test-gif',
        'title': 'Test',
        'file': {
          'xs': {
            'webp': {'url': 'https://example.com/xs.webp', 'width': 160, 'height': 90},
          },
        },
      };

      final gif = KlipyGif.fromJson(json);
      expect(gif.thumbnailUrl, 'https://example.com/xs.webp');
    });

    test('returns null when no thumbnails', () {
      final json = {
        'id': 789,
        'slug': 'test-gif',
        'title': 'Test',
        'file': {
          'hd': {
            'gif': {'url': 'https://example.com/hd.gif', 'width': 1920, 'height': 1080},
          },
        },
      };

      final gif = KlipyGif.fromJson(json);
      expect(gif.thumbnailUrl, isNull);
    });
  });

  group('KlipyGif gifUrl helpers', () {
    test('gets from md gif', () {
      final json = {
        'id': 789,
        'slug': 'test-gif',
        'title': 'Test',
        'file': {
          'md': {
            'gif': {'url': 'https://example.com/md.gif', 'width': 640, 'height': 360},
          },
        },
      };

      final gif = KlipyGif.fromJson(json);

      expect(gif.gifUrl, 'https://example.com/md.gif');
    });

    test('gets from hd when md not available', () {
      final json = {
        'id': 789,
        'slug': 'test-gif',
        'title': 'Test',
        'file': {
          'hd': {
            'gif': {'url': 'https://example.com/hd.gif', 'width': 1920, 'height': 1080},
          },
        },
      };

      final gif = KlipyGif.fromJson(json);

      expect(gif.gifUrl, 'https://example.com/hd.gif');
    });

    test('returns null when no gif format available', () {
      final json = {
        'id': 789,
        'slug': 'test-gif',
        'title': 'Test',
        'file': {
          'md': {
            'webp': {'url': 'https://example.com/md.webp', 'width': 640, 'height': 360},
          },
        },
      };

      final gif = KlipyGif.fromJson(json);

      expect(gif.gifUrl, isNull);
    });
  });

  group('KlipyGif itemUrl', () {
    test('generates correct Klipy URL', () {
      final Map<String, dynamic> json = {
        'id': 789,
        'slug': 'funny-cat-abc123',
        'title': 'Funny Cat',
        'file': <String, dynamic>{},
      };

      final gif = KlipyGif.fromJson(json);

      expect(gif.itemUrl, 'https://klipy.com/gif/funny-cat-abc123');
    });
  });

  group('KlipyService', () {
    late MockDio mockDio;
    late KlipyService service;

    setUp(() {
      mockDio = MockDio();
      service = KlipyService(apiKey: 'test-api-key', customerId: 'test-user', dio: mockDio);
    });

    test('searchGifs returns correct results', () async {
      final responseJson = {
        'result': true,
        'data': {
          'data': [
            {'id': 1, 'slug': 'gif-1', 'title': 'Test GIF', 'file': <String, dynamic>{}},
          ],
          'current_page': 1,
          'per_page': 24,
          'has_next': false,
        },
      };

      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/v1/test-api-key/gifs/search',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: responseJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/test-api-key/gifs/search'),
        ),
      );

      final response = await service.searchGifs(query: 'funny cats');

      expect(response.results, hasLength(1));
      expect(response.results.first.slug, 'gif-1');
    });

    test('searchGifs respects pagination', () async {
      final responseJson = {
        'result': true,
        'data': {'data': [], 'current_page': 2, 'per_page': 24, 'has_next': true},
      };

      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/v1/test-api-key/gifs/search',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: responseJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/test-api-key/gifs/search'),
        ),
      );

      final response = await service.searchGifs(query: 'test', page: 2);

      expect(response.currentPage, 2);
      expect(response.nextPage, 3);
    });

    test('getTrendingGifs returns correct results', () async {
      final responseJson = {
        'result': true,
        'data': {
          'data': [
            {'id': 1, 'slug': 'trending-1', 'title': 'Trending GIF', 'file': <String, dynamic>{}},
          ],
          'current_page': 1,
          'per_page': 24,
          'has_next': false,
        },
      };

      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/v1/test-api-key/gifs/trending',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: responseJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/test-api-key/gifs/trending'),
        ),
      );

      final response = await service.getTrendingGifs();

      expect(response.results, hasLength(1));
      expect(response.results.first.slug, 'trending-1');
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
