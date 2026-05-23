import 'package:go_router/go_router.dart';
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

  /// Returns a decoded path parameter, or an empty string when absent.
  String decodedPathOrEmpty(String key) => Uri.decodeComponent(state.pathParameters[key] ?? '');

  /// Parses a decoded AT-URI query value, or returns `null` when absent/blank.
  AtUri? atUri(String key) {
    final value = decoded(key);
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return AtUri.parse(value);
  }
}
