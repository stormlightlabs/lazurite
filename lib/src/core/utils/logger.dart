import 'dart:developer' as developer;

class Logger {
  const Logger(this.name);

  final String name;

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    final formattedError = _formatMetadata(error);
    developer.log(message, name: name, level: 500, error: formattedError, stackTrace: stackTrace);
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    final formattedError = _formatMetadata(error);
    developer.log(message, name: name, level: 800, error: formattedError, stackTrace: stackTrace);
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    final formattedError = _formatMetadata(error);
    developer.log(message, name: name, level: 900, error: formattedError, stackTrace: stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    final formattedError = _formatMetadata(error);
    developer.log(message, name: name, level: 1000, error: formattedError, stackTrace: stackTrace);
  }

  Object? _formatMetadata(Object? metadata) {
    if (metadata == null) return null;
    if (metadata is Map || metadata is List) {
      return metadata.toString();
    }
    return metadata;
  }
}
