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

  /// Tooltip for composing a post
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get buttonCompose;

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

  /// Button label to copy an in-app crash report
  ///
  /// In en, this message translates to:
  /// **'Copy report'**
  String get buttonCopyReport;

  /// Clear all filters button label
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get buttonClearAll;

  /// Button label to open an email draft for an in-app crash report
  ///
  /// In en, this message translates to:
  /// **'Email report'**
  String get buttonEmailReport;

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

  /// Lowercase fallback for an unknown value
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get commonUnknown;

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

  /// Settings font size dropdown option with display label and numeric point size
  ///
  /// In en, this message translates to:
  /// **'{label} ({size})'**
  String formatFontSizeOption(String label, int size);

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

  /// Post card context label shown before a reposter profile link
  ///
  /// In en, this message translates to:
  /// **'Reposted by'**
  String get labelRepostedByCard;

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

  /// Explains that an over-limit scheduled compose will publish as a thread
  ///
  /// In en, this message translates to:
  /// **'This will publish as a thread of {count, plural, =1{1 post} other{{count} posts}}.'**
  String formatComposeScheduledThreadPreview(int count);

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

  /// Settings item for account-level preferences
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get labelAccountSettings;

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

  /// Blacksky provider option label
  ///
  /// In en, this message translates to:
  /// **'Blacksky'**
  String get labelBlacksky;

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

  /// Settings label for code font selection
  ///
  /// In en, this message translates to:
  /// **'Code Font'**
  String get labelCodeFont;

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

  /// Settings label for content font selection
  ///
  /// In en, this message translates to:
  /// **'Content Font'**
  String get labelContentFont;

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

  /// Developer setting to trigger a recoverable Flutter crash report screen
  ///
  /// In en, this message translates to:
  /// **'Crash Report Screen Test'**
  String get labelCrashReportScreenTest;

  /// Crash report section title for the error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get labelCrashReportError;

  /// Crash report section title for related app logs
  ///
  /// In en, this message translates to:
  /// **'Relevant logs'**
  String get labelCrashReportRelevantLogs;

  /// Crash report section title for the stack trace
  ///
  /// In en, this message translates to:
  /// **'Stack trace'**
  String get labelCrashReportStackTrace;

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

  /// Settings label for content font size selection
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get labelFontSize;

  /// Small content font size option label
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get labelFontSizeSmall;

  /// Normal content font size option label
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get labelFontSizeNormal;

  /// Large content font size option label
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get labelFontSizeLarge;

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

  /// Settings label for heading font selection
  ///
  /// In en, this message translates to:
  /// **'Heading Font'**
  String get labelHeadingFont;

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

  /// Suggested follows sheet and menu label
  ///
  /// In en, this message translates to:
  /// **'Suggested Follows'**
  String get labelSuggestedFollows;

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

  /// Settings subtitle for the about page
  ///
  /// In en, this message translates to:
  /// **'Stormlight Labs'**
  String get messageAboutSubtitle;

  /// Settings subtitle for account-level preferences
  ///
  /// In en, this message translates to:
  /// **'Feed display preferences and account defaults'**
  String get messageAccountSettingsSubtitle;

  /// Debug app password help text
  ///
  /// In en, this message translates to:
  /// **'Can be generated via Bluesky\'\'s App Passwords section at bsky.app.'**
  String get messageAppPasswordGeneratedViaBluesky;

  /// Settings subtitle for AT Explorer
  ///
  /// In en, this message translates to:
  /// **'View PDS Records'**
  String get messageAtExplorerSubtitle;

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

  /// Developer setting subtitle for testing the in-app crash report screen
  ///
  /// In en, this message translates to:
  /// **'Open a recoverable Flutter error screen with copy and email actions'**
  String get messageCrashReportScreenTestSubtitle;

  /// Snackbar message after copying a crash report
  ///
  /// In en, this message translates to:
  /// **'Crash report copied'**
  String get messageCrashReportCopied;

  /// Instructions shown on the in-app crash report screen
  ///
  /// In en, this message translates to:
  /// **'You can copy the crash report or open an email to send a summary to Stormlight Labs.'**
  String get messageCrashReportInstructions;

  /// Message shown when the in-app crash report could not load all diagnostics
  ///
  /// In en, this message translates to:
  /// **'Some report details could not be loaded. A minimal report is still available.'**
  String get messageCrashReportPartial;

  /// Marker appended when a crash report stack trace is shortened for an email draft
  ///
  /// In en, this message translates to:
  /// **'[Stack trace truncated for email]'**
  String get messageCrashReportEmailStackTraceTruncated;

  /// Email body for an in-app crash report. Keep this compact because it is encoded into a mailto URL.
  ///
  /// In en, this message translates to:
  /// **'A Lazurite screen crashed.\n\nThe full report may be too large for email. Please use Copy report in the app if support asks for the full details.\n\nError:\n{error}\n\nStack trace:\n{stackTrace}'**
  String formatCrashReportEmailBody(String error, String stackTrace);

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

  /// Feed layout comfortable option
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get messageFeedLayoutComfortable;

  /// Loading message while saved accounts load
  ///
  /// In en, this message translates to:
  /// **'Loading saved accounts...'**
  String get messageLoadingSavedAccounts;

  /// Crash report message when there are no relevant log lines
  ///
  /// In en, this message translates to:
  /// **'No recent log lines were available.'**
  String get messageNoRecentLogLinesAvailable;

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
  /// **'Manage searching your bookmarks & saved posts.'**
  String get messageManageSemanticSearchSubtitle;

  /// Settings subtitle for opening app logs
  ///
  /// In en, this message translates to:
  /// **'View app log files'**
  String get messageLogsSubtitle;

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

  /// Settings subtitle for the privacy policy
  ///
  /// In en, this message translates to:
  /// **'How Lazurite handles data'**
  String get messagePrivacyPolicySubtitle;

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

  /// Empty state when a profile has no liked posts
  ///
  /// In en, this message translates to:
  /// **'No liked posts yet'**
  String get messageNoLikedPostsYet;

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

  /// Search field placeholder when adding list members
  ///
  /// In en, this message translates to:
  /// **'Search for people'**
  String get messageSearchForPeoplePlaceholder;

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

  /// Settings subtitle for the terms of service
  ///
  /// In en, this message translates to:
  /// **'Usage rules and responsibilities'**
  String get messageTermsOfServiceSubtitle;

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

  /// Button label to add a feed
  ///
  /// In en, this message translates to:
  /// **'Add feed'**
  String get buttonAddFeed;

  /// Button label to add members to a list
  ///
  /// In en, this message translates to:
  /// **'Add members'**
  String get buttonAddMembers;

  /// Button label to block an account
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get buttonBlock;

  /// Create button label
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get buttonCreate;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// Button label to follow an account
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get buttonFollow;

  /// Button label to follow all starter pack members
  ///
  /// In en, this message translates to:
  /// **'Follow all'**
  String get buttonFollowAll;

  /// Button label showing that an account is followed
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get buttonFollowing;

  /// Button label while following all starter pack members
  ///
  /// In en, this message translates to:
  /// **'Following…'**
  String get buttonFollowingInProgress;

  /// Button label to load more results
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get buttonLoadMore;

  /// Button label to mute an account or list
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get buttonMute;

  /// Button label to start a follow audit scan
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get buttonScan;

  /// Button label to view all items
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get buttonSeeAll;

  /// Button label to reveal blocked-by accounts
  ///
  /// In en, this message translates to:
  /// **'Show accounts'**
  String get buttonShowAccounts;

  /// Button label to submit a moderation report
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get buttonSubmitReport;

  /// Button label to unblock an account
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get buttonUnblock;

  /// Button label to unfollow an account
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get buttonUnfollow;

  /// Button label to unfollow selected audit results
  ///
  /// In en, this message translates to:
  /// **'Unfollow Selected ({count})'**
  String buttonUnfollowSelected(int count);

  /// Button label to unmute an account or list
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get buttonUnmute;

  /// Confirmation dialog body before blocking an account
  ///
  /// In en, this message translates to:
  /// **'They will not be able to see your posts or interact with you. They will not be notified that you blocked them.'**
  String get dialogBlockAccountContent;

  /// Confirmation dialog title before blocking an account
  ///
  /// In en, this message translates to:
  /// **'Block Account?'**
  String get dialogBlockAccountTitle;

  /// Confirmation dialog title before deleting a list
  ///
  /// In en, this message translates to:
  /// **'Delete list?'**
  String get dialogDeleteListTitle;

  /// Confirmation dialog body before deleting a starter pack
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this starter pack and its backing list. This cannot be undone.'**
  String get dialogDeleteStarterPackContent;

  /// Confirmation dialog title before deleting a starter pack
  ///
  /// In en, this message translates to:
  /// **'Delete starter pack'**
  String get dialogDeleteStarterPackTitle;

  /// Confirmation dialog body before muting an account
  ///
  /// In en, this message translates to:
  /// **'You will no longer see their posts or receive notifications from them.'**
  String get dialogMuteAccountContent;

  /// Confirmation dialog title before muting an account
  ///
  /// In en, this message translates to:
  /// **'Mute Account?'**
  String get dialogMuteAccountTitle;

  /// Confirmation dialog body before unblocking an account
  ///
  /// In en, this message translates to:
  /// **'They will be able to see your posts and interact with you again.'**
  String get dialogUnblockAccountContent;

  /// Confirmation dialog title before unblocking an account
  ///
  /// In en, this message translates to:
  /// **'Unblock Account?'**
  String get dialogUnblockAccountTitle;

  /// Confirmation dialog body before unfollowing an account
  ///
  /// In en, this message translates to:
  /// **'You will no longer see their posts in your feed.'**
  String get dialogUnfollowAccountContent;

  /// Confirmation dialog title before unfollowing an account
  ///
  /// In en, this message translates to:
  /// **'Unfollow?'**
  String get dialogUnfollowAccountTitle;

  /// Confirmation dialog body before unmuting an account
  ///
  /// In en, this message translates to:
  /// **'You will see their posts and receive notifications again.'**
  String get dialogUnmuteAccountContent;

  /// Confirmation dialog title before unmuting an account
  ///
  /// In en, this message translates to:
  /// **'Unmute Account?'**
  String get dialogUnmuteAccountTitle;

  /// Error message when starter pack creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create starter pack'**
  String get errorFailedToCreateStarterPack;

  /// Error message when accounts cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load accounts'**
  String get errorFailedToLoadAccounts;

  /// Error message when a list feed cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load feed'**
  String get errorFailedToLoadFeed;

  /// Error message when feed picker suggestions cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load feeds'**
  String get errorFailedToLoadFeeds;

  /// Error message when a list cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load list'**
  String get errorFailedToLoadList;

  /// Error message when lists cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load lists'**
  String get errorFailedToLoadLists;

  /// Error message when list members cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load members'**
  String get errorFailedToLoadMembers;

  /// Error message when loading more results fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load more'**
  String get errorFailedToLoadMore;

  /// Error message when posts cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load posts'**
  String get errorFailedToLoadPosts;

  /// Error title when a profile cannot load
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get errorFailedToLoadProfile;

  /// Error message when a starter pack cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load starter pack'**
  String get errorFailedToLoadStarterPack;

  /// Error message when starter packs cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load starter packs'**
  String get errorFailedToLoadStarterPacks;

  /// Error title when suggested follows cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load suggestions'**
  String get errorFailedToLoadSuggestions;

  /// Error message when follow audit fails
  ///
  /// In en, this message translates to:
  /// **'Failed to complete follow audit.'**
  String get errorFollowAuditFailed;

  /// Validation error when a profile image is too large
  ///
  /// In en, this message translates to:
  /// **'Image must be smaller than 1MB'**
  String get errorImageTooLarge;

  /// Validation error when profile image file type is unsupported
  ///
  /// In en, this message translates to:
  /// **'Use a JPEG or PNG image'**
  String get errorInvalidProfileImageType;

  /// Error when a selected profile image cannot be read
  ///
  /// In en, this message translates to:
  /// **'Unable to read selected image'**
  String get errorProfileImageReadFailed;

  /// Report submission failure dialog body
  ///
  /// In en, this message translates to:
  /// **'Unable to submit your report. Please try again later.'**
  String get errorReportFailed;

  /// Report submission failure dialog title
  ///
  /// In en, this message translates to:
  /// **'Report Failed'**
  String get errorReportFailedTitle;

  /// Error title when a profile connection tab cannot load
  ///
  /// In en, this message translates to:
  /// **'Unable to load {tab}'**
  String errorUnableToLoadConnections(String tab);

  /// Snackbar message when profile update fails
  ///
  /// In en, this message translates to:
  /// **'Unable to update profile'**
  String get errorUnableToUpdateProfile;

  /// Count of accounts
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account} other{{count} accounts}}'**
  String formatAccountCount(int count);

  /// Message when blocked-by account count exists but profiles are unavailable
  ///
  /// In en, this message translates to:
  /// **'Found {count, plural, =1{1 blocked-by account} other{{count} blocked-by accounts}}, but public Bluesky profile details could not be loaded.'**
  String formatBlockedByAccountsUnavailable(int count);

  /// Loading message for a profile connection tab
  ///
  /// In en, this message translates to:
  /// **'Loading {tab}...'**
  String formatConnectionsLoading(String tab);

  /// Empty search message for a profile connection tab
  ///
  /// In en, this message translates to:
  /// **'No {tab} match \"{query}\"'**
  String formatConnectionsNoMatches(String tab, String query);

  /// Empty message for a profile connection tab
  ///
  /// In en, this message translates to:
  /// **'No {tab} found'**
  String formatConnectionsNoneFound(String tab);

  /// Search progress message for profile connections
  ///
  /// In en, this message translates to:
  /// **'Searching {count} accounts...'**
  String formatConnectionsSearching(int count);

  /// Completed search progress message for profile connections
  ///
  /// In en, this message translates to:
  /// **'Searched {count} accounts'**
  String formatConnectionsSearched(int count);

  /// Stopped search progress message for profile connections
  ///
  /// In en, this message translates to:
  /// **'Search stopped after {count} accounts'**
  String formatConnectionsSearchStopped(int count);

  /// Connections link text for a profile viewer's known followers count
  ///
  /// In en, this message translates to:
  /// **'You know {count, plural, =1{1 follower} other{{count} followers}}'**
  String formatKnownFollowersLink(int count);

  /// Follow audit classifying progress label
  ///
  /// In en, this message translates to:
  /// **'Classifying: {progress}/{total}'**
  String formatClassifyingProgress(int progress, int total);

  /// Snackbar message after copying a DID
  ///
  /// In en, this message translates to:
  /// **'DID copied to clipboard'**
  String get formatDidCopied;

  /// Follow audit fetching progress label
  ///
  /// In en, this message translates to:
  /// **'Fetching follows: {progress}/{total}'**
  String formatFetchingFollowsProgress(int progress, int total);

  /// Follow audit loading message while fetching the account follow count
  ///
  /// In en, this message translates to:
  /// **'Getting follow count...'**
  String get messageGettingFollowCount;

  /// Snackbar message after following starter pack members
  ///
  /// In en, this message translates to:
  /// **'Followed {count, plural, =1{1 member} other{{count} members}}'**
  String formatFollowedMemberCount(int count);

  /// Follow audit summary after scanning follows
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 follow scanned for problematic accounts} other{{count} follows scanned for problematic accounts}}'**
  String formatFollowsScanned(int count);

  /// Follow audit intro message when the follow count is known
  ///
  /// In en, this message translates to:
  /// **'Scan your {count, plural, =1{1 follow} other{{count} follows}} for deleted, suspended, blocked, and hidden accounts.'**
  String formatFollowAuditPromptWithCount(int count);

  /// Tooltip to hide a follow audit status
  ///
  /// In en, this message translates to:
  /// **'Hide {status}'**
  String formatHideStatus(String status);

  /// Profile joined date label
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String formatJoinedDate(String date);

  /// Profile card joined relative time label
  ///
  /// In en, this message translates to:
  /// **'Joined {relativeTime}'**
  String formatJoinedRelative(String relativeTime);

  /// List creator attribution label
  ///
  /// In en, this message translates to:
  /// **'by @{handle}'**
  String formatListByHandle(String handle);

  /// Count of list or starter pack members
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String formatMemberCount(int count);

  /// Report dialog title for a target handle
  ///
  /// In en, this message translates to:
  /// **'{title} by @{handle}'**
  String formatProfileReportTitle(String title, String handle);

  /// Profile edit validation message for a text length limit
  ///
  /// In en, this message translates to:
  /// **'{label} must be {count} characters or fewer'**
  String formatProfileTextLimit(String label, int count);

  /// Profile edit validation message for byte length
  ///
  /// In en, this message translates to:
  /// **'{label} is too long'**
  String formatProfileTextTooLong(String label);

  /// Follow audit warning when some profiles failed to load
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 profile could not be loaded.} other{{count} profiles could not be loaded.}}'**
  String formatProfilesFailedToLoad(int count);

  /// Report submission success dialog body
  ///
  /// In en, this message translates to:
  /// **'Thank you. Your report (ID: {reportId}) has been submitted.'**
  String formatReportSubmitted(String reportId);

  /// Follow audit selected count footer
  ///
  /// In en, this message translates to:
  /// **'Selected: {selected}/{total}'**
  String formatSelectedCount(int selected, int total);

  /// Tooltip to show a follow audit status
  ///
  /// In en, this message translates to:
  /// **'Show {status}'**
  String formatShowStatus(String status);

  /// Title for unavailable accounts card
  ///
  /// In en, this message translates to:
  /// **'Unavailable accounts ({count})'**
  String formatUnavailableAccounts(int count);

  /// Follow audit completion message
  ///
  /// In en, this message translates to:
  /// **'Unfollowed {count} account(s)'**
  String formatUnfollowedAccounts(int count);

  /// Helper text for required character-limited fields
  ///
  /// In en, this message translates to:
  /// **'Required, max {count} characters'**
  String formatValidationRequiredMaxCharacters(int count);

  /// Action label to add an account to a list
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get labelAddToList;

  /// Follow audit screen title
  ///
  /// In en, this message translates to:
  /// **'Audit Followers'**
  String get labelAuditFollowers;

  /// Profile banner image button label
  ///
  /// In en, this message translates to:
  /// **'Banner'**
  String get labelBanner;

  /// List action label to block accounts via a moderation list
  ///
  /// In en, this message translates to:
  /// **'Block via list'**
  String get labelBlockViaList;

  /// Profile context tab label for accounts that blocked the user
  ///
  /// In en, this message translates to:
  /// **'Blocked By'**
  String get labelBlockedBy;

  /// Profile context tab label for accounts the user is blocking
  ///
  /// In en, this message translates to:
  /// **'Blocking'**
  String get labelBlocking;

  /// Profile connections screen title
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get labelConnections;

  /// Profile action label to copy DID
  ///
  /// In en, this message translates to:
  /// **'Copy DID'**
  String get labelCopyDid;

  /// Create list dialog title
  ///
  /// In en, this message translates to:
  /// **'Create list'**
  String get labelCreateList;

  /// Tooltip to create a starter pack
  ///
  /// In en, this message translates to:
  /// **'Create starter pack'**
  String get labelCreateStarterPack;

  /// Short curation list badge label
  ///
  /// In en, this message translates to:
  /// **'CURATE'**
  String get labelCurateShort;

  /// List members section heading
  ///
  /// In en, this message translates to:
  /// **'Current Members'**
  String get labelCurrentMembers;

  /// Profile context list section heading
  ///
  /// In en, this message translates to:
  /// **'Curation Lists'**
  String get labelCurationLists;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get labelDescription;

  /// Optional description field label
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get labelDescriptionOptional;

  /// Profile display name field label
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get labelDisplayName;

  /// Edit list dialog or action title
  ///
  /// In en, this message translates to:
  /// **'Edit list'**
  String get labelEditList;

  /// Edit profile screen title or action label
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get labelEditProfile;

  /// Edit starter pack dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit starter pack'**
  String get labelEditStarterPack;

  /// Feed label
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get labelFeed;

  /// Followers label
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get labelFollowers;

  /// Short connections tab label for followers that are also followed by the viewer
  ///
  /// In en, this message translates to:
  /// **'Known'**
  String get labelKnownFollowers;

  /// Starter pack statistic label for joins this week
  ///
  /// In en, this message translates to:
  /// **'joined this week'**
  String get labelJoinedThisWeek;

  /// Starter pack card statistic label for total joins
  ///
  /// In en, this message translates to:
  /// **'joined total'**
  String get labelJoinedTotal;

  /// Following label
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get labelFollowing;

  /// Generic list title
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get labelList;

  /// Lists label
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get labelLists;

  /// Profile media tab label
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get labelMedia;

  /// Members section label
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get labelMembers;

  /// Profile context moderation list section heading
  ///
  /// In en, this message translates to:
  /// **'Moderation Lists'**
  String get labelModerationLists;

  /// Short moderation list badge label
  ///
  /// In en, this message translates to:
  /// **'MOD'**
  String get labelModerationShort;

  /// List action label to mute a list
  ///
  /// In en, this message translates to:
  /// **'Mute list'**
  String get labelMuteList;

  /// Mutual follows label
  ///
  /// In en, this message translates to:
  /// **'Mutuals'**
  String get labelMutuals;

  /// My lists screen title
  ///
  /// In en, this message translates to:
  /// **'My Lists'**
  String get labelMyLists;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelName;

  /// New starter pack screen title
  ///
  /// In en, this message translates to:
  /// **'New Starter Pack'**
  String get labelNewStarterPack;

  /// Profile context other list section heading
  ///
  /// In en, this message translates to:
  /// **'Other Lists'**
  String get labelOtherLists;

  /// Pronouns field label
  ///
  /// In en, this message translates to:
  /// **'Pronouns'**
  String get labelPronouns;

  /// Profile context screen title and action label
  ///
  /// In en, this message translates to:
  /// **'Profile Context'**
  String get labelProfileContext;

  /// Generic profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get labelProfileTitle;

  /// Starter pack feeds section title
  ///
  /// In en, this message translates to:
  /// **'Recommended Feeds'**
  String get labelRecommendedFeeds;

  /// Profile context reference list section heading
  ///
  /// In en, this message translates to:
  /// **'Reference Lists'**
  String get labelReferenceLists;

  /// Short reference list badge label
  ///
  /// In en, this message translates to:
  /// **'REFERENCE'**
  String get labelReferenceShort;

  /// Profile replies tab label
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get labelReplies;

  /// Report action label
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get labelReport;

  /// Report account dialog title
  ///
  /// In en, this message translates to:
  /// **'Report Account'**
  String get labelReportAccount;

  /// Report reason section label
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get labelReportReason;

  /// Report explanation field label
  ///
  /// In en, this message translates to:
  /// **'Explanation (required)'**
  String get labelReportReasonExplanationRequired;

  /// Report reason label for harassment
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get labelReportReasonHarassment;

  /// Report reason label for misleading content
  ///
  /// In en, this message translates to:
  /// **'Misleading'**
  String get labelReportReasonMisleading;

  /// Report reason label for other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get labelReportReasonOther;

  /// Report reason label for sexual content
  ///
  /// In en, this message translates to:
  /// **'Sexual Content'**
  String get labelReportReasonSexualContent;

  /// Report reason label for spam
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get labelReportReasonSpam;

  /// Report reason label for violations
  ///
  /// In en, this message translates to:
  /// **'Violation'**
  String get labelReportReasonViolation;

  /// Report success dialog title
  ///
  /// In en, this message translates to:
  /// **'Report Submitted'**
  String get labelReportSubmitted;

  /// Select all checkbox label
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get labelSelectAll;

  /// Feed picker sheet title
  ///
  /// In en, this message translates to:
  /// **'Select a feed'**
  String get labelSelectFeed;

  /// Profile action label to share a profile
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get labelShareProfile;

  /// Fallback starter pack title
  ///
  /// In en, this message translates to:
  /// **'Starter Pack'**
  String get labelStarterPack;

  /// Type field label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get labelType;

  /// Starter pack detail statistic label for total joins
  ///
  /// In en, this message translates to:
  /// **'total joined'**
  String get labelTotalJoined;

  /// Profile liked posts unavailable entry title
  ///
  /// In en, this message translates to:
  /// **'Unavailable liked post'**
  String get labelUnavailableLikedPost;

  /// List action label to unblock accounts via a moderation list
  ///
  /// In en, this message translates to:
  /// **'Unblock via list'**
  String get labelUnblockViaList;

  /// List action label to unmute a list
  ///
  /// In en, this message translates to:
  /// **'Unmute list'**
  String get labelUnmuteList;

  /// Helper label for selecting up to three starter pack feeds
  ///
  /// In en, this message translates to:
  /// **'(up to 3)'**
  String get labelUpToThree;

  /// Website field label
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get labelWebsite;

  /// Profile connection chip for the current user
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get labelYou;

  /// Profile context blocked-by explanatory copy
  ///
  /// In en, this message translates to:
  /// **'Blocks are a normal part of social media. This data is public on the AT Protocol.'**
  String get messageBlockedByContextNotice;

  /// Profile context message when blocking list is not available
  ///
  /// In en, this message translates to:
  /// **'Blocking information is only available when viewing your own profile.'**
  String get messageBlockingOnlyOwnProfile;

  /// Tooltip and semantics label for changing profile avatar
  ///
  /// In en, this message translates to:
  /// **'Change avatar image'**
  String get messageChangeAvatarImage;

  /// Tooltip and semantics label for changing profile banner
  ///
  /// In en, this message translates to:
  /// **'Change banner image'**
  String get messageChangeBannerImage;

  /// Profile edit validation error for invalid website
  ///
  /// In en, this message translates to:
  /// **'Enter a valid website'**
  String get messageEnterValidWebsite;

  /// List detail message when moderation lists do not have feeds
  ///
  /// In en, this message translates to:
  /// **'Feed not available for moderation lists'**
  String get messageFeedUnavailableForModerationLists;

  /// Follow audit intro message before scanning
  ///
  /// In en, this message translates to:
  /// **'Scan your follows for deleted, suspended, blocked, and hidden accounts.'**
  String get messageFollowAuditIntro;

  /// Follow audit empty prompt before scanning
  ///
  /// In en, this message translates to:
  /// **'Tap Scan to audit your follow list.'**
  String get messageFollowAuditStartPrompt;

  /// Profile context empty blocked-by message
  ///
  /// In en, this message translates to:
  /// **'No accounts have blocked this user'**
  String get messageNoAccountsBlockedThisUser;

  /// Empty state when no lists exist
  ///
  /// In en, this message translates to:
  /// **'No lists yet'**
  String get messageNoListsYet;

  /// Empty starter pack members message
  ///
  /// In en, this message translates to:
  /// **'No members'**
  String get messageNoMembers;

  /// Empty list members message
  ///
  /// In en, this message translates to:
  /// **'No members yet'**
  String get messageNoMembersYet;

  /// Empty list members message with search instruction
  ///
  /// In en, this message translates to:
  /// **'No members yet. Search above to add people.'**
  String get messageNoMembersYetSearch;

  /// Empty profile media tab message
  ///
  /// In en, this message translates to:
  /// **'No media posts yet'**
  String get messageNoMediaPostsYet;

  /// Empty profile/list feed message
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get messageNoPostsYet;

  /// Follow audit empty results message
  ///
  /// In en, this message translates to:
  /// **'No problematic follows found'**
  String get messageNoProblematicFollows;

  /// Empty profile replies message
  ///
  /// In en, this message translates to:
  /// **'No replies yet'**
  String get messageNoRepliesYet;

  /// Follow audit empty filtered results message
  ///
  /// In en, this message translates to:
  /// **'No results visible for the current filters.'**
  String get messageNoResultsForFilters;

  /// Empty starter packs message
  ///
  /// In en, this message translates to:
  /// **'No starter packs yet'**
  String get messageNoStarterPacksYet;

  /// Empty suggested follows message
  ///
  /// In en, this message translates to:
  /// **'No suggestions found'**
  String get messageNoSuggestionsFound;

  /// Profile context empty blocking message
  ///
  /// In en, this message translates to:
  /// **'Not blocking anyone'**
  String get messageNotBlockingAnyone;

  /// Profile context empty lists-on message
  ///
  /// In en, this message translates to:
  /// **'Not on any lists'**
  String get messageNotOnAnyLists;

  /// Fallback unavailable profile reason
  ///
  /// In en, this message translates to:
  /// **'Profile unavailable'**
  String get messageProfileUnavailable;

  /// Snackbar after profile update succeeds
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get messageProfileUpdated;

  /// Report explanation text field hint
  ///
  /// In en, this message translates to:
  /// **'Please explain why you are reporting this...'**
  String get messageReportExplanationHint;

  /// Report reason description for harassment
  ///
  /// In en, this message translates to:
  /// **'Harassment or rude behaviour'**
  String get messageReportReasonHarassmentDescription;

  /// Report reason description for misleading content
  ///
  /// In en, this message translates to:
  /// **'Misleading or deceptive content'**
  String get messageReportReasonMisleadingDescription;

  /// Report reason description for other
  ///
  /// In en, this message translates to:
  /// **'Other reason (requires explanation)'**
  String get messageReportReasonOtherDescription;

  /// Report reason description for sexual content
  ///
  /// In en, this message translates to:
  /// **'Unwanted sexual content'**
  String get messageReportReasonSexualContentDescription;

  /// Report reason description for spam
  ///
  /// In en, this message translates to:
  /// **'Spam or unsolicited content'**
  String get messageReportReasonSpamDescription;

  /// Report reason description for violations
  ///
  /// In en, this message translates to:
  /// **'Violates community guidelines'**
  String get messageReportReasonViolationDescription;

  /// Profile connections search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search handle, name, or description'**
  String get messageSearchConnectionsPlaceholder;

  /// Search field placeholder when adding people
  ///
  /// In en, this message translates to:
  /// **'Search for people to add'**
  String get messageSearchPeopleToAddPlaceholder;

  /// Profile context message when some blocked accounts are unavailable
  ///
  /// In en, this message translates to:
  /// **'Some blocked accounts are suspended or unavailable.'**
  String get messageSomeBlockedAccountsUnavailable;

  /// Suggested follows unavailable message
  ///
  /// In en, this message translates to:
  /// **'Suggested follows are unavailable right now.'**
  String get messageSuggestedFollowsUnavailable;

  /// Unavailable accounts card subtitle
  ///
  /// In en, this message translates to:
  /// **'These accounts are suspended or their public profile could not be fetched.'**
  String get messageUnavailableAccountsDescription;

  /// Follow audit status label
  ///
  /// In en, this message translates to:
  /// **'Blocked by'**
  String get statusBlockedBy;

  /// Follow audit status label
  ///
  /// In en, this message translates to:
  /// **'Blocking'**
  String get statusBlocking;

  /// Follow audit status label
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get statusDeactivated;

  /// Follow audit status label
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get statusDeleted;

  /// Follow audit status label
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get statusHidden;

  /// Follow audit status label
  ///
  /// In en, this message translates to:
  /// **'Mutual block'**
  String get statusMutualBlock;

  /// Follow audit status label
  ///
  /// In en, this message translates to:
  /// **'Self-follow'**
  String get statusSelfFollow;

  /// Follow audit status label
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// Tooltip for clearing a search field
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get tooltipClearSearch;

  /// Tooltip for jump to top button
  ///
  /// In en, this message translates to:
  /// **'Jump to top'**
  String get tooltipJumpToTop;

  /// Profile edit validation error for invalid website
  ///
  /// In en, this message translates to:
  /// **'Enter a valid website'**
  String get validationEnterValidWebsite;

  /// Empty state message in the account switcher sheet
  ///
  /// In en, this message translates to:
  /// **'No other signed-in accounts yet. Add an account to switch between profiles.'**
  String get accountSwitcherNoOtherAccounts;

  /// Button and dialog title to add another account
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get buttonAddAccount;

  /// Message thread menu item to copy all messages
  ///
  /// In en, this message translates to:
  /// **'Copy All'**
  String get buttonCopyAll;

  /// Button label to mark notifications read
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get buttonMarkAllRead;

  /// Snackbar message when adding an account fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add account'**
  String get errorFailedToAddAccount;

  /// Error title when messages cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages'**
  String get errorFailedToLoadMessages;

  /// Error title when notifications cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get errorFailedToLoadNotifications;

  /// Snackbar message when removing an account from account switcher fails
  ///
  /// In en, this message translates to:
  /// **'Unable to remove account right now.'**
  String get errorUnableToRemoveAccountNow;

  /// Two-person actor summary in grouped notifications
  ///
  /// In en, this message translates to:
  /// **'{first} and {second}'**
  String formatActorListTwo(String first, String second);

  /// Multi-person actor summary in grouped notifications
  ///
  /// In en, this message translates to:
  /// **'{first}, {second}, and {count} others'**
  String formatActorListWithOthers(String first, String second, int count);

  /// Month and day label for notification sections
  ///
  /// In en, this message translates to:
  /// **'{month} {day}'**
  String formatMonthDay(String month, int day);

  /// Confirmation dialog body when removing an account from the account switcher
  ///
  /// In en, this message translates to:
  /// **'Remove @{handle} from this device?'**
  String formatRemoveAccountContent(String handle);

  /// Account switcher sheet title
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get labelAccounts;

  /// Alerts screen title
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get labelAlertsTitle;

  /// Fallback conversation title
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get labelConversation;

  /// Notification channel name for follows
  ///
  /// In en, this message translates to:
  /// **'Follows'**
  String get labelFollows;

  /// Notification channel name for likes
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get labelLikes;

  /// Message requests tab label
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get labelMessageRequests;

  /// Other notification channel name
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get labelOther;

  /// Primary messages tab label
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get labelPrimary;

  /// Fallback actor summary for grouped notifications
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get labelSomeone;

  /// Snackbar message after copying a message
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get messageCopied;

  /// Deleted message placeholder
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messageDeleted;

  /// Local notification body fallback for unknown notification reasons
  ///
  /// In en, this message translates to:
  /// **'sent a notification'**
  String get messageLocalNotificationFallbackBody;

  /// Local notification title fallback
  ///
  /// In en, this message translates to:
  /// **'New notification'**
  String get messageNewNotification;

  /// Offline state title
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get messageNoConnection;

  /// Empty primary conversations state
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get messageNoConversationsYet;

  /// Empty message requests state
  ///
  /// In en, this message translates to:
  /// **'No message requests'**
  String get messageNoMessageRequests;

  /// Empty message thread state
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get messageNoMessagesYet;

  /// Empty notifications state
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get messageNoNotificationsYet;

  /// Notification summary for contact match
  ///
  /// In en, this message translates to:
  /// **'joined from your contacts'**
  String get messageNotificationContactMatch;

  /// Notification summary for follows
  ///
  /// In en, this message translates to:
  /// **'followed you'**
  String get messageNotificationFollow;

  /// Notification summary fallback
  ///
  /// In en, this message translates to:
  /// **'interacted with you'**
  String get messageNotificationInteracted;

  /// Notification summary for likes
  ///
  /// In en, this message translates to:
  /// **'liked your post'**
  String get messageNotificationLike;

  /// Notification summary for likes via repost
  ///
  /// In en, this message translates to:
  /// **'liked your repost'**
  String get messageNotificationLikeViaRepost;

  /// Notification summary for mentions
  ///
  /// In en, this message translates to:
  /// **'mentioned you'**
  String get messageNotificationMention;

  /// Notification summary for quotes
  ///
  /// In en, this message translates to:
  /// **'quoted your post'**
  String get messageNotificationQuote;

  /// Notification summary for replies
  ///
  /// In en, this message translates to:
  /// **'replied to your post'**
  String get messageNotificationReply;

  /// Notification summary for reposts
  ///
  /// In en, this message translates to:
  /// **'reposted your post'**
  String get messageNotificationRepost;

  /// Notification summary for reposts via repost
  ///
  /// In en, this message translates to:
  /// **'reposted your repost'**
  String get messageNotificationRepostViaRepost;

  /// Notification summary for starter pack joins
  ///
  /// In en, this message translates to:
  /// **'joined via your starter pack'**
  String get messageNotificationStarterPackJoined;

  /// Notification summary for subscribed posts
  ///
  /// In en, this message translates to:
  /// **'posted a new update'**
  String get messageNotificationSubscribedPost;

  /// Notification summary for unverified account
  ///
  /// In en, this message translates to:
  /// **'removed your verification'**
  String get messageNotificationUnverified;

  /// Notification summary for verified account
  ///
  /// In en, this message translates to:
  /// **'verified your account'**
  String get messageNotificationVerified;

  /// Message composer placeholder
  ///
  /// In en, this message translates to:
  /// **'Message…'**
  String get messagePlaceholder;

  /// Snackbar when account switch requires reauthentication
  ///
  /// In en, this message translates to:
  /// **'Please sign in again for that account.'**
  String get messagePleaseSignInAgainForAccount;

  /// Offline message list explanation
  ///
  /// In en, this message translates to:
  /// **'Reconnect to load messages.'**
  String get messageReconnectToLoadMessages;

  /// Offline notifications explanation
  ///
  /// In en, this message translates to:
  /// **'Reconnect to load notifications.'**
  String get messageReconnectToLoadNotifications;

  /// Snackbar after copying a message thread
  ///
  /// In en, this message translates to:
  /// **'Thread copied'**
  String get messageThreadCopied;

  /// Today date section label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get messageToday;

  /// Yesterday date section label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get messageYesterday;

  /// Handle placeholder in account switcher
  ///
  /// In en, this message translates to:
  /// **'username.bsky.social'**
  String get placeholderUsernameBskySocial;

  /// Account switcher validation error for empty handle or DID
  ///
  /// In en, this message translates to:
  /// **'Enter a Bluesky handle or DID'**
  String get validationEnterBlueskyHandleOrDid;

  /// Account switcher validation error for incomplete DID
  ///
  /// In en, this message translates to:
  /// **'Enter a complete DID like did:plc:... or did:web:...'**
  String get validationEnterCompleteDid;

  /// Account switcher validation error for invalid handle
  ///
  /// In en, this message translates to:
  /// **'Enter a full handle like username.bsky.social'**
  String get validationEnterFullHandle;

  /// Account switcher validation error for unsupported DID method
  ///
  /// In en, this message translates to:
  /// **'Use a did:plc:... or did:web:... identifier'**
  String get validationUseSupportedDid;

  /// Validation error for missing app password
  ///
  /// In en, this message translates to:
  /// **'Enter your app password'**
  String get validationEnterAppPassword;

  /// Generic add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// Button label while an add action is in progress
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get buttonAdding;

  /// Devtools button label linking to pds.ls
  ///
  /// In en, this message translates to:
  /// **'Inspired by pds.ls'**
  String get buttonInspiredByPdsLs;

  /// Button label to copy record JSON
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get buttonCopyJson;

  /// Button label to resolve a handle, DID, or AT URI
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get buttonResolve;

  /// Button label to unsubscribe from a labeler
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get buttonUnsubscribe;

  /// Dialog title for adding a moderation labeler
  ///
  /// In en, this message translates to:
  /// **'Add labeler'**
  String get dialogAddLabelerTitle;

  /// Confirmation dialog body before clearing all log files
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all log files. This action cannot be undone.'**
  String get dialogClearAllLogsContent;

  /// Confirmation dialog title before clearing all log files
  ///
  /// In en, this message translates to:
  /// **'Clear all logs?'**
  String get dialogClearAllLogsTitle;

  /// Error title when logs cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load logs'**
  String get errorFailedToLoadLogs;

  /// Error title when moderation settings cannot load
  ///
  /// In en, this message translates to:
  /// **'Failed to load moderation settings'**
  String get errorFailedToLoadModerationSettings;

  /// Snackbar message when unsubscribing from a labeler fails
  ///
  /// In en, this message translates to:
  /// **'Failed to unsubscribe: {error}'**
  String errorFailedToUnsubscribeLabeler(Object error);

  /// Snackbar message when adult content preference update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update adult content: {error}'**
  String errorFailedToUpdateAdultContent(Object error);

  /// Snackbar message when a label preference update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update preference: {error}'**
  String errorFailedToUpdateLabelPreference(Object error);

  /// Snackbar message when a labeler subscription update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update subscription: {error}'**
  String errorFailedToUpdateLabelerSubscription(Object error);

  /// Validation error when adding a labeler without a DID
  ///
  /// In en, this message translates to:
  /// **'Enter a labeler DID.'**
  String get errorLabelerDidRequired;

  /// Error thrown when a labeler DID cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Labeler not found.'**
  String get errorLabelerNotFound;

  /// Validation error when no labeler exists for the entered DID
  ///
  /// In en, this message translates to:
  /// **'No labeler found for that DID.'**
  String get errorNoLabelerFoundForDid;

  /// Error title when a labeler detail screen cannot load
  ///
  /// In en, this message translates to:
  /// **'Unable to load labeler'**
  String get errorUnableToLoadLabeler;

  /// Add labeler button showing current and maximum custom labelers
  ///
  /// In en, this message translates to:
  /// **'Add ({current}/{max})'**
  String formatAddLabelerLimit(int current, int max);

  /// Devtools repository collection count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 collection} other{{count} collections}}'**
  String formatCollectionsCount(int count);

  /// Devtools record CID label
  ///
  /// In en, this message translates to:
  /// **'CID: {cid}'**
  String formatCid(String cid);

  /// Moderation labeler detail chip showing custom label count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 custom label} other{{count} custom labels}}'**
  String formatCustomLabelCount(int count);

  /// Moderation labeler card chip showing custom definition count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 definition} other{{count} definitions}}'**
  String formatDefinitionCount(int count);

  /// Devtools record list count while total is unknown
  ///
  /// In en, this message translates to:
  /// **'{count} loaded'**
  String formatLoadedRecordsCount(int count);

  /// Devtools record list count showing loaded and total records
  ///
  /// In en, this message translates to:
  /// **'{loaded} of {total}'**
  String formatLoadedRecordsOfTotal(int loaded, int total);

  /// Tooltip description for a moderation label source
  ///
  /// In en, this message translates to:
  /// **'{source} label'**
  String formatModerationSourceLabel(String source);

  /// Moderation policy chip showing the blur behavior
  ///
  /// In en, this message translates to:
  /// **'Blur {value}'**
  String formatPolicyBlur(String value);

  /// Moderation policy chip showing default preference
  ///
  /// In en, this message translates to:
  /// **'Default {value}'**
  String formatPolicyDefault(String value);

  /// Moderation policy chip showing a label identifier
  ///
  /// In en, this message translates to:
  /// **'ID {identifier}'**
  String formatPolicyId(String identifier);

  /// Moderation policy chip showing severity
  ///
  /// In en, this message translates to:
  /// **'Severity {value}'**
  String formatPolicySeverity(String value);

  /// Moderation labeler card chip showing published value count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 published value} other{{count} published values}}'**
  String formatPublishedValueCount(int count);

  /// Devtools repository record count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 record} other{{count} records}}'**
  String formatRecordsCount(int count);

  /// Snackbar after subscribing to a labeler
  ///
  /// In en, this message translates to:
  /// **'Subscribed to {name}'**
  String formatSubscribedToLabeler(String name);

  /// Moderation settings adult content switch label
  ///
  /// In en, this message translates to:
  /// **'Adult content'**
  String get labelAdultContentSetting;

  /// Short chip label for adult-only moderation labels
  ///
  /// In en, this message translates to:
  /// **'18+'**
  String get labelAdultOnlyShort;

  /// Status label for always-on moderation labeler
  ///
  /// In en, this message translates to:
  /// **'Always on'**
  String get labelAlwaysOn;

  /// Log viewer auto-scroll control label
  ///
  /// In en, this message translates to:
  /// **'Auto-scroll'**
  String get labelAutoScroll;

  /// Built-in Bluesky moderation labeler title
  ///
  /// In en, this message translates to:
  /// **'Bluesky moderation'**
  String get labelBlueskyModeration;

  /// Chip label for a built-in item
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get labelBuiltIn;

  /// Moderation settings section title for built-in labeler
  ///
  /// In en, this message translates to:
  /// **'Built-in labeler'**
  String get labelBuiltInLabeler;

  /// Moderation labeler chip and switch label for built-in moderation
  ///
  /// In en, this message translates to:
  /// **'Built-in moderation'**
  String get labelBuiltInModeration;

  /// Moderation badge for blocked account content
  ///
  /// In en, this message translates to:
  /// **'Blocked account'**
  String get labelBlockedAccount;

  /// Moderation badge for content from an account that blocked the user
  ///
  /// In en, this message translates to:
  /// **'Blocked by account'**
  String get labelBlockedByAccount;

  /// Moderation badge for content limited by a block relationship
  ///
  /// In en, this message translates to:
  /// **'Blocked relationship'**
  String get labelBlockedRelationship;

  /// Devtools section heading for repository collections
  ///
  /// In en, this message translates to:
  /// **'COLLECTIONS'**
  String get labelCollections;

  /// Moderation label preference option to hide matching content
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get labelContentPreferenceHide;

  /// Moderation label preference option to ignore matching content
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get labelContentPreferenceIgnore;

  /// Moderation label preference option to warn on matching content
  ///
  /// In en, this message translates to:
  /// **'Warn'**
  String get labelContentPreferenceWarn;

  /// Moderation settings section title for custom labelers
  ///
  /// In en, this message translates to:
  /// **'Custom labelers'**
  String get labelCustomLabelers;

  /// Labeler detail screen app bar title
  ///
  /// In en, this message translates to:
  /// **'Labeler'**
  String get labelLabeler;

  /// Input label for labeler DID
  ///
  /// In en, this message translates to:
  /// **'Labeler DID'**
  String get labelLabelerDid;

  /// Moderation settings hero title
  ///
  /// In en, this message translates to:
  /// **'Labelers and content moderation'**
  String get labelLabelersAndContentModeration;

  /// Labeler detail section heading for preferences
  ///
  /// In en, this message translates to:
  /// **'Label preferences'**
  String get labelLabelPreferences;

  /// Moderation badge for hidden content
  ///
  /// In en, this message translates to:
  /// **'Hidden content'**
  String get labelHiddenContent;

  /// Log level filter chip for debug logs
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get labelLogLevelDebug;

  /// Log level filter chip for error logs
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get labelLogLevelError;

  /// Log level filter chip for fatal logs
  ///
  /// In en, this message translates to:
  /// **'Fatal'**
  String get labelLogLevelFatal;

  /// Log level filter chip for info logs
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get labelLogLevelInfo;

  /// Log level filter chip for trace logs
  ///
  /// In en, this message translates to:
  /// **'Trace'**
  String get labelLogLevelTrace;

  /// Log level filter chip for warning logs
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get labelLogLevelWarning;

  /// Fallback informational moderation badge label
  ///
  /// In en, this message translates to:
  /// **'Moderation note'**
  String get labelModerationNote;

  /// Moderation source label for the built-in Bluesky labeler
  ///
  /// In en, this message translates to:
  /// **'Bluesky'**
  String get labelModerationSourceBluesky;

  /// Moderation source label for a subscribed custom labeler
  ///
  /// In en, this message translates to:
  /// **'Subscribed labeler'**
  String get labelModerationSourceSubscribedLabeler;

  /// Moderation badge for muted account content
  ///
  /// In en, this message translates to:
  /// **'Muted account'**
  String get labelMutedAccount;

  /// Moderation badge for muted phrase content
  ///
  /// In en, this message translates to:
  /// **'Muted phrase'**
  String get labelMutedPhrase;

  /// Empty state title when a labeler has no localized custom definitions
  ///
  /// In en, this message translates to:
  /// **'No custom label definitions'**
  String get labelNoCustomLabelDefinitions;

  /// Empty state title when no custom labelers are subscribed
  ///
  /// In en, this message translates to:
  /// **'No custom labelers'**
  String get labelNoCustomLabelers;

  /// Developer PDS Explorer screen title
  ///
  /// In en, this message translates to:
  /// **'PDS Explorer'**
  String get labelPdsExplorer;

  /// Labeler detail section heading for published policies
  ///
  /// In en, this message translates to:
  /// **'Published policies'**
  String get labelPublishedPolicies;

  /// Devtools breadcrumb label for an empty record key
  ///
  /// In en, this message translates to:
  /// **'Record JSON'**
  String get labelRecordJson;

  /// Generic refresh tooltip label
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get labelRefresh;

  /// Devtools breadcrumb fallback label for repository
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get labelRepository;

  /// Labeler detail switch label for subscribed labelers
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get labelSubscribed;

  /// Fallback moderation label for sensitive content
  ///
  /// In en, this message translates to:
  /// **'Sensitive content'**
  String get labelSensitiveContent;

  /// Generic fallback label when a name is unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get labelUnknown;

  /// Helper text in add labeler dialog
  ///
  /// In en, this message translates to:
  /// **'Paste a labeler DID to review and subscribe to its labels.'**
  String get messageAddLabelerDidHelper;

  /// Moderation settings adult content switch helper text
  ///
  /// In en, this message translates to:
  /// **'Required before 18+ label preferences can be changed.'**
  String get messageAdultContentRequiredForLabels;

  /// Moderation settings fallback subtitle when built-in labeler details are unavailable
  ///
  /// In en, this message translates to:
  /// **'The built-in labeler is active even if its details cannot be loaded right now.'**
  String get messageBuiltInLabelerActiveWhenUnavailable;

  /// Labeler detail subtitle for built-in labeler subscription switch
  ///
  /// In en, this message translates to:
  /// **'This labeler is always active.'**
  String get messageBuiltInLabelerAlwaysActive;

  /// Developer PDS Explorer empty state helper text
  ///
  /// In en, this message translates to:
  /// **'Enter a handle, DID, or AT-URI to explore\na user\'\'s repository.'**
  String get messageDevtoolsEmptyState;

  /// Helper text shown when adult content is required to edit a label preference
  ///
  /// In en, this message translates to:
  /// **'Enable adult content to change this 18+ label.'**
  String get messageEnableAdultContentForLabel;

  /// Tooltip for blocked account moderation badge
  ///
  /// In en, this message translates to:
  /// **'This account is blocked'**
  String get messageBlockedAccountDescription;

  /// Tooltip for blocked-by account moderation badge
  ///
  /// In en, this message translates to:
  /// **'This account has blocked you'**
  String get messageBlockedByAccountDescription;

  /// Tooltip for blocked relationship moderation badge
  ///
  /// In en, this message translates to:
  /// **'This content is limited by a block relationship'**
  String get messageBlockedRelationshipDescription;

  /// Tooltip for hidden content moderation badge
  ///
  /// In en, this message translates to:
  /// **'This content is hidden by moderation rules'**
  String get messageHiddenContentDescription;

  /// Snackbar after copying record JSON
  ///
  /// In en, this message translates to:
  /// **'JSON copied to clipboard'**
  String get messageJsonCopiedToClipboard;

  /// Log viewer empty state title
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get messageLogsEmpty;

  /// Log viewer empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Log entries will appear here'**
  String get messageLogsEmptySubtitle;

  /// Moderation settings hero subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage adult-content visibility, subscribed labelers, and the rules each labeler applies to posts and profiles.'**
  String get messageModerationSettingsHeroSubtitle;

  /// Fallback moderation badge tooltip
  ///
  /// In en, this message translates to:
  /// **'Moderation guidance applies here'**
  String get messageModerationGuidanceApplies;

  /// Tooltip for muted account moderation badge
  ///
  /// In en, this message translates to:
  /// **'Muted content is being downranked here'**
  String get messageMutedAccountDescription;

  /// Tooltip for muted phrase moderation badge
  ///
  /// In en, this message translates to:
  /// **'A muted phrase matched this content'**
  String get messageMutedPhraseDescription;

  /// Labeler detail empty state subtitle when no localized custom definitions are available
  ///
  /// In en, this message translates to:
  /// **'This labeler publishes values, but not localized custom definitions.'**
  String get messageNoCustomLabelDefinitions;

  /// Moderation settings empty state subtitle when no custom labelers are subscribed
  ///
  /// In en, this message translates to:
  /// **'Add a labeler DID to subscribe and configure its custom labels.'**
  String get messageNoCustomLabelers;

  /// Fallback description for a label definition without localized description
  ///
  /// In en, this message translates to:
  /// **'No description available for this label.'**
  String get messageNoLabelDescriptionAvailable;

  /// Snackbar when there is no log file to share
  ///
  /// In en, this message translates to:
  /// **'No log file available'**
  String get messageNoLogFileAvailable;

  /// Devtools repository count status when record counts cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Record counts unavailable'**
  String get messageRecordCountsUnavailable;

  /// Devtools repository count status while record counts are loading
  ///
  /// In en, this message translates to:
  /// **'Counting records...'**
  String get messageRecordCountsLoading;

  /// Labeler detail subtitle for custom labeler subscription switch
  ///
  /// In en, this message translates to:
  /// **'Subscribed labelers are added to your moderation headers and preferences.'**
  String get messageSubscribedLabelersHeaders;

  /// Snackbar when the log share sheet cannot open
  ///
  /// In en, this message translates to:
  /// **'Unable to open share sheet. Please try again.'**
  String get messageUnableToOpenShareSheet;

  /// Snackbar when the crash report email draft cannot open
  ///
  /// In en, this message translates to:
  /// **'Unable to open email app. Please copy the report instead.'**
  String get messageUnableToOpenEmailApp;

  /// Devtools search input placeholder
  ///
  /// In en, this message translates to:
  /// **'Handle, DID, or at:// URI'**
  String get placeholderHandleDidOrAtUri;

  /// Placeholder DID in add labeler dialog
  ///
  /// In en, this message translates to:
  /// **'did:plc:examplelabeler'**
  String get placeholderLabelerDid;

  /// Log viewer search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Filter logs...'**
  String get placeholderLogsFilter;

  /// Share sheet subject for log files
  ///
  /// In en, this message translates to:
  /// **'Lazurite logs'**
  String get subjectLazuriteLogs;

  /// Email subject for an in-app crash report
  ///
  /// In en, this message translates to:
  /// **'Lazurite crash report'**
  String get subjectLazuriteCrashReport;

  /// Tooltip for clearing all log files
  ///
  /// In en, this message translates to:
  /// **'Clear all logs'**
  String get tooltipClearAllLogs;

  /// Tooltip for collapsing a log row stack trace preview
  ///
  /// In en, this message translates to:
  /// **'Collapse stack trace'**
  String get tooltipCollapseStackTrace;

  /// Tooltip for expanding a log row stack trace preview
  ///
  /// In en, this message translates to:
  /// **'Expand stack trace'**
  String get tooltipExpandStackTrace;

  /// Tooltip for opening pds.ls
  ///
  /// In en, this message translates to:
  /// **'Go to pds.ls'**
  String get tooltipGoToPdsLs;

  /// Tooltip for sharing a log file
  ///
  /// In en, this message translates to:
  /// **'Share log file'**
  String get tooltipShareLogFile;
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
