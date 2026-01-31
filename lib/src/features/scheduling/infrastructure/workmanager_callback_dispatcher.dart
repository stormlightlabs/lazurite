import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/background_infrastructure.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    return handleTask(taskName, inputData);
  });
}

/// Testable task handler for Workmanager.
Future<bool> handleTask(
  String taskName,
  Map<String, dynamic>? inputData, {
  Future<BackgroundInfrastructure> Function()? initInfra,
}) async {
  const logger = Logger('Workmanager');
  logger.info('Background task started: $taskName');

  if (inputData == null || !inputData.containsKey('draftId')) {
    logger.error('Background task missing draftId in inputData');
    return false;
  }

  final draftId = inputData['draftId'] as String;

  try {
    final infra = await (initInfra ?? BackgroundInfrastructure.initialize)();
    await infra.postPublisher.publishDraft(draftId);
    return true;
  } catch (e, stack) {
    logger.error('Background task failed for draft $draftId', e, stack);
    return false;
  }
}
