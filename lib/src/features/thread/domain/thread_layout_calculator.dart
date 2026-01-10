import 'package:lazurite/src/features/thread/domain/thread.dart';

/// Utility class for thread layout calculations.
///
/// Provides constants and methods for computing indentation, connector
/// positioning, and depth management for nested thread rendering.
class ThreadLayoutCalculator {
  ThreadLayoutCalculator._();

  /// Base indentation for depth 0 posts
  static const double baseIndent = 0.0;

  /// Additional indentation per nesting level
  static const double indentPerLevel = 12.0;

  /// Maximum depth before flattening
  static const int maxDepth = 5;

  /// Calculate left padding for a post at given depth.
  ///
  /// Depth is clamped to [maxDepth] to prevent infinite horizontal scrolling.
  static double calculateIndent(int depth) {
    final effectiveDepth = depth.clamp(0, maxDepth);
    return baseIndent + (effectiveDepth * indentPerLevel);
  }

  /// Determine if depth should be flattened.
  ///
  /// Returns true if depth exceeds [maxDepth], indicating that further
  /// nesting should be prevented to maintain readability.
  static bool shouldFlattenDepth(int depth) {
    return depth > maxDepth;
  }

  /// Calculate effective depth (accounts for max depth flattening).
  ///
  /// Returns the actual depth value that should be used for rendering,
  /// clamped to [maxDepth].
  static int calculateEffectiveDepth(int actualDepth) {
    return actualDepth.clamp(0, maxDepth);
  }

  /// Get parent context for deep threads.
  ///
  /// Returns a string like "@username" to show which post this is replying to
  /// when depth is flattened.
  static String getParentContext(ThreadViewPost post) {
    if (post.parent == null) return '';
    final handle = post.parent!.post.author.handle;
    return '@$handle';
  }

  /// Count total number of replies (including nested).
  ///
  /// Recursively counts all descendants of a post.
  static int countAllReplies(ThreadViewPost post) {
    var count = post.replies.length;
    for (final reply in post.replies) {
      count += countAllReplies(reply);
    }
    return count;
  }
}
