/// Canonical route paths shared by router policy, route declarations,
/// and feature screens.
enum AppRoutePath {
  /// Authenticated home timeline root.
  home,

  /// Login screen.
  login,

  /// Public browsing redirect root.
  public,

  /// Public browsing route pattern for provider/tab state.
  publicProviderTab,

  /// Compose route.
  compose,

  /// Hashtag timeline route.
  hashtag,

  /// Feed detail route shared by authenticated and public contexts.
  feed,

  /// Post thread compatibility route using a query AT-URI.
  post,

  /// Canonical post route using actor and record key path params.
  postRecord,

  /// Topic timeline route shared by authenticated and public contexts.
  topic,

  /// Public profile route pattern that excludes `/profile/me`.
  publicProfile,

  /// Current account profile route.
  profileMe,

  /// Profile context route.
  profileContext,

  /// Full-screen image viewer route.
  images,

  /// Full-screen video viewer route.
  video,

  /// Bookmarked posts route.
  bookmarks,

  /// Liked posts route.
  liked,

  /// Lists overview route.
  lists,

  /// List detail compatibility route using a query AT-URI.
  list,

  /// Canonical list detail route using actor and record key path params.
  listRecord,

  /// Create starter pack route.
  createStarterPack,

  /// Starter pack compatibility route using a query AT-URI.
  starterPack,

  /// Canonical starter pack detail route using actor and record key path params.
  starterPackRecord,

  /// Actor starter packs route.
  starterPacks,

  /// Alerts route.
  alerts,

  /// Compatibility notifications route.
  notifications,

  /// Compatibility messages route.
  messages,

  /// Search route.
  search,

  /// AT Explorer route.
  atExplorer,

  /// Settings root.
  settings,

  /// Settings about page.
  settingsAbout,

  /// Settings logs page.
  settingsLogs,

  /// Developer tools route exposed under settings for logged-out users.
  settingsDevTools,

  /// Terms of service route.
  terms,

  /// Privacy policy route.
  privacy,

  /// OAuth callback path used by mobile custom-scheme and HTTPS app links.
  oauthCallback,

  /// Older callback path still accepted for compatibility with existing links.
  oauthCallbackCompatibility;

  /// URL path used by GoRouter route declarations, redirects, and navigation.
  String get path => switch (this) {
    AppRoutePath.home => '/',
    AppRoutePath.login => '/login',
    AppRoutePath.public => '/public',
    AppRoutePath.publicProviderTab => '/public/:provider/:tab',
    AppRoutePath.compose => '/compose',
    AppRoutePath.hashtag => '/hashtag',
    AppRoutePath.feed => '/feed',
    AppRoutePath.post => '/post',
    AppRoutePath.postRecord => '/profile/:actor/post/:rkey',
    AppRoutePath.topic => '/topic',
    AppRoutePath.publicProfile => r'/profile/:actor(m|[^m][^/]*|m[^e][^/]*|me[^/]+)',
    AppRoutePath.profileMe => '/profile/me',
    AppRoutePath.profileContext => '/profile/:actor/context',
    AppRoutePath.images => '/images',
    AppRoutePath.video => '/video',
    AppRoutePath.bookmarks => '/bookmarks',
    AppRoutePath.liked => '/liked',
    AppRoutePath.lists => '/lists',
    AppRoutePath.list => '/list',
    AppRoutePath.listRecord => '/list/:actor/:rkey',
    AppRoutePath.createStarterPack => '/create-starter-pack',
    AppRoutePath.starterPack => '/starter-pack',
    AppRoutePath.starterPackRecord => '/starter-pack/:actor/:rkey',
    AppRoutePath.starterPacks => '/starter-packs',
    AppRoutePath.alerts => '/alerts',
    AppRoutePath.notifications => '/notifications',
    AppRoutePath.messages => '/messages',
    AppRoutePath.search => '/search',
    AppRoutePath.atExplorer => '/at-explorer',
    AppRoutePath.settings => '/settings',
    AppRoutePath.settingsAbout => '/settings/about',
    AppRoutePath.settingsLogs => '/settings/logs',
    AppRoutePath.settingsDevTools => '/settings/devtools',
    AppRoutePath.terms => '/terms',
    AppRoutePath.privacy => '/privacy',
    AppRoutePath.oauthCallback => '/oauth/callback',
    AppRoutePath.oauthCallbackCompatibility => '/callback',
  };

  /// Last path segment for declaring nested GoRouter child routes.
  ///
  /// For example, [settingsAbout] has the absolute [path] `/settings/about`
  /// but must be declared as `about` inside the `/settings` parent route.
  String get childPath => path.substring(path.lastIndexOf('/') + 1);

  /// Canonical profile-context location for an actor DID or handle.
  static String profileContextLocation({required String actor}) =>
      '/${Uri(pathSegments: ['profile', actor, 'context'])}';
}
