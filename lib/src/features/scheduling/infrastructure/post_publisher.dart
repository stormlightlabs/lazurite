import 'package:lazurite/src/core/utils/error_message.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart' as composer;
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/features/scheduling/domain/schedule.dart';
import 'package:lazurite/src/infrastructure/auth/auth_repository.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/daos/drafts_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/schedules_dao.dart';

/// Service for publishing scheduled drafts.
///
/// Handles the complete publishing flow including validation, session refresh,
/// record creation, and status persistence. Ensures idempotency by checking
/// if a draft has already been posted before attempting to publish.
class PostPublisher {
  PostPublisher({
    required DraftsDao draftsDao,
    required SchedulesDao schedulesDao,
    required SessionStorage sessionStorage,
    required AuthRepository authRepository,
    required DraftRepository draftRepository,
    required Logger logger,
  }) : _draftsDao = draftsDao,
       _schedulesDao = schedulesDao,
       _sessionStorage = sessionStorage,
       _authRepository = authRepository,
       _draftRepository = draftRepository,
       _logger = logger;

  final DraftsDao _draftsDao;
  final SchedulesDao _schedulesDao;
  final SessionStorage _sessionStorage;
  final AuthRepository _authRepository;
  final DraftRepository _draftRepository;
  final Logger _logger;

  /// Maximum number of publish attempts before giving up.
  static const _maxAttempts = 3;

  /// Publishes a scheduled draft by ID.
  ///
  /// This method:
  /// 1. Validates the draft exists and is in a valid state
  /// 2. Checks for idempotency (already posted)
  /// 3. Refreshes the session if needed
  /// 4. Publishes the draft using the DraftRepository
  /// 5. Updates the schedule status
  ///
  /// Returns the URI and CID of the published post, or null if already posted.
  /// Throws an exception if publishing fails.
  Future<({String uri, String cid})?> publishDraft(String draftId) async {
    _logger.info('Publishing scheduled draft: $draftId');

    final session = await _sessionStorage.getSession();
    if (session == null) {
      throw Exception('No active session');
    }
    final ownerDid = session.did;

    final draftRecord = await _draftsDao.getDraft(draftId, ownerDid);
    if (draftRecord == null) {
      final error = 'Draft $draftId not found';
      _logger.error(error);
      throw Exception(error);
    }

    final scheduleData = await _schedulesDao.getSchedule(draftId, ownerDid);
    if (scheduleData == null) {
      final error = 'Schedule for draft $draftId not found';
      _logger.error(error);
      throw Exception(error);
    }

    if (scheduleData.postedUri != null && scheduleData.postedCid != null) {
      _logger.info('Draft $draftId already posted at ${scheduleData.postedUri}');
      return (uri: scheduleData.postedUri!, cid: scheduleData.postedCid!);
    }

    if (scheduleData.attempts >= _maxAttempts) {
      final error = 'Draft $draftId exceeded max publish attempts ($_maxAttempts)';
      _logger.error(error);
      await _updateScheduleFailed(draftId, ownerDid, error);
      throw Exception(error);
    }

    await _schedulesDao.updateScheduleStatus(draftId, ownerDid, ScheduleStatus.posting.name);

    try {
      _logger.debug('Refreshing session before publishing draft $draftId');
      final refreshedSession = await _authRepository.refreshSession(session);
      await _sessionStorage.saveSession(refreshedSession);

      _logger.info('Calling DraftRepository.publishDraft for $draftId');
      final result = await _draftRepository.publishDraft(draftId);

      await _schedulesDao.updateScheduleStatus(
        draftId,
        ownerDid,
        ScheduleStatus.posted.name,
        postedUri: result.uri,
        postedCid: result.cid,
      );

      _logger.info('Successfully published scheduled draft $draftId to ${result.uri}');
      return result;
    } catch (e, stack) {
      final error = errorMessage(e);
      _logger.error('Failed to publish scheduled draft $draftId', e, stack);

      await _schedulesDao.incrementAttempts(draftId, ownerDid);
      await _updateScheduleFailed(draftId, ownerDid, error);

      rethrow;
    }
  }

  /// Publishes multiple scheduled drafts in sequence.
  ///
  /// Returns a list of successful posts and a list of failures.
  Future<
    ({
      List<({String draftId, String uri, String cid})> succeeded,
      List<({String draftId, String error})> failed,
    })
  >
  publishDrafts(List<String> draftIds) async {
    final succeeded = <({String draftId, String uri, String cid})>[];
    final failed = <({String draftId, String error})>[];

    for (final draftId in draftIds) {
      try {
        final result = await publishDraft(draftId);
        if (result != null) {
          succeeded.add((draftId: draftId, uri: result.uri, cid: result.cid));
        } else {
          succeeded.add((draftId: draftId, uri: '', cid: ''));
        }
      } catch (e) {
        failed.add((draftId: draftId, error: errorMessage(e)));
      }
    }

    return (succeeded: succeeded, failed: failed);
  }

  /// Validates that a draft is ready to be published.
  ///
  /// Returns true if the draft exists and is in a publishable state.
  /// Logs warnings if the draft is not valid.
  Future<bool> validateDraft(String draftId) async {
    final session = await _sessionStorage.getSession();
    if (session == null) {
      _logger.warning('No active session for draft validation');
      return false;
    }

    final draftRecord = await _draftsDao.getDraft(draftId, session.did);
    if (draftRecord == null) {
      _logger.warning('Draft $draftId not found for validation');
      return false;
    }

    final status = _statusFromDb(draftRecord.draft.status);
    if (status == composer.DraftStatus.posted) {
      _logger.warning('Draft $draftId is already posted');
      return false;
    }

    if (status == composer.DraftStatus.publishing) {
      _logger.warning('Draft $draftId is already being published');
      return false;
    }

    return true;
  }

  /// Checks if a draft has already been posted (idempotency check).
  Future<bool> isAlreadyPosted(String draftId) async {
    final session = await _sessionStorage.getSession();
    if (session == null) return false;

    final scheduleData = await _schedulesDao.getSchedule(draftId, session.did);
    return scheduleData?.postedUri != null && scheduleData?.postedCid != null;
  }

  /// Updates a schedule to failed status with an error message.
  Future<void> _updateScheduleFailed(String draftId, String ownerDid, String error) async {
    await _schedulesDao.updateScheduleStatus(
      draftId,
      ownerDid,
      ScheduleStatus.failed.name,
      lastError: error,
    );
  }

  /// Converts a database status string to a DraftStatus enum.
  composer.DraftStatus _statusFromDb(String value) {
    return composer.DraftStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => composer.DraftStatus.draft,
    );
  }
}
