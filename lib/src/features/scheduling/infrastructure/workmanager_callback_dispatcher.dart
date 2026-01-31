import 'package:lazurite/src/core/utils/logger.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    const logger = Logger('Workmanager');
    logger.info('Background task started: $taskName with data: $inputData');

    try {
      // TODO: Initialize minimal infrastructure and call PostPublisher
      return true;
    } catch (e, stack) {
      logger.error('Background task failed: $taskName', e, stack);
      return false;
    }
  });
}
