import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Lazurite'**
  String get appTitle;

  /// Button label to apply a setting and restart app services
  ///
  /// In en, this message translates to:
  /// **'Apply and Restart'**
  String get buttonApplyAndRestart;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// Button label to clear local cache
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get buttonClearCache;

  /// Continue button label
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get buttonContinue;

  /// Remove button label
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get buttonRemove;

  /// Apply button label
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get buttonApply;

  /// Clear button label
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get buttonClear;

  /// Clear all filters button label
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get buttonClearAll;

  /// Open button label
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get buttonOpen;

  /// Button label to clear local sign-in data
  ///
  /// In en, this message translates to:
  /// **'Reset Sign-In Data'**
  String get buttonResetSignInData;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// Sign in button label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get buttonSignIn;

  /// Button label to reveal moderated content
  ///
  /// In en, this message translates to:
  /// **'Show content'**
  String get buttonShowContent;

  /// Try again button label
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get buttonTryAgain;

  /// Label for a value that has never happened
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get commonNever;

  /// Label for no value
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// Label for a health check that has not run
  ///
  /// In en, this message translates to:
  /// **'Not checked yet'**
  String get commonNotCheckedYet;

  /// Disabled option label
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get commonOff;

  /// Confirmation dialog body before clearing local cache
  ///
  /// In en, this message translates to:
  /// **'This removes cached posts, profiles, images, feeds, threads, label data, and local semantic search data.\n\nAccounts, settings, drafts, bookmarks, and likes are kept.'**
  String get dialogClearCacheContent;

  /// Confirmation dialog title before clearing local cache
  ///
  /// In en, this message translates to:
  /// **'Clear cache?'**
  String get dialogClearCacheTitle;

  /// Confirmation dialog body before removing a saved account from this device
  ///
  /// In en, this message translates to:
  /// **'Remove @{handle} from this device?'**
  String dialogRemoveAccountContent(String handle);

  /// Confirmation dialog title before removing a saved account
  ///
  /// In en, this message translates to:
  /// **'Remove Account'**
  String get dialogRemoveAccountTitle;

  /// Confirmation dialog body before clearing local sign-in data
  ///
  /// In en, this message translates to:
  /// **'Use this only when troubleshooting sign-in or account switching.\n\nThis clears all local account sessions on this device and sends you back to sign in. It does not delete your Bluesky account or posts.'**
  String get dialogResetSignInDataContent;

  /// Confirmation dialog title before clearing local sign-in data
  ///
  /// In en, this message translates to:
  /// **'Reset sign-in data?'**
  String get dialogResetSignInDataTitle;

  /// Confirmation dialog body before switching AppView provider
  ///
  /// In en, this message translates to:
  /// **'Apply and restart now to rebuild network services.\n\nYou will stay signed in and no local data will be deleted.\n\nModeration labels, ranking, and trending results can differ between providers.'**
  String get dialogSwitchAppViewProviderContent;

  /// Confirmation dialog title before switching AppView provider
  ///
  /// In en, this message translates to:
  /// **'Switch AppView provider?'**
  String get dialogSwitchAppViewProviderTitle;

  /// Snackbar message when persisting selected provider fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save provider selection: {error}'**
  String errorFailedToSaveProviderSelection(Object error);

  /// Snackbar message when cache clearing fails
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cache: {error}'**
  String errorFailedToClearCache(Object error);

  /// Generic error state title
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGenericTitle;

  /// Snackbar message when a saved account cannot be removed
  ///
  /// In en, this message translates to:
  /// **'Unable to remove account right now.'**
  String get errorUnableToRemoveAccount;

  /// Tooltip for removing a saved account
  ///
  /// In en, this message translates to:
  /// **'Remove account'**
  String get labelRemoveAccount;

  /// Settings account row subtitle when multiple accounts are available
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account - tap to switch} other{{count} accounts - tap to switch}}'**
  String formatAccountsTapToSwitch(int count);

  /// Settings subtitle for selected AppView provider
  ///
  /// In en, this message translates to:
  /// **'{provider} selected. Switching providers performs a soft restart.'**
  String formatAppViewProviderSelected(String provider);

  /// Settings subtitle showing the count of subscribed custom moderation labelers
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No custom labelers subscribed} =1{1 custom labeler subscribed} other{{count} custom labelers subscribed}}'**
  String formatContentModerationCustomLabelers(int count);

  /// Thread auto-collapse depth setting option
  ///
  /// In en, this message translates to:
  /// **'Depth {depth}'**
  String formatDepth(int depth);

  /// About page or settings label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get labelAbout;

  /// Account settings section label
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get labelAccount;

  /// Settings section for account maintenance actions
  ///
  /// In en, this message translates to:
  /// **'Account Maintenance'**
  String get labelAccountMaintenance;

  /// Provider diagnostics label for active provider
  ///
  /// In en, this message translates to:
  /// **'Active Provider'**
  String get labelActiveProvider;

  /// Adult content setting label
  ///
  /// In en, this message translates to:
  /// **'Adult Content'**
  String get labelAdultContent;

  /// Advanced settings section label
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get labelAdvanced;

  /// Bottom navigation alerts label
  ///
  /// In en, this message translates to:
  /// **'ALERTS'**
  String get labelAlerts;

  /// Animations settings label
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get labelAnimations;

  /// Appearance settings section label
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get labelAppearance;

  /// Debug app password field label
  ///
  /// In en, this message translates to:
  /// **'App Password'**
  String get labelAppPassword;

  /// Debug app password login card title
  ///
  /// In en, this message translates to:
  /// **'App Password Login'**
  String get labelAppPasswordLogin;

  /// AppView provider settings label
  ///
  /// In en, this message translates to:
  /// **'AppView Provider'**
  String get labelAppViewProvider;

  /// AT Protocol explorer settings/menu label
  ///
  /// In en, this message translates to:
  /// **'AT Explorer'**
  String get labelAtExplorer;

  /// Settings section title for AT Protocol connection details
  ///
  /// In en, this message translates to:
  /// **'AT Protocol Connection'**
  String get labelAtProtocolConnection;

  /// Menu item for follow audit feature
  ///
  /// In en, this message translates to:
  /// **'Audit Follows'**
  String get labelAuditFollows;

  /// Back tooltip label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get labelBack;

  /// Settings item for bookmarked and liked posts
  ///
  /// In en, this message translates to:
  /// **'Bookmarks & Likes'**
  String get labelBookmarksAndLikes;

  /// Snackbar message after clearing cache
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get labelCacheCleared;

  /// Login provider selection label
  ///
  /// In en, this message translates to:
  /// **'Choose your portal'**
  String get labelChooseYourPortal;

  /// Settings item for follow audit feature
  ///
  /// In en, this message translates to:
  /// **'Clean Follows'**
  String get labelCleanFollows;

  /// Settings item for clearing cache
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get labelClearCache;

  /// Community provider option label
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get labelCommunity;

  /// Constellation URL setting label
  ///
  /// In en, this message translates to:
  /// **'Constellation URL'**
  String get labelConstellationUrl;

  /// Content moderation settings label
  ///
  /// In en, this message translates to:
  /// **'Content Moderation'**
  String get labelContentModeration;

  /// Semantic label for continuing sign in
  ///
  /// In en, this message translates to:
  /// **'Continue sign in'**
  String get labelContinueSignIn;

  /// Crash reporting setting label
  ///
  /// In en, this message translates to:
  /// **'Crash Reporting'**
  String get labelCrashReporting;

  /// Developer setting to trigger a test crash
  ///
  /// In en, this message translates to:
  /// **'Crashlytics Test Crash'**
  String get labelCrashlyticsTestCrash;

  /// Cross-provider fallback setting label
  ///
  /// In en, this message translates to:
  /// **'Cross-Provider Fallback'**
  String get labelCrossProviderFallback;

  /// Destructive settings section label
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get labelDangerZone;

  /// Dark theme option label
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get labelDark;

  /// Debug section label
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get labelDebug;

  /// Developer settings section label
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get labelDeveloper;

  /// Feed layout setting label
  ///
  /// In en, this message translates to:
  /// **'Feed Layout'**
  String get labelFeedLayout;

  /// Feeds menu/settings label
  ///
  /// In en, this message translates to:
  /// **'Feeds'**
  String get labelFeeds;

  /// Developer setting to force the next XRPC request to return Unauthorized
  ///
  /// In en, this message translates to:
  /// **'Force Next XRPC 401'**
  String get labelForceNextXrpc401;

  /// Developer setting to simulate offline mode
  ///
  /// In en, this message translates to:
  /// **'Go Offline'**
  String get labelGoOffline;

  /// Fallback account display name when no user is signed in
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get labelGuest;

  /// Provider diagnostics health label
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get labelHealth;

  /// Handle field label
  ///
  /// In en, this message translates to:
  /// **'Handle'**
  String get labelHandle;

  /// Hide button label
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get labelHide;

  /// Bottom navigation home label
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get labelHome;

  /// Provider diagnostics last error label
  ///
  /// In en, this message translates to:
  /// **'Last Error'**
  String get labelLastError;

  /// Provider diagnostics last fallback label
  ///
  /// In en, this message translates to:
  /// **'Last Fallback'**
  String get labelLastFallback;

  /// Provider diagnostics last health check label
  ///
  /// In en, this message translates to:
  /// **'Last Health Check'**
  String get labelLastHealthCheck;

  /// Layout settings section label
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get labelLayout;

  /// Light theme option label
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get labelLight;

  /// Log out button or menu label
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get labelLogOut;

  /// Logs settings label
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get labelLogs;

  /// Messages menu label
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get labelMessages;

  /// Moderation settings section label
  ///
  /// In en, this message translates to:
  /// **'Moderation'**
  String get labelModeration;

  /// Navigation menu section label
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get labelNavigation;

  /// New post menu label
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get labelNewPost;

  /// Notifications menu label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get labelNotifications;

  /// Tooltip for opening the navigation menu
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get labelOpenMenu;

  /// Privacy policy link label
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get labelPrivacyPolicy;

  /// Bottom navigation profile label
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get labelProfile;

  /// Settings section for provider diagnostics
  ///
  /// In en, this message translates to:
  /// **'Provider Diagnostics'**
  String get labelProviderDiagnostics;

  /// Settings item for refreshing provider health
  ///
  /// In en, this message translates to:
  /// **'Refresh Provider Health'**
  String get labelRefreshProviderHealth;

  /// Settings item for resetting local sign-in data
  ///
  /// In en, this message translates to:
  /// **'Reset Sign-In Data'**
  String get labelResetSignInData;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Roam the ATmosphere'**
  String get labelRoamTheAtmosphere;

  /// Search menu/settings label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get labelSearch;

  /// Title for posts-only search mode
  ///
  /// In en, this message translates to:
  /// **'Search Posts'**
  String get labelSearchPosts;

  /// Button and dialog title for jumping directly to a profile
  ///
  /// In en, this message translates to:
  /// **'Jump to profile'**
  String get labelJumpToProfile;

  /// Posts tab label
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get labelPosts;

  /// People tab label
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get labelPeople;

  /// Starter packs tab label
  ///
  /// In en, this message translates to:
  /// **'Starter Packs'**
  String get labelStarterPacks;

  /// Sort control label
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get labelSortBy;

  /// Top sort option label
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get labelTop;

  /// Latest sort option label
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get labelLatest;

  /// Search filters button label
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get labelFilters;

  /// Post filters sheet title
  ///
  /// In en, this message translates to:
  /// **'Post filters'**
  String get labelPostFilters;

  /// Mentions filter label
  ///
  /// In en, this message translates to:
  /// **'Mentions'**
  String get labelMentions;

  /// Author filter label
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get labelAuthor;

  /// Fixed author filter label
  ///
  /// In en, this message translates to:
  /// **'Author (fixed)'**
  String get labelAuthorFixed;

  /// Language filter label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get labelLanguage;

  /// Domain filter label
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get labelDomain;

  /// URL filter label
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get labelUrl;

  /// Tags filter label
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get labelTags;

  /// Since date filter label
  ///
  /// In en, this message translates to:
  /// **'Since'**
  String get labelSince;

  /// Until date filter label
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get labelUntil;

  /// Button label to clear since date filter
  ///
  /// In en, this message translates to:
  /// **'Clear since'**
  String get labelClearSince;

  /// Button label to clear until date filter
  ///
  /// In en, this message translates to:
  /// **'Clear until'**
  String get labelClearUntil;

  /// Saved accounts section label on login screen
  ///
  /// In en, this message translates to:
  /// **'Saved accounts'**
  String get labelSavedAccounts;

  /// Bottom navigation search label
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get labelSearchNav;

  /// Semantic search settings label
  ///
  /// In en, this message translates to:
  /// **'Semantic Search'**
  String get labelSemanticSearch;

  /// Settings page title or tooltip
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get labelSettings;

  /// Show button label
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get labelShow;

  /// Fallback account handle text when sign in is required
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get labelSignInRequired;

  /// Slingshot identity fallback setting label
  ///
  /// In en, this message translates to:
  /// **'Slingshot Identity Fallback'**
  String get labelSlingshotIdentityFallback;

  /// Tooltip while sign in is starting
  ///
  /// In en, this message translates to:
  /// **'Starting sign in'**
  String get labelStartingSignIn;

  /// System theme option label
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get labelSystem;

  /// Terms of service link label
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get labelTermsOfService;

  /// Theme subsection label in settings
  ///
  /// In en, this message translates to:
  /// **'THEME'**
  String get labelTheme;

  /// Thread auto-collapse setting label
  ///
  /// In en, this message translates to:
  /// **'Thread Auto-Collapse'**
  String get labelThreadAutoCollapse;

  /// Troubleshooting settings section label
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get labelTroubleshooting;

  /// Typeahead provider settings label
  ///
  /// In en, this message translates to:
  /// **'Typeahead Provider'**
  String get labelTypeaheadProvider;

  /// Video upload limits settings label
  ///
  /// In en, this message translates to:
  /// **'Video Upload Limits'**
  String get labelVideoUploadLimits;

  /// Debug app password help text
  ///
  /// In en, this message translates to:
  /// **'Can be generated via Bluesky\'\'s App Passwords section at bsky.app.'**
  String get messageAppPasswordGeneratedViaBluesky;

  /// Snackbar message after arming debug unauthorized response
  ///
  /// In en, this message translates to:
  /// **'Armed: next XRPC request will return debug 401 Unauthorized'**
  String get messageAppViewDebug401Armed;

  /// Settings subtitle for Bluesky typeahead provider
  ///
  /// In en, this message translates to:
  /// **'Bluesky official endpoint selected.'**
  String get messageBlueskyEndpointSelected;

  /// Settings subtitle for bookmarks and likes
  ///
  /// In en, this message translates to:
  /// **'View your bookmarked and liked posts'**
  String get messageBookmarksAndLikesSubtitle;

  /// Login screen provider selection helper text
  ///
  /// In en, this message translates to:
  /// **'Choose the AppView provider used for sign in and public reads.'**
  String get messageChooseProviderSubtitle;

  /// Settings subtitle for clean follows
  ///
  /// In en, this message translates to:
  /// **'Audit and unfollow problematic accounts in bulk'**
  String get messageCleanFollowsSubtitle;

  /// Settings subtitle for clearing cache
  ///
  /// In en, this message translates to:
  /// **'Remove cached posts, profiles, images, feeds, threads, and semantic search data'**
  String get messageClearCacheSubtitle;

  /// Settings subtitle for community typeahead provider
  ///
  /// In en, this message translates to:
  /// **'Community (waow.tech) selected. Third-party service.'**
  String get messageCommunityTypeaheadSelected;

  /// Settings subtitle for content moderation
  ///
  /// In en, this message translates to:
  /// **'Manage labelers and visibility rules'**
  String get messageContentModerationSubtitle;

  /// Settings subtitle when adult content preference is enabled
  ///
  /// In en, this message translates to:
  /// **'18+ labels can be configured'**
  String get messageAdultContentEnabled;

  /// Settings subtitle when adult content preference is disabled
  ///
  /// In en, this message translates to:
  /// **'Required before 18+ labels can be configured'**
  String get messageAdultContentRequired;

  /// Settings subtitle when crash reporting is disabled
  ///
  /// In en, this message translates to:
  /// **'Disabled. Crash and error reports are not sent.'**
  String get messageCrashReportingDisabled;

  /// Settings subtitle when crash reporting is enabled
  ///
  /// In en, this message translates to:
  /// **'Enabled. Crash and error reports are sent to improve stability.'**
  String get messageCrashReportingEnabled;

  /// Developer setting subtitle for test crash
  ///
  /// In en, this message translates to:
  /// **'Intentionally crash to validate Crashlytics reports'**
  String get messageCrashlyticsTestCrashSubtitle;

  /// Settings subtitle for cross-provider fallback
  ///
  /// In en, this message translates to:
  /// **'Retry public reads on the alternate AppView when transient errors occur'**
  String get messageCrossProviderFallbackSubtitle;

  /// Developer setting subtitle for simulated offline
  ///
  /// In en, this message translates to:
  /// **'Turn off online connectivity'**
  String get messageDeveloperGoOfflineSubtitle;

  /// Feed layout card option
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get messageFeedLayoutCard;

  /// Loading message while saved accounts load
  ///
  /// In en, this message translates to:
  /// **'Loading saved accounts...'**
  String get messageLoadingSavedAccounts;

  /// Feed layout compact option
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get messageFeedLayoutCompact;

  /// Settings subtitle for feeds
  ///
  /// In en, this message translates to:
  /// **'Manage pinned and saved feeds'**
  String get messageFeedsSubtitle;

  /// Developer setting subtitle for forced 401
  ///
  /// In en, this message translates to:
  /// **'Debug-only: next network request returns Unauthorized to test token refresh'**
  String get messageForceNextXrpc401Subtitle;

  /// Settings subtitle for semantic search management
  ///
  /// In en, this message translates to:
  /// **'Manage semantic search from Bookmarks & Likes -> Search'**
  String get messageManageSemanticSearchSubtitle;

  /// Moderation overlay description when content cannot be revealed
  ///
  /// In en, this message translates to:
  /// **'Hidden by your moderation settings and cannot be revealed here.'**
  String get messageModeratedContentCannotReveal;

  /// Moderation overlay description when content can be revealed
  ///
  /// In en, this message translates to:
  /// **'Hidden by your moderation settings. You can reveal it for this view.'**
  String get messageModeratedContentCanReveal;

  /// Settings subtitle for provider diagnostics
  ///
  /// In en, this message translates to:
  /// **'Moderation/ranking can differ by provider. Verify health and recent fallback state.'**
  String get messageProviderDiagnosticsSubtitle;

  /// Settings subtitle for refreshing provider health
  ///
  /// In en, this message translates to:
  /// **'Probe public AppView endpoints now'**
  String get messageRefreshProviderHealthSubtitle;

  /// Settings subtitle for resetting sign-in data
  ///
  /// In en, this message translates to:
  /// **'Troubleshoot OAuth or account-switching issues by clearing local sessions on this device'**
  String get messageResetSignInDataSubtitle;

  /// Generic search subtitle
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get messageSearchSubtitle;

  /// Confirmation dialog body before clearing search history
  ///
  /// In en, this message translates to:
  /// **'This will delete all your recent searches.'**
  String get messageClearSearchHistoryContent;

  /// Confirmation dialog title before clearing search history
  ///
  /// In en, this message translates to:
  /// **'Clear search history?'**
  String get messageClearSearchHistoryTitle;

  /// Hint shown in jump to profile dialog
  ///
  /// In en, this message translates to:
  /// **'Start typing to search handles.'**
  String get messageStartTypingToSearchHandles;

  /// Helper text when starter pack search is disabled
  ///
  /// In en, this message translates to:
  /// **'Starter pack search is not available in the API yet.'**
  String get messageStarterPackSearchApiUnavailable;

  /// Starter pack search unavailable state title
  ///
  /// In en, this message translates to:
  /// **'Starter Pack Search Is Unavailable'**
  String get messageStarterPackSearchUnavailableTitle;

  /// Starter pack search unavailable state body
  ///
  /// In en, this message translates to:
  /// **'(Starter Pack Search is not yet implemented in the BlueSky API)'**
  String get messageStarterPackSearchUnavailableBody;

  /// Button label to open upstream API issue
  ///
  /// In en, this message translates to:
  /// **'Track API progress'**
  String get messageTrackApiProgress;

  /// Snackbar message when opening upstream issue link fails
  ///
  /// In en, this message translates to:
  /// **'Could not open issue link.'**
  String get messageCouldNotOpenIssueLink;

  /// Search posts field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search posts'**
  String get messageSearchPostsPlaceholder;

  /// Search placeholder in profile posts-only mode
  ///
  /// In en, this message translates to:
  /// **'Search this profile\'\'s posts'**
  String get messageSearchThisProfilesPostsPlaceholder;

  /// Search people field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get messageSearchPeoplePlaceholder;

  /// Search feeds field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search feeds'**
  String get messageSearchFeedsPlaceholder;

  /// Starter pack search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Starter pack search unavailable'**
  String get messageStarterPackSearchUnavailablePlaceholder;

  /// Settings subtitle for Slingshot identity fallback
  ///
  /// In en, this message translates to:
  /// **'If handle lookup fails, use Slingshot to find your DID and PDS so sign-in can continue'**
  String get messageSlingshotIdentityFallbackSubtitle;

  /// Settings subtitle for thread auto-collapse
  ///
  /// In en, this message translates to:
  /// **'Collapse reply branches deeper than the selected level'**
  String get messageThreadAutoCollapseSubtitle;

  /// Settings subtitle for animations
  ///
  /// In en, this message translates to:
  /// **'Turn off non-essential motion effects'**
  String get messageTurnOffNonEssentialMotion;

  /// Settings subtitle for video upload limits
  ///
  /// In en, this message translates to:
  /// **'Check your daily video quota'**
  String get messageVideoUploadLimitsSubtitle;

  /// Placeholder for app password field
  ///
  /// In en, this message translates to:
  /// **'xxxx-xxxx-xxxx-xxxx'**
  String get placeholderAppPassword;

  /// Placeholder for handle or DID sign-in field
  ///
  /// In en, this message translates to:
  /// **'username.bsky.social or did:plc:...'**
  String get placeholderHandleOrDid;

  /// Label for handle or DID sign-in field
  ///
  /// In en, this message translates to:
  /// **'Handle or DID'**
  String get promptHandleOrDid;

  /// Validation error for missing app password
  ///
  /// In en, this message translates to:
  /// **'Enter your app password'**
  String get validationEnterAppPassword;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
