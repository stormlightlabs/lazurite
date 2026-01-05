import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';

void main() {
  group('Logger', () {
    test('methods do not throw exceptions', () {
      const logger = Logger('TestLogger');

      expect(() => logger.debug('debug message'), returnsNormally);
      expect(() => logger.info('info message'), returnsNormally);
      expect(() => logger.warning('warning message'), returnsNormally);
      expect(() => logger.error('error message'), returnsNormally);
    });

    test('methods accept error and stackTrace', () {
      const logger = Logger('TestLogger');
      final error = Exception('test exception');
      final stackTrace = StackTrace.current;

      expect(() => logger.debug('debug', error, stackTrace), returnsNormally);
      expect(() => logger.info('info', error, stackTrace), returnsNormally);
      expect(() => logger.warning('warning', error, stackTrace), returnsNormally);
      expect(() => logger.error('error', error, stackTrace), returnsNormally);
    });
  });
}
