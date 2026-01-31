/// Platform-agnostic scheduler interface for scheduled posts.
///
/// This interface abstracts platform-specific scheduling mechanisms,
/// allowing the application to swap implementations (e.g., notification-based
/// vs background task-based) without refactoring core business logic.
///
/// Implementations should handle:
/// - Scheduling a one-time task at a specific UTC datetime
/// - Canceling previously scheduled tasks
/// - Resyncing all pending tasks after device reboot or app restart
///
/// Example implementations:
/// - NotificationScheduler: Uses flutter_local_notifications
/// - BackgroundTaskScheduler: Uses workmanager/foreground services
abstract class Scheduler {
  /// Schedules a one-time task for the given draft.
  ///
  /// The [draftId] uniquely identifies the draft to be published.
  /// The [scheduledAtUtc] specifies when the task should execute.
  ///
  /// Implementations should:
  /// - Handle timezone conversions internally
  /// - Store the draftId for task identification
  /// - Return a boolean indicating success
  Future<bool> schedule(String draftId, DateTime scheduledAtUtc);

  /// Cancels a previously scheduled task.
  ///
  /// The [draftId] identifies the task to cancel.
  ///
  /// Implementations should:
  /// - Handle cases where the task doesn't exist gracefully
  /// - Clean up any platform-specific resources
  /// - Return a boolean indicating whether a task was canceled
  Future<bool> cancel(String draftId);

  /// Resynchronizes all pending scheduled tasks.
  ///
  /// This should be called on app startup to restore tasks after:
  /// - Device reboot
  /// - App restart
  /// - Platform scheduler resets
  ///
  /// Implementations should:
  /// - Query the database for pending scheduled posts
  /// - Re-register tasks with the platform scheduler
  /// - Handle tasks that may have already executed
  Future<void> resyncAll();

  /// Cancels all previously scheduled tasks managed by this scheduler.
  Future<void> cancelAll();
}
