import 'dart:developer' as developer;

class Logger {
  const Logger(this.name);

  final String name;

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: name, level: 500, error: error, stackTrace: stackTrace);
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: name, level: 800, error: error, stackTrace: stackTrace);
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: name, level: 900, error: error, stackTrace: stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: name, level: 1000, error: error, stackTrace: stackTrace);
  }
}
