import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/klipy_gif.dart';

part 'klipy_service.g.dart';

// TODO: Replace with your Klipy API key from https://partner.klipy.com
const String _defaultApiKey = 'YOUR_KLIPY_API_KEY';

/// Service for interacting with Klipy API.
///
/// Provides methods for searching GIFs and getting trending GIFs.
/// The API key should be configured securely via environment variables.
/// Obtain your API key from https://partner.klipy.com
@riverpod
KlipyService klipyService(Ref ref) {
  return KlipyService(apiKey: _defaultApiKey);
}

class KlipyService {
  KlipyService({required String apiKey, String? customerId, Dio? dio})
    : _apiKey = apiKey,
      _customerId = customerId ?? 'lazurite_user',
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.klipy.com',
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 30),
            ),
          );

  final String _apiKey;
  final String _customerId;
  final Dio _dio;

  /// Searches for GIFs matching the query string.
  ///
  /// [query] is the search query string.
  /// [perPage] is the number of results to return (max 50, default 24).
  /// [page] is the page number for pagination (starts at 1).
  Future<KlipySearchResponse> searchGifs({
    required String query,
    int perPage = 24,
    int page = 1,
  }) async {
    if (query.trim().isEmpty) {
      return getTrendingGifs(perPage: perPage, page: page);
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/$_apiKey/gifs/search',
        queryParameters: {
          'customer_id': _customerId,
          'q': query,
          'per_page': perPage.clamp(1, 50),
          'page': page,
        },
      );

      return KlipySearchResponse.fromApiResponse(response.data ?? {});
    } on DioException catch (e) {
      throw _convertDioError(e);
    }
  }

  /// Gets trending GIFs.
  ///
  /// [perPage] is the number of results to return (max 50, default 24).
  /// [page] is the page number for pagination (starts at 1).
  Future<KlipySearchResponse> getTrendingGifs({int perPage = 24, int page = 1}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/$_apiKey/gifs/trending',
        queryParameters: {
          'customer_id': _customerId,
          'per_page': perPage.clamp(1, 50),
          'page': page,
        },
      );

      return KlipySearchResponse.fromApiResponse(response.data ?? {});
    } on DioException catch (e) {
      throw _convertDioError(e);
    }
  }

  /// Downloads a GIF thumbnail for upload.
  ///
  /// [url] is the URL of the thumbnail to download.
  /// Returns the file path of the downloaded thumbnail.
  Future<File> downloadThumbnail(String url) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Failed to download thumbnail: empty response');
      }

      final extension = url.contains('.webp') ? 'webp' : 'jpg';
      final directory = Directory.systemTemp;
      final file = File(
        '${directory.path}/klipy_thumb_${DateTime.now().millisecondsSinceEpoch}.$extension',
      );
      await file.writeAsBytes(bytes);

      return file;
    } on DioException catch (e) {
      throw _convertDioError(e);
    }
  }

  /// Converts DioException to a more user-friendly error.
  Exception _convertDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          return Exception('Client error: ${e.response?.statusMessage}');
        }
        if (statusCode != null && statusCode >= 500) {
          return Exception('Server error. Please try again later.');
        }
        return Exception('Network error: ${e.response?.statusMessage}');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
        return Exception('An unexpected error occurred: ${e.message}');
    }
  }
}
