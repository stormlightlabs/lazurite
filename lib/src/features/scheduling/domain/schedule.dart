import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

/// Status of a scheduled post through the publishing pipeline.
enum ScheduleStatus {
  /// Post is scheduled and waiting for the scheduled time.
  scheduled,

  /// Post is currently being published to the network.
  posting,

  /// Post was successfully published.
  posted,

  /// Post publication failed after retry attempts.
  failed,
}

/// Converts string from database to ScheduleStatus enum.
ScheduleStatus scheduleStatusFromString(String value) {
  return ScheduleStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ScheduleStatus.scheduled,
  );
}

/// Converts ScheduleStatus enum to string for database storage.
String scheduleStatusToString(ScheduleStatus value) {
  return value.name;
}

/// Represents a scheduled post publication.
///
/// Links a draft to a scheduled publication time, tracking the state
/// of the post through the publishing pipeline. Maintains idempotency
/// by storing the posted URI/CID once successfully published.
@freezed
abstract class Schedule with _$Schedule {
  const factory Schedule({
    /// ID of the draft to be published.
    required String draftId,

    /// The DID of the user who owns this scheduled post.
    required String ownerDid,

    /// When the post should be published (UTC).
    required DateTime scheduledAtUtc,

    /// Current state of the scheduled post.
    required ScheduleStatus status,

    /// When this schedule record was created.
    required DateTime createdAt,

    /// When this schedule was last modified.
    required DateTime updatedAt,

    /// Number of publish attempts made.
    @Default(0) int attempts,

    /// Error message from the last failed attempt (if any).
    String? lastError,

    /// AT URI of the successfully posted post (null until published).
    String? postedUri,

    /// CID of the successfully posted post (null until published).
    String? postedCid,
  }) = _Schedule;

  const Schedule._();

  factory Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);

  /// Returns true if the post has been successfully published.
  bool get isPosted => status == ScheduleStatus.posted;

  /// Returns true if the post publication failed.
  bool get isFailed => status == ScheduleStatus.failed;

  /// Returns true if the post is currently being published.
  bool get isPublishing => status == ScheduleStatus.posting;

  /// Returns true if the post is waiting to be published.
  bool get isScheduled => status == ScheduleStatus.scheduled;

  /// Returns true if this schedule can be retried (failed with attempts remaining).
  bool get canRetry => status == ScheduleStatus.failed && attempts < 3;
}
