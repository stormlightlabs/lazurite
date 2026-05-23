import 'package:go_router/go_router.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';

/// Convenience reader for decoded route query and path values.
///
/// Route files should use this for repeated URL decoding and typed parsing so
/// screen builders receive normalized values instead of raw query strings.
class RouteQuery {
  const RouteQuery(this.state);

  final GoRouterState state;

  /// Returns a decoded query value, or `null` when the value is absent.
  String? decoded(String key) {
    final value = state.uri.queryParameters[key];
    return value == null ? null : Uri.decodeComponent(value);
  }

  /// Returns a decoded query value trimmed, or an empty string when absent.
  String decodedOrEmpty(String key) => decoded(key)?.trim() ?? '';

  /// Returns whether a query value was present and not blank after decoding.
  bool hasNonEmpty(String key) => decoded(key)?.trim().isNotEmpty == true;

  /// Returns a decoded path parameter, or an empty string when absent.
  String decodedPathOrEmpty(String key) => Uri.decodeComponent(state.pathParameters[key] ?? '');

  /// Parses a decoded AT-URI query value, or returns `null` when invalid.
  AtUri? tryAtUri(String key) {
    final value = decoded(key);
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final normalized = value.trim();
    if (!normalized.startsWith('at://')) {
      log.d('Invalid AT-URI in route query "$key": missing at:// scheme');
      return null;
    }
    try {
      return AtUri.parse(normalized);
    } catch (error, stackTrace) {
      log.d('Invalid AT-URI in route query "$key"', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  /// Parses a decoded AT-URI query value.
  ///
  /// Use [tryAtUri] for external/deep-link input where malformed values should
  /// show an invalid-link route state instead of throwing.
  AtUri? atUri(String key) => tryAtUri(key);
}
