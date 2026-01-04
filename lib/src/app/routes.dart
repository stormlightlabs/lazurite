/// Route path and name constants for navigation.
library;

/// Route paths for the application.
abstract final class AppRoutes {
  static const String home = '/home';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String dms = '/dms';
  static const String profile = '/profile';

  static const String login = '/login';
  static const String callback = '/callback';
  static const String compose = '/compose';
  static const String settings = '/settings';
  static const String drafts = '/drafts';

  static const String thread = 't/:uri';
  static const String profileDetail = 'u/:did';
  static const String convo = 'c/:convoId';
  static const String draftDetail = ':draftId';
}

/// Route names for named navigation.
abstract final class AppRouteNames {
  static const String home = 'home';
  static const String search = 'search';
  static const String notifications = 'notifications';
  static const String dms = 'dms';
  static const String profile = 'profile';
  static const String login = 'login';
  static const String callback = 'callback';
  static const String compose = 'compose';
  static const String settings = 'settings';
  static const String drafts = 'drafts';
  static const String thread = 'thread';
  static const String profileDetail = 'profileDetail';
  static const String convo = 'convo';
  static const String draftDetail = 'draftDetail';
}
