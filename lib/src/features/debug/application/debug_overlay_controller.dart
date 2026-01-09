import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debug_overlay_controller.g.dart';

/// State for the debug overlay.
class DebugOverlayState {
  const DebugOverlayState({this.isVisible = false, this.activeTabIndex = 0});

  /// Whether the overlay is currently visible.
  final bool isVisible;

  /// The currently active tab index.
  final int activeTabIndex;

  /// Creates a copy of this state with the given fields replaced.
  DebugOverlayState copyWith({bool? isVisible, int? activeTabIndex}) {
    return DebugOverlayState(
      isVisible: isVisible ?? this.isVisible,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebugOverlayState &&
          runtimeType == other.runtimeType &&
          isVisible == other.isVisible &&
          activeTabIndex == other.activeTabIndex;

  @override
  int get hashCode => Object.hash(isVisible, activeTabIndex);
}

/// Controller for the debug overlay visibility and tab state.
///
/// Manages overlay visibility, active tab selection, and provides methods
/// to show, hide, and toggle the overlay.
@riverpod
class DebugOverlayController extends _$DebugOverlayController {
  @override
  DebugOverlayState build() => const DebugOverlayState();

  /// Shows the debug overlay.
  void show() => state = state.copyWith(isVisible: true);

  /// Hides the debug overlay.
  void hide() => state = state.copyWith(isVisible: false);

  /// Toggles the debug overlay visibility.
  void toggle() => state = state.copyWith(isVisible: !state.isVisible);

  /// Sets the active tab index.
  void setTab(int index) => state = state.copyWith(activeTabIndex: index);
}
