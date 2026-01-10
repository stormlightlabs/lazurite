import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'thread_collapse_state.g.dart';

/// Manages collapse/expand state for thread posts.
///
/// State is session-only and keyed by post URI. Posts are expanded by default.
@riverpod
class ThreadCollapseState extends _$ThreadCollapseState {
  @override
  Map<String, bool> build() => {};

  /// Check if a post is collapsed.
  ///
  /// Returns false (expanded) if post URI is not in the map.
  bool isCollapsed(String postUri) => state[postUri] ?? false;

  /// Toggle collapse state for a post.
  void toggle(String postUri) {
    state = {...state, postUri: !(state[postUri] ?? false)};
  }

  /// Collapse all posts in the provided list.
  void collapseAll(List<String> uris) {
    final newState = {...state};
    for (final uri in uris) {
      newState[uri] = true;
    }
    state = newState;
  }

  /// Expand all posts (clear all collapse state).
  void expandAll() {
    state = {};
  }

  /// Collapse a specific post.
  void collapse(String postUri) {
    state = {...state, postUri: true};
  }

  /// Expand a specific post.
  void expand(String postUri) {
    state = {...state, postUri: false};
  }
}
