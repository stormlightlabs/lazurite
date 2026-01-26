/// Route path and name constants for navigation.
library;

/// Route paths for the application.
abstract final class AppRoutes {
  static const String home = '/home';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String dms = '/dms';
  static const String profile = '/profile';
  static const String splash = '/splash';
  static const String landing = '/landing';

  static const String login = '/login';
  static const String callback = '/callback';
  static const String compose = '/compose';
  static const String drafts = '/drafts';
  static const String scheduled = '/scheduled/:draftId';

  static const String settings = '/settings';
  static const String appearance = '/settings/appearance';
  static const String about = '/settings/about';
  static const String feedPreferences = '/settings/feeds';
  static const String contentModeration = '/settings/moderation';
  static const String mutedWords = '/settings/muted-words';
  static const String accessibility = '/settings/accessibility';

  static const String thread = 't/:uri';
  static const String profileDetail = 'u/:did';
  static const String followers = 'followers/:did';
  static const String following = 'following/:did';
  static const String convo = 'c/:convoId';
  static const String draftDetail = ':draftId';
  static const String feeds = '/feeds';
  static const String discoverFeeds = 'discover';
  static const String devtools = '/devtools';
  static const String devtoolsCollections = 'collections';
  static const String devtoolsRecords = ':collection';
  static const String devtoolsRecord = ':rkey';
  static const String fullscreenImage = '/fullscreen/image';
  static const String fullscreenVideo = '/fullscreen/video';
}

/// Route names for named navigation.
abstract final class AppRouteNames {
  static const String home = 'home';
  static const String search = 'search';
  static const String notifications = 'notifications';
  static const String dms = 'dms';
  static const String profile = 'profile';
  static const String splash = 'splash';
  static const String landing = 'landing';

  static const String login = 'login';
  static const String callback = 'callback';
  static const String compose = 'compose';
  static const String scheduled = 'scheduled';
  static const String settings = 'settings';
  static const String appearance = 'appearance';
  static const String about = 'about';
  static const String feedPreferences = 'feedPreferences';
  static const String contentModeration = 'contentModeration';
  static const String mutedWords = 'mutedWords';
  static const String accessibility = 'accessibility';
  static const String drafts = 'drafts';
  static const String thread = 'thread';
  static const String profileDetail = 'profileDetail';
  static const String followers = 'followers';
  static const String following = 'following';
  static const String convo = 'convo';
  static const String draftDetail = 'draftDetail';
  static const String feeds = 'feeds';
  static const String discoverFeeds = 'discoverFeeds';
  static const String devToolsHome = 'devToolsHome';
  static const String devToolsCollections = 'devToolsCollections';
  static const String devToolsRecords = 'devToolsRecords';
  static const String devToolsRecord = 'devToolsRecord';
  static const String fullscreenImage = 'fullscreenImage';
  static const String fullscreenVideo = 'fullscreenVideo';
}
