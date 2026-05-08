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

  /// Button label to clear locally stored items
  ///
  /// In en, this message translates to:
  /// **'Clear Local'**
  String get buttonClearLocal;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// Discard button label
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get buttonDiscard;

  /// Button label to load additional quote posts
  ///
  /// In en, this message translates to:
  /// **'Load more quotes'**
  String get buttonLoadMoreQuotes;

  /// Button label to load additional repost users
  ///
  /// In en, this message translates to:
  /// **'Load more reposts'**
  String get buttonLoadMoreReposts;

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

  /// OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// Button label to publish a post
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get buttonPost;

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

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// Button label to save post edits
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get buttonSaveChanges;

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

  /// Share button or menu label
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get buttonShare;

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

  /// Lowercase relative time label for the current moment
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get commonNow;

  /// Relative time label for the current moment
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get commonJustNow;

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

  /// Confirmation dialog body before clearing local bookmarks
  ///
  /// In en, this message translates to:
  /// **'This removes only local bookmarks from this device. Bluesky cloud bookmarks will not be deleted.'**
  String get dialogClearLocalBookmarksContent;

  /// Confirmation dialog title before clearing local bookmarks
  ///
  /// In en, this message translates to:
  /// **'Clear local bookmarks?'**
  String get dialogClearLocalBookmarksTitle;

  /// Confirmation dialog body before deleting a post
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get dialogDeletePostContent;

  /// Confirmation dialog title before deleting a post
  ///
  /// In en, this message translates to:
  /// **'Delete Post?'**
  String get dialogDeletePostTitle;

  /// Confirmation dialog title before deleting a draft
  ///
  /// In en, this message translates to:
  /// **'Delete Draft?'**
  String get dialogDeleteDraftTitle;

  /// Confirmation dialog body before leaving unsaved post edits
  ///
  /// In en, this message translates to:
  /// **'You have unsaved edits. Discard them and leave?'**
  String get dialogDiscardChangesContent;

  /// Confirmation dialog title before leaving unsaved post edits
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get dialogDiscardChangesTitle;

  /// Information dialog body explaining how post editing is implemented
  ///
  /// In en, this message translates to:
  /// **'Lazurite saves edits by deleting and recreating the post record with the same URI. During re-indexing, ranking, counters, and search visibility can shift, and updates may take time to appear everywhere.'**
  String get dialogEditAlgorithmContent;

  /// Information dialog title explaining how post editing works
  ///
  /// In en, this message translates to:
  /// **'How Post Editing Works'**
  String get dialogEditAlgorithmTitle;

  /// Confirmation dialog body before leaving compose with unsaved content
  ///
  /// In en, this message translates to:
  /// **'You have unsaved content. Would you like to save it as a draft?'**
  String get dialogSaveDraftContent;

  /// Confirmation dialog title before leaving compose with unsaved content
  ///
  /// In en, this message translates to:
  /// **'Save Draft?'**
  String get dialogSaveDraftTitle;

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

  /// Error title shown when bookmarks cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load bookmarks'**
  String get errorFailedToLoadBookmarks;

  /// Error title shown when liked posts cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load liked posts'**
  String get errorFailedToLoadLikedPosts;

  /// Error message shown when liked posts cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load liked posts: {error}'**
  String errorFailedToLoadLikedPostsDetails(Object error);

  /// Warning message shown when refreshing liked posts fails
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh liked posts: {error}'**
  String errorFailedToRefreshLikedPosts(Object error);

  /// Error title shown when trending content cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load trending'**
  String get errorFailedToLoadTrending;

  /// Error message shown when trending topics cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load trending topics: {error}'**
  String errorFailedToLoadTrendingTopics(Object error);

  /// Fallback message when an error has no details
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get errorUnknown;

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

  /// Fallback liked-post card subtitle showing when a post was liked
  ///
  /// In en, this message translates to:
  /// **'Liked on {date}'**
  String formatLikedOn(String date);

  /// Interaction sheet tab label showing like count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Like} other{{count} Likes}}'**
  String formatLikesCount(int count);

  /// Message explaining that a post action requires reconnecting
  ///
  /// In en, this message translates to:
  /// **'You are offline. Reconnect to {action}.'**
  String formatOfflineReconnectAction(String action);

  /// Post card reply context label showing the parent post author
  ///
  /// In en, this message translates to:
  /// **'Replying to @{handle}'**
  String formatReplyingToHandle(String handle);

  /// Interaction sheet tab label showing repost count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Repost} other{{count} Reposts}}'**
  String formatRepostsCount(int count);

  /// Fallback saved-post card subtitle showing when a post was saved
  ///
  /// In en, this message translates to:
  /// **'Saved on {date}'**
  String formatSavedOn(String date);

  /// Trending topic category subtitle line
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String formatTrendingCategory(String category);

  /// Trending topic post count subtitle line
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 post} other{{count} posts}}'**
  String formatTrendingPostCount(int count);

  /// Post overflow action label to view an author profile
  ///
  /// In en, this message translates to:
  /// **'View @{handle}'**
  String formatViewHandle(String handle);

  /// Snackbar message when the image picker fails
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String formatComposeFailedToPickImage(Object error);

  /// Snackbar message when the video picker fails
  ///
  /// In en, this message translates to:
  /// **'Failed to pick video: {error}'**
  String formatComposeFailedToPickVideo(Object error);

  /// Compose error message when saving edits fails with details
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes: {error}'**
  String formatComposeFailedToSaveChanges(Object error);

  /// Compose error message when post submission fails with details
  ///
  /// In en, this message translates to:
  /// **'Failed to submit post: {error}'**
  String formatComposeFailedToSubmitPost(Object error);

  /// Compose validation error when an attached image is too large
  ///
  /// In en, this message translates to:
  /// **'Image \"{fileName}\" is {sizeMb} MB - max 1 MB.'**
  String formatComposeImageTooLarge(String fileName, String sizeMb);

  /// Compose quote preview label with the quoted author's handle
  ///
  /// In en, this message translates to:
  /// **'Quoting @{handle}'**
  String formatComposeQuotingHandle(String handle);

  /// Compose scheduled post pill label
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {dateTime}'**
  String formatComposeScheduledFor(String dateTime);

  /// Video attachment status when ready and alt text exists
  ///
  /// In en, this message translates to:
  /// **'Ready - \"{altText}\"'**
  String formatComposeVideoReadyWithAltText(String altText);

  /// Compose validation error when a video is too large
  ///
  /// In en, this message translates to:
  /// **'Video is {sizeMb} MB - exceeds the 100 MB limit.'**
  String formatComposeVideoTooLarge(String sizeMb);

  /// Compose drafts panel count label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 draft} other{{count} drafts}}'**
  String formatDraftCount(int count);

  /// Offline action phrase for liking a post
  ///
  /// In en, this message translates to:
  /// **'like this post'**
  String get actionLikeThisPost;

  /// Offline action phrase for replying to a post
  ///
  /// In en, this message translates to:
  /// **'reply to this post'**
  String get actionReplyToThisPost;

  /// Offline action phrase for reposting a post
  ///
  /// In en, this message translates to:
  /// **'repost this post'**
  String get actionRepostThisPost;

  /// Offline action phrase for publishing a post
  ///
  /// In en, this message translates to:
  /// **'publish your post'**
  String get actionPublishYourPost;

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

  /// Tooltip for bookmark actions menu
  ///
  /// In en, this message translates to:
  /// **'Bookmark actions'**
  String get labelBookmarkActions;

  /// Fallback saved-post card title
  ///
  /// In en, this message translates to:
  /// **'Bookmarked Post'**
  String get labelBookmarkedPost;

  /// Bookmarks tab label
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get labelBookmarks;

  /// Bluesky source tab label
  ///
  /// In en, this message translates to:
  /// **'Bluesky'**
  String get labelBluesky;

  /// Short all-caps label for media alt text controls
  ///
  /// In en, this message translates to:
  /// **'ALT'**
  String get labelAlt;

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

  /// Close button tooltip
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get labelClose;

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

  /// Uppercase compact relative time label for the current moment
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get labelNow;

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

  /// Bookmark menu item to clear local bookmarks
  ///
  /// In en, this message translates to:
  /// **'Clear local bookmarks'**
  String get labelClearLocalBookmarks;

  /// Post overflow menu item to copy a post link
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get labelCopyLink;

  /// Post overflow menu item to delete a post
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get labelDeletePost;

  /// Tooltip for deleting a draft
  ///
  /// In en, this message translates to:
  /// **'Delete draft'**
  String get labelDeleteDraft;

  /// Post overflow menu item to edit a post
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get labelEditPost;

  /// Liked posts tab label
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get labelLiked;

  /// Post interactions sheet section label for users who liked a post
  ///
  /// In en, this message translates to:
  /// **'LIKED BY'**
  String get labelLikedBy;

  /// Fallback liked-post card title
  ///
  /// In en, this message translates to:
  /// **'Liked Post'**
  String get labelLikedPost;

  /// Tooltip for opening more information
  ///
  /// In en, this message translates to:
  /// **'More info'**
  String get labelMoreInfo;

  /// Local saved-post source tab label
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get labelLocal;

  /// Tooltip to open a post
  ///
  /// In en, this message translates to:
  /// **'Open post'**
  String get labelOpenPost;

  /// Post action label to quote a post
  ///
  /// In en, this message translates to:
  /// **'Quote Post'**
  String get labelQuotePost;

  /// Heading for quote and repost bottom sheet
  ///
  /// In en, this message translates to:
  /// **'QUOTE / REPOSTS'**
  String get labelQuoteReposts;

  /// Quotes section title
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get labelQuotes;

  /// Post save menu item to remove a cloud bookmark
  ///
  /// In en, this message translates to:
  /// **'Remove from Bluesky'**
  String get labelRemoveFromBluesky;

  /// Post save menu item to remove a local bookmark
  ///
  /// In en, this message translates to:
  /// **'Remove local save'**
  String get labelRemoveLocalSave;

  /// Post overflow menu item to report a post
  ///
  /// In en, this message translates to:
  /// **'Report Post'**
  String get labelReportPost;

  /// Post action label to repost a post
  ///
  /// In en, this message translates to:
  /// **'Repost'**
  String get labelRepost;

  /// Post interactions sheet section label for users who reposted a post
  ///
  /// In en, this message translates to:
  /// **'REPOSTED BY'**
  String get labelRepostedBy;

  /// Reposts section title
  ///
  /// In en, this message translates to:
  /// **'Reposts'**
  String get labelReposts;

  /// Image context menu item to save an image
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get labelSaveImage;

  /// Post save menu item to create a local bookmark
  ///
  /// In en, this message translates to:
  /// **'Save locally'**
  String get labelSaveLocally;

  /// Post save menu item to create a cloud bookmark
  ///
  /// In en, this message translates to:
  /// **'Save to Bluesky'**
  String get labelSaveToBluesky;

  /// Compose toolbar schedule button tooltip
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get labelSchedule;

  /// Scheduled draft badge label
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get labelScheduled;

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

  /// Post overflow menu item to open users who liked a post
  ///
  /// In en, this message translates to:
  /// **'Show Liked Users'**
  String get labelShowLikedUsers;

  /// Post overflow menu item to open quote and repost lists
  ///
  /// In en, this message translates to:
  /// **'Show Quote/Repost List'**
  String get labelShowQuoteRepostList;

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

  /// Fallback video label
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get labelVideo;

  /// Trending topics section label
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get labelTopics;

  /// Trending screen title and tooltip label
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get labelTrending;

  /// Trending suggested topics section label
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get labelSuggested;

  /// Post action label to undo a repost
  ///
  /// In en, this message translates to:
  /// **'Unrepost'**
  String get labelUnrepost;

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

  /// Snackbar message after copying a post link
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get messageLinkCopiedToClipboard;

  /// Loading message while trending topics load
  ///
  /// In en, this message translates to:
  /// **'Loading trending topics'**
  String get messageLoadingTrendingTopics;

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

  /// Trending banner shown when supplemental metadata cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Metadata temporarily unavailable'**
  String get messageMetadataTemporarilyUnavailable;

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

  /// Message shown when liked posts dependencies are unavailable
  ///
  /// In en, this message translates to:
  /// **'Liked posts are unavailable right now.'**
  String get messageLikedPostsUnavailable;

  /// Snackbar message after post edits are saved
  ///
  /// In en, this message translates to:
  /// **'Changes saved.'**
  String get messageChangesSaved;

  /// Tooltip for adding video alt text
  ///
  /// In en, this message translates to:
  /// **'Add alt text'**
  String get messageComposeAddAltText;

  /// Compose toolbar add image tooltip
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get messageComposeAddImage;

  /// Compose toolbar add video tooltip
  ///
  /// In en, this message translates to:
  /// **'Add video'**
  String get messageComposeAddVideo;

  /// Tooltip for clearing scheduled compose time
  ///
  /// In en, this message translates to:
  /// **'Clear scheduled time'**
  String get messageComposeClearScheduledTime;

  /// Image alt text field placeholder
  ///
  /// In en, this message translates to:
  /// **'Describe the image'**
  String get messageComposeDescribeImage;

  /// Video alt text field placeholder
  ///
  /// In en, this message translates to:
  /// **'Describe the video'**
  String get messageComposeDescribeVideo;

  /// Snackbar message after saving a draft
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get messageComposeDraftSaved;

  /// Compose drafts panel title and toolbar tooltip
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get messageComposeDrafts;

  /// Compose edit mode notice banner
  ///
  /// In en, this message translates to:
  /// **'Edits are saved by replacing the record while keeping this post URI. Ranking, counts, and visibility may shift while networks re-index.'**
  String get messageComposeEditNotice;

  /// Image alt text dialog title
  ///
  /// In en, this message translates to:
  /// **'Alt text'**
  String get messageComposeImageAltTextTitle;

  /// Compose validation message when too many images are attached
  ///
  /// In en, this message translates to:
  /// **'Maximum 4 images allowed'**
  String get messageComposeImageMaxCount;

  /// Compose validation message for unsupported image extensions
  ///
  /// In en, this message translates to:
  /// **'Image must be JPEG, PNG, or WebP'**
  String get messageComposeImageMustBeJpegPngWebp;

  /// Compose validation message for image picker size validation
  ///
  /// In en, this message translates to:
  /// **'Image must be smaller than 1MB'**
  String get messageComposeImageMustBeUnder1Mb;

  /// Empty state text in compose drafts panel
  ///
  /// In en, this message translates to:
  /// **'No drafts saved'**
  String get messageComposeNoDraftsSaved;

  /// Fallback draft content label when a draft has no text
  ///
  /// In en, this message translates to:
  /// **'(No text)'**
  String get messageComposeNoText;

  /// Compose text field placeholder
  ///
  /// In en, this message translates to:
  /// **'What\'\'s on your mind?'**
  String get messageComposePlaceholder;

  /// Video alt text preview unavailable message
  ///
  /// In en, this message translates to:
  /// **'Preview unavailable'**
  String get messageComposePreviewUnavailable;

  /// Compose quote preview label without an author handle
  ///
  /// In en, this message translates to:
  /// **'Quoting post'**
  String get messageComposeQuotingPost;

  /// Compose validation message when a video cannot be added because other media exists
  ///
  /// In en, this message translates to:
  /// **'Remove existing media before adding a video'**
  String get messageComposeRemoveExistingMediaBeforeVideo;

  /// Tooltip for removing an image attachment
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get messageComposeRemoveImage;

  /// Tooltip for removing a quoted post from compose
  ///
  /// In en, this message translates to:
  /// **'Remove quoted post'**
  String get messageComposeRemoveQuotedPost;

  /// Compose toolbar save draft tooltip
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get messageComposeSaveDraft;

  /// Video alt text dialog title
  ///
  /// In en, this message translates to:
  /// **'Video alt text'**
  String get messageComposeVideoAltTextTitle;

  /// Video attachment status while checking upload limits
  ///
  /// In en, this message translates to:
  /// **'Checking upload limits...'**
  String get messageVideoCheckingUploadLimits;

  /// Video upload validation message when the daily limit is reached
  ///
  /// In en, this message translates to:
  /// **'Daily video upload limit reached.'**
  String get messageVideoDailyUploadLimitReached;

  /// Video attachment processing status
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get messageVideoProcessing;

  /// Video attachment error when processing fails
  ///
  /// In en, this message translates to:
  /// **'Video processing failed.'**
  String get messageVideoProcessingFailed;

  /// Video attachment error when processing times out
  ///
  /// In en, this message translates to:
  /// **'Video processing timed out.'**
  String get messageVideoProcessingTimedOut;

  /// Video attachment ready status
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get messageVideoReady;

  /// Video attachment ready-to-upload status
  ///
  /// In en, this message translates to:
  /// **'Ready to upload'**
  String get messageVideoReadyToUpload;

  /// Video upload generic failure message
  ///
  /// In en, this message translates to:
  /// **'Upload failed - please try again.'**
  String get messageVideoUploadFailed;

  /// Video attachment uploading status
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get messageVideoUploading;

  /// Compose edit error when the post changed remotely
  ///
  /// In en, this message translates to:
  /// **'This post was changed elsewhere. Reopen it and try editing again.'**
  String get errorComposeChangedElsewhere;

  /// Compose edit error when an edit cannot be confirmed
  ///
  /// In en, this message translates to:
  /// **'Edit was submitted but could not be confirmed yet. Please reopen the post and verify.'**
  String get errorComposeCouldNotConfirmEdit;

  /// Compose edit recovery error when save and recovery status are unknown
  ///
  /// In en, this message translates to:
  /// **'Could not save changes and we could not confirm recovery. Reopen the thread and verify the post.'**
  String get errorComposeCouldNotSaveAndConfirmRecovery;

  /// Compose edit validation error when edit context is missing
  ///
  /// In en, this message translates to:
  /// **'Edit context is missing. Please reopen the editor and try again.'**
  String get errorComposeEditContextMissing;

  /// Compose error when creating a post fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create post. Please try again.'**
  String get errorComposeFailedToCreatePost;

  /// Compose error when saving post edits fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes. Please try again.'**
  String get errorComposeFailedToSaveChanges;

  /// Compose error when image upload fails
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image. Please try again.'**
  String get errorComposeFailedToUploadImage;

  /// Compose error when an attached image file is missing
  ///
  /// In en, this message translates to:
  /// **'Image file not found. Please re-attach and try again.'**
  String get errorComposeImageFileNotFound;

  /// Compose error when submission fails and is saved as a draft
  ///
  /// In en, this message translates to:
  /// **'Network error - post saved as draft.'**
  String get errorComposeNetworkSavedAsDraft;

  /// Compose edit error when the original post was restored after failure
  ///
  /// In en, this message translates to:
  /// **'Could not save changes. Your original post was restored.'**
  String get errorComposeOriginalPostRestored;

  /// Compose validation error for unsupported image bytes
  ///
  /// In en, this message translates to:
  /// **'Unsupported image format. Use JPEG, PNG, or WebP.'**
  String get errorComposeUnsupportedImageFormat;

  /// Empty state title when there are no bookmarks
  ///
  /// In en, this message translates to:
  /// **'No bookmarks'**
  String get messageNoBookmarks;

  /// Empty state subtitle when there are no bookmarks
  ///
  /// In en, this message translates to:
  /// **'Posts you bookmark will appear here'**
  String get messageNoBookmarksSubtitle;

  /// Empty state title when a bookmark source tab is empty
  ///
  /// In en, this message translates to:
  /// **'No bookmarks in this source'**
  String get messageNoBookmarksInSource;

  /// Empty state subtitle when a bookmark source tab is empty
  ///
  /// In en, this message translates to:
  /// **'Try switching tabs or saving posts to this source'**
  String get messageNoBookmarksInSourceSubtitle;

  /// Empty state message when a post has no likes or reposts
  ///
  /// In en, this message translates to:
  /// **'No interactions yet'**
  String get messageNoInteractionsYet;

  /// Empty state title when there are no liked posts
  ///
  /// In en, this message translates to:
  /// **'No liked posts'**
  String get messageNoLikedPosts;

  /// Empty state subtitle when there are no liked posts
  ///
  /// In en, this message translates to:
  /// **'Posts you like will appear here after sync'**
  String get messageNoLikedPostsSubtitle;

  /// Empty state message when a post has no quote posts
  ///
  /// In en, this message translates to:
  /// **'No quotes yet'**
  String get messageNoQuotesYet;

  /// Empty state message when a post has no reposts
  ///
  /// In en, this message translates to:
  /// **'No reposts yet'**
  String get messageNoRepostsYet;

  /// Empty state message when there are no trending topics
  ///
  /// In en, this message translates to:
  /// **'No trending topics right now'**
  String get messageNoTrendingTopicsRightNow;

  /// Snackbar message after deleting a post
  ///
  /// In en, this message translates to:
  /// **'Post deleted'**
  String get messagePostDeleted;

  /// Post action subtitle for quote post
  ///
  /// In en, this message translates to:
  /// **'Quote this post with your own text'**
  String get messageQuotePostSubtitle;

  /// Quoted embed unavailable message for blocked quoted posts
  ///
  /// In en, this message translates to:
  /// **'Quoted post is blocked'**
  String get messageQuotedPostBlocked;

  /// Quoted embed unavailable message for missing quoted posts
  ///
  /// In en, this message translates to:
  /// **'Quoted post not found'**
  String get messageQuotedPostNotFound;

  /// Quoted embed unavailable message for detached or unavailable quoted posts
  ///
  /// In en, this message translates to:
  /// **'Quoted post is unavailable'**
  String get messageQuotedPostUnavailable;

  /// Post action subtitle for removing a repost
  ///
  /// In en, this message translates to:
  /// **'Remove this repost'**
  String get messageRemoveRepostSubtitle;

  /// Post card reply context label when parent post details are unavailable
  ///
  /// In en, this message translates to:
  /// **'Reply in a thread'**
  String get messageReplyInThread;

  /// Compose reply banner prefix before the replied-to handle
  ///
  /// In en, this message translates to:
  /// **'Replying to'**
  String get messageReplyingTo;

  /// Post action subtitle for reposting a post
  ///
  /// In en, this message translates to:
  /// **'Share this post'**
  String get messageShareThisPostSubtitle;

  /// Post overflow subtitle for viewing users who liked a post
  ///
  /// In en, this message translates to:
  /// **'View who liked this post'**
  String get messageShowLikedUsersSubtitle;

  /// Post overflow subtitle for viewing quotes and reposts
  ///
  /// In en, this message translates to:
  /// **'View quote posts and expand reposts'**
  String get messageShowQuoteRepostListSubtitle;

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
