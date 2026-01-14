import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/tenor_gif.dart';

part 'tenor_service.g.dart';

// FIXME: Replace with an actual API key
const String _defaultApiKey = 'AIzaSyD4HJZw9KqfVqXbQeJZxk7w7xX0Xy0X0';

/// Service for interacting with Tenor API.
///
/// Provides methods for searching GIFs and getting featured/trending GIFs.
/// The API key should be configured securely via environment variables.
@riverpod
TenorService tenorService(Ref ref) {
  return TenorService(apiKey: _defaultApiKey, clientKey: 'lazurite_flutter');
}

class TenorService {
  TenorService({required String apiKey, required String clientKey, Dio? dio})
    : _apiKey = apiKey,
      _clientKey = clientKey,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://tenor.googleapis.com/v2',
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 30),
            ),
          );

  final String _apiKey;
  final String _clientKey;
  final Dio _dio;

  /// Searches for GIFs matching the query string.
  ///
  /// [query] is the search query string.
  /// [limit] is the number of results to return (max 50, default 20).
  /// [pos] is the pagination token for fetching next page.
  Future<TenorSearchResponse> searchGifs({
    required String query,
    int limit = 20,
    String? pos,
  }) async {
    if (query.trim().isEmpty) {
      return getFeaturedGifs(limit: limit);
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/search',
        queryParameters: {
          'q': query,
          'key': _apiKey,
          'client_key': _clientKey,
          'limit': limit.clamp(1, 50),
          if (pos != null) 'pos': pos,
        },
      );

      return TenorSearchResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw _convertDioError(e);
    }
  }

  /// Gets featured/trending GIFs.
  ///
  /// [limit] is the number of results to return (max 50, default 20).
  /// [pos] is the pagination token for fetching next page.
  Future<TenorSearchResponse> getFeaturedGifs({int limit = 20, String? pos}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/featured',
        queryParameters: {
          'key': _apiKey,
          'client_key': _clientKey,
          'limit': limit.clamp(1, 50),
          if (pos != null) 'pos': pos,
        },
      );

      return TenorSearchResponse.fromJson(response.data ?? {});
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

      final directory = Directory.systemTemp;
      final file = File(
        '${directory.path}/tenor_thumb_${DateTime.now().millisecondsSinceEpoch}.jpg',
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
