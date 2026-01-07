import 'bluesky_preferences.dart';

/// Service for filtering content based on muted words and user preferences.
///
/// Checks post text and tags against the user's muted words list to determine
/// if content should be hidden from feeds and search results.
class MutedWordFilterService {
  const MutedWordFilterService({required this.mutedWords});

  /// User's muted words preferences (only active, non-expired words).
  final List<MutedWord> mutedWords;

  /// Checks if a post should be hidden based on muted words.
  ///
  /// Matches muted words against:
  /// - Post text (if target includes 'content')
  /// - Post tags/hashtags (if target includes 'tags')
  ///
  /// For actor targets:
  /// - 'all': Mutes from all accounts
  /// - 'excludeFollowing': Only mutes from accounts not followed (requires isFollowing parameter)
  ///
  /// Returns true if the post matches any active muted word.
  bool shouldMutePost({
    required String text,
    List<String> tags = const [],
    bool isFollowing = false,
  }) {
    for (final word in mutedWords) {
      if (word.actorTarget == MutedWordActorTarget.excludeFollowing && isFollowing) {
        continue;
      }

      final value = word.value.toLowerCase();

      for (final target in word.targets) {
        switch (target) {
          case MutedWordTarget.content:
            if (_matchesContent(text, value)) return true;
          case MutedWordTarget.tags:
            if (_matchesTags(tags, value)) return true;
        }
      }
    }

    return false;
  }

  /// Checks if muted word matches in post content.
  ///
  /// Performs case-insensitive substring matching with word boundaries.
  /// For example, "cat" will match "I love cats" but not "category".
  /// Handles special characters and emojis by detecting if the muted value
  /// is alphanumeric - if not, uses simple substring matching instead.
  bool _matchesContent(String text, String mutedValue) {
    final lowerText = text.toLowerCase();

    try {
      final escaped = RegExp.escape(mutedValue);

      final isAlphanumeric = RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(mutedValue);

      if (isAlphanumeric) {
        final boundaryPattern = RegExp(r'\b' + escaped + r's?\b');
        return boundaryPattern.hasMatch(lowerText);
      } else {
        final simplePattern = RegExp(escaped);
        return simplePattern.hasMatch(lowerText);
      }
    } catch (e) {
      return lowerText.contains(mutedValue);
    }
  }

  /// Checks if muted word matches in post tags.
  ///
  /// Performs case-insensitive exact matching on hashtags.
  bool _matchesTags(List<String> tags, String mutedValue) {
    return tags.any((tag) => tag.toLowerCase() == mutedValue);
  }

  /// Checks if any muted word would trigger for given content and tags.
  ///
  /// Useful for checking before displaying content or for analytics.
  bool hasMatchingMutedWords({
    required String text,
    List<String> tags = const [],
    bool isFollowing = false,
  }) {
    return shouldMutePost(text: text, tags: tags, isFollowing: isFollowing);
  }

  /// Gets all muted words that match the given content.
  ///
  /// Returns the list of MutedWord objects that triggered for debugging or user feedback purposes.
  List<MutedWord> getMatchingMutedWords({
    required String text,
    List<String> tags = const [],
    bool isFollowing = false,
  }) {
    final matches = <MutedWord>[];

    for (final word in mutedWords) {
      if (word.actorTarget == MutedWordActorTarget.excludeFollowing && isFollowing) {
        continue;
      }

      final value = word.value.toLowerCase();
      var matched = false;

      for (final target in word.targets) {
        switch (target) {
          case MutedWordTarget.content:
            if (_matchesContent(text, value)) matched = true;
          case MutedWordTarget.tags:
            if (_matchesTags(tags, value)) matched = true;
        }
      }

      if (matched) matches.add(word);
    }

    return matches;
  }
}
