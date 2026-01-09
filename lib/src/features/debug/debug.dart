/// Debug overlay feature for development-time diagnostics.
///
/// This feature provides a debug overlay accessible only in debug builds
/// (kDebugMode). It displays system information, ATProto session details,
/// and (in Part 2) network logs.
///
/// ## Usage
/// Wrap your MaterialApp with [DebugOverlayHost]:
/// ```dart
/// DebugOverlayHost(
///   child: MaterialApp.router(...),
/// )
/// ```
///
/// ## Activation
/// - **Mobile**: 2-finger long-press for 2 seconds
/// - **Desktop**: ALT+F12 keyboard shortcut
library;

export 'application/debug_overlay_controller.dart';
export 'application/system_info_provider.dart';
export 'presentation/atproto_session_tab.dart';
export 'presentation/debug_drawer.dart';
export 'presentation/debug_overlay_host.dart';
export 'presentation/system_info_tab.dart';
