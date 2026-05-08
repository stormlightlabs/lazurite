// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lazurite';

  @override
  String get buttonApplyAndRestart => 'Apply and Restart';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonClearCache => 'Clear Cache';

  @override
  String get buttonContinue => 'Continue';

  @override
  String get buttonClearLocal => 'Clear Local';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonLoadMoreQuotes => 'Load more quotes';

  @override
  String get buttonLoadMoreReposts => 'Load more reposts';

  @override
  String get buttonRemove => 'Remove';

  @override
  String get buttonApply => 'Apply';

  @override
  String get buttonClear => 'Clear';

  @override
  String get buttonClearAll => 'Clear all';

  @override
  String get buttonOpen => 'Open';

  @override
  String get buttonResetSignInData => 'Reset Sign-In Data';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get buttonSignIn => 'Sign In';

  @override
  String get buttonShowContent => 'Show content';

  @override
  String get buttonShare => 'Share';

  @override
  String get buttonTryAgain => 'Try again';

  @override
  String get commonNever => 'Never';

  @override
  String get commonNone => 'None';

  @override
  String get commonNow => 'now';

  @override
  String get commonNotCheckedYet => 'Not checked yet';

  @override
  String get commonOff => 'Off';

  @override
  String get dialogClearCacheContent =>
      'This removes cached posts, profiles, images, feeds, threads, label data, and local semantic search data.\n\nAccounts, settings, drafts, bookmarks, and likes are kept.';

  @override
  String get dialogClearCacheTitle => 'Clear cache?';

  @override
  String get dialogClearLocalBookmarksContent =>
      'This removes only local bookmarks from this device. Bluesky cloud bookmarks will not be deleted.';

  @override
  String get dialogClearLocalBookmarksTitle => 'Clear local bookmarks?';

  @override
  String get dialogDeletePostContent => 'This action cannot be undone.';

  @override
  String get dialogDeletePostTitle => 'Delete Post?';

  @override
  String dialogRemoveAccountContent(String handle) {
    return 'Remove @$handle from this device?';
  }

  @override
  String get dialogRemoveAccountTitle => 'Remove Account';

  @override
  String get dialogResetSignInDataContent =>
      'Use this only when troubleshooting sign-in or account switching.\n\nThis clears all local account sessions on this device and sends you back to sign in. It does not delete your Bluesky account or posts.';

  @override
  String get dialogResetSignInDataTitle => 'Reset sign-in data?';

  @override
  String get dialogSwitchAppViewProviderContent =>
      'Apply and restart now to rebuild network services.\n\nYou will stay signed in and no local data will be deleted.\n\nModeration labels, ranking, and trending results can differ between providers.';

  @override
  String get dialogSwitchAppViewProviderTitle => 'Switch AppView provider?';

  @override
  String errorFailedToSaveProviderSelection(Object error) {
    return 'Failed to save provider selection: $error';
  }

  @override
  String errorFailedToClearCache(Object error) {
    return 'Failed to clear cache: $error';
  }

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get errorFailedToLoadBookmarks => 'Failed to load bookmarks';

  @override
  String get errorFailedToLoadLikedPosts => 'Failed to load liked posts';

  @override
  String errorFailedToLoadLikedPostsDetails(Object error) {
    return 'Failed to load liked posts: $error';
  }

  @override
  String errorFailedToRefreshLikedPosts(Object error) {
    return 'Failed to refresh liked posts: $error';
  }

  @override
  String get errorFailedToLoadTrending => 'Failed to load trending';

  @override
  String errorFailedToLoadTrendingTopics(Object error) {
    return 'Failed to load trending topics: $error';
  }

  @override
  String get errorUnknown => 'Unknown error';

  @override
  String get errorUnableToRemoveAccount => 'Unable to remove account right now.';

  @override
  String get labelRemoveAccount => 'Remove account';

  @override
  String formatAccountsTapToSwitch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts - tap to switch',
      one: '1 account - tap to switch',
    );
    return '$_temp0';
  }

  @override
  String formatAppViewProviderSelected(String provider) {
    return '$provider selected. Switching providers performs a soft restart.';
  }

  @override
  String formatContentModerationCustomLabelers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count custom labelers subscribed',
      one: '1 custom labeler subscribed',
      zero: 'No custom labelers subscribed',
    );
    return '$_temp0';
  }

  @override
  String formatDepth(int depth) {
    return 'Depth $depth';
  }

  @override
  String formatLikedOn(String date) {
    return 'Liked on $date';
  }

  @override
  String formatLikesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count Likes', one: '1 Like');
    return '$_temp0';
  }

  @override
  String formatOfflineReconnectAction(String action) {
    return 'You are offline. Reconnect to $action.';
  }

  @override
  String formatReplyingToHandle(String handle) {
    return 'Replying to @$handle';
  }

  @override
  String formatRepostsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count Reposts', one: '1 Repost');
    return '$_temp0';
  }

  @override
  String formatSavedOn(String date) {
    return 'Saved on $date';
  }

  @override
  String formatTrendingCategory(String category) {
    return 'Category: $category';
  }

  @override
  String formatTrendingPostCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count posts', one: '1 post');
    return '$_temp0';
  }

  @override
  String formatViewHandle(String handle) {
    return 'View @$handle';
  }

  @override
  String get actionLikeThisPost => 'like this post';

  @override
  String get actionReplyToThisPost => 'reply to this post';

  @override
  String get actionRepostThisPost => 'repost this post';

  @override
  String get labelAbout => 'About';

  @override
  String get labelAccount => 'Account';

  @override
  String get labelAccountMaintenance => 'Account Maintenance';

  @override
  String get labelActiveProvider => 'Active Provider';

  @override
  String get labelAdultContent => 'Adult Content';

  @override
  String get labelAdvanced => 'Advanced';

  @override
  String get labelAlerts => 'ALERTS';

  @override
  String get labelAnimations => 'Animations';

  @override
  String get labelAppearance => 'Appearance';

  @override
  String get labelAppPassword => 'App Password';

  @override
  String get labelAppPasswordLogin => 'App Password Login';

  @override
  String get labelAppViewProvider => 'AppView Provider';

  @override
  String get labelAtExplorer => 'AT Explorer';

  @override
  String get labelAtProtocolConnection => 'AT Protocol Connection';

  @override
  String get labelAuditFollows => 'Audit Follows';

  @override
  String get labelBack => 'Back';

  @override
  String get labelBookmarksAndLikes => 'Bookmarks & Likes';

  @override
  String get labelBookmarkActions => 'Bookmark actions';

  @override
  String get labelBookmarkedPost => 'Bookmarked Post';

  @override
  String get labelBookmarks => 'Bookmarks';

  @override
  String get labelBluesky => 'Bluesky';

  @override
  String get labelCacheCleared => 'Cache cleared';

  @override
  String get labelChooseYourPortal => 'Choose your portal';

  @override
  String get labelCleanFollows => 'Clean Follows';

  @override
  String get labelClearCache => 'Clear Cache';

  @override
  String get labelCommunity => 'Community';

  @override
  String get labelConstellationUrl => 'Constellation URL';

  @override
  String get labelContentModeration => 'Content Moderation';

  @override
  String get labelContinueSignIn => 'Continue sign in';

  @override
  String get labelCrashReporting => 'Crash Reporting';

  @override
  String get labelCrashlyticsTestCrash => 'Crashlytics Test Crash';

  @override
  String get labelCrossProviderFallback => 'Cross-Provider Fallback';

  @override
  String get labelDangerZone => 'Danger Zone';

  @override
  String get labelDark => 'Dark';

  @override
  String get labelDebug => 'Debug';

  @override
  String get labelDeveloper => 'Developer';

  @override
  String get labelFeedLayout => 'Feed Layout';

  @override
  String get labelFeeds => 'Feeds';

  @override
  String get labelForceNextXrpc401 => 'Force Next XRPC 401';

  @override
  String get labelGoOffline => 'Go Offline';

  @override
  String get labelGuest => 'Guest';

  @override
  String get labelHealth => 'Health';

  @override
  String get labelHandle => 'Handle';

  @override
  String get labelHide => 'Hide';

  @override
  String get labelHome => 'HOME';

  @override
  String get labelLastError => 'Last Error';

  @override
  String get labelLastFallback => 'Last Fallback';

  @override
  String get labelLastHealthCheck => 'Last Health Check';

  @override
  String get labelLayout => 'Layout';

  @override
  String get labelLight => 'Light';

  @override
  String get labelLogOut => 'Log Out';

  @override
  String get labelLogs => 'Logs';

  @override
  String get labelMessages => 'Messages';

  @override
  String get labelModeration => 'Moderation';

  @override
  String get labelNavigation => 'Navigation';

  @override
  String get labelNewPost => 'New Post';

  @override
  String get labelNow => 'NOW';

  @override
  String get labelNotifications => 'Notifications';

  @override
  String get labelOpenMenu => 'Open menu';

  @override
  String get labelPrivacyPolicy => 'Privacy Policy';

  @override
  String get labelProfile => 'PROFILE';

  @override
  String get labelProviderDiagnostics => 'Provider Diagnostics';

  @override
  String get labelRefreshProviderHealth => 'Refresh Provider Health';

  @override
  String get labelResetSignInData => 'Reset Sign-In Data';

  @override
  String get labelRoamTheAtmosphere => 'Roam the ATmosphere';

  @override
  String get labelSearch => 'Search';

  @override
  String get labelSearchPosts => 'Search Posts';

  @override
  String get labelJumpToProfile => 'Jump to profile';

  @override
  String get labelPosts => 'Posts';

  @override
  String get labelPeople => 'People';

  @override
  String get labelStarterPacks => 'Starter Packs';

  @override
  String get labelSortBy => 'Sort by';

  @override
  String get labelTop => 'Top';

  @override
  String get labelLatest => 'Latest';

  @override
  String get labelFilters => 'Filters';

  @override
  String get labelPostFilters => 'Post filters';

  @override
  String get labelMentions => 'Mentions';

  @override
  String get labelAuthor => 'Author';

  @override
  String get labelAuthorFixed => 'Author (fixed)';

  @override
  String get labelLanguage => 'Language';

  @override
  String get labelDomain => 'Domain';

  @override
  String get labelUrl => 'URL';

  @override
  String get labelTags => 'Tags';

  @override
  String get labelSince => 'Since';

  @override
  String get labelUntil => 'Until';

  @override
  String get labelClearSince => 'Clear since';

  @override
  String get labelClearUntil => 'Clear until';

  @override
  String get labelClearLocalBookmarks => 'Clear local bookmarks';

  @override
  String get labelCopyLink => 'Copy Link';

  @override
  String get labelDeletePost => 'Delete Post';

  @override
  String get labelEditPost => 'Edit Post';

  @override
  String get labelLiked => 'Liked';

  @override
  String get labelLikedBy => 'LIKED BY';

  @override
  String get labelLikedPost => 'Liked Post';

  @override
  String get labelLocal => 'Local';

  @override
  String get labelOpenPost => 'Open post';

  @override
  String get labelQuotePost => 'Quote Post';

  @override
  String get labelQuoteReposts => 'QUOTE / REPOSTS';

  @override
  String get labelQuotes => 'Quotes';

  @override
  String get labelRemoveFromBluesky => 'Remove from Bluesky';

  @override
  String get labelRemoveLocalSave => 'Remove local save';

  @override
  String get labelReportPost => 'Report Post';

  @override
  String get labelRepost => 'Repost';

  @override
  String get labelRepostedBy => 'REPOSTED BY';

  @override
  String get labelReposts => 'Reposts';

  @override
  String get labelSaveImage => 'Save image';

  @override
  String get labelSaveLocally => 'Save locally';

  @override
  String get labelSaveToBluesky => 'Save to Bluesky';

  @override
  String get labelSavedAccounts => 'Saved accounts';

  @override
  String get labelSearchNav => 'SEARCH';

  @override
  String get labelSemanticSearch => 'Semantic Search';

  @override
  String get labelShowLikedUsers => 'Show Liked Users';

  @override
  String get labelShowQuoteRepostList => 'Show Quote/Repost List';

  @override
  String get labelSettings => 'Settings';

  @override
  String get labelShow => 'Show';

  @override
  String get labelSignInRequired => 'Sign in required';

  @override
  String get labelSlingshotIdentityFallback => 'Slingshot Identity Fallback';

  @override
  String get labelStartingSignIn => 'Starting sign in';

  @override
  String get labelSystem => 'System';

  @override
  String get labelTermsOfService => 'Terms of Service';

  @override
  String get labelTheme => 'THEME';

  @override
  String get labelThreadAutoCollapse => 'Thread Auto-Collapse';

  @override
  String get labelTroubleshooting => 'Troubleshooting';

  @override
  String get labelTopics => 'Topics';

  @override
  String get labelTrending => 'Trending';

  @override
  String get labelSuggested => 'Suggested';

  @override
  String get labelUnrepost => 'Unrepost';

  @override
  String get labelTypeaheadProvider => 'Typeahead Provider';

  @override
  String get labelVideoUploadLimits => 'Video Upload Limits';

  @override
  String get messageAppPasswordGeneratedViaBluesky =>
      'Can be generated via Bluesky\'s App Passwords section at bsky.app.';

  @override
  String get messageAppViewDebug401Armed => 'Armed: next XRPC request will return debug 401 Unauthorized';

  @override
  String get messageBlueskyEndpointSelected => 'Bluesky official endpoint selected.';

  @override
  String get messageBookmarksAndLikesSubtitle => 'View your bookmarked and liked posts';

  @override
  String get messageChooseProviderSubtitle => 'Choose the AppView provider used for sign in and public reads.';

  @override
  String get messageCleanFollowsSubtitle => 'Audit and unfollow problematic accounts in bulk';

  @override
  String get messageClearCacheSubtitle =>
      'Remove cached posts, profiles, images, feeds, threads, and semantic search data';

  @override
  String get messageCommunityTypeaheadSelected => 'Community (waow.tech) selected. Third-party service.';

  @override
  String get messageContentModerationSubtitle => 'Manage labelers and visibility rules';

  @override
  String get messageAdultContentEnabled => '18+ labels can be configured';

  @override
  String get messageAdultContentRequired => 'Required before 18+ labels can be configured';

  @override
  String get messageCrashReportingDisabled => 'Disabled. Crash and error reports are not sent.';

  @override
  String get messageCrashReportingEnabled => 'Enabled. Crash and error reports are sent to improve stability.';

  @override
  String get messageCrashlyticsTestCrashSubtitle => 'Intentionally crash to validate Crashlytics reports';

  @override
  String get messageCrossProviderFallbackSubtitle =>
      'Retry public reads on the alternate AppView when transient errors occur';

  @override
  String get messageDeveloperGoOfflineSubtitle => 'Turn off online connectivity';

  @override
  String get messageFeedLayoutCard => 'Card';

  @override
  String get messageLoadingSavedAccounts => 'Loading saved accounts...';

  @override
  String get messageFeedLayoutCompact => 'Compact';

  @override
  String get messageFeedsSubtitle => 'Manage pinned and saved feeds';

  @override
  String get messageLinkCopiedToClipboard => 'Link copied to clipboard';

  @override
  String get messageLoadingTrendingTopics => 'Loading trending topics';

  @override
  String get messageForceNextXrpc401Subtitle =>
      'Debug-only: next network request returns Unauthorized to test token refresh';

  @override
  String get messageManageSemanticSearchSubtitle => 'Manage semantic search from Bookmarks & Likes -> Search';

  @override
  String get messageMetadataTemporarilyUnavailable => 'Metadata temporarily unavailable';

  @override
  String get messageModeratedContentCannotReveal => 'Hidden by your moderation settings and cannot be revealed here.';

  @override
  String get messageModeratedContentCanReveal => 'Hidden by your moderation settings. You can reveal it for this view.';

  @override
  String get messageProviderDiagnosticsSubtitle =>
      'Moderation/ranking can differ by provider. Verify health and recent fallback state.';

  @override
  String get messageLikedPostsUnavailable => 'Liked posts are unavailable right now.';

  @override
  String get messageNoBookmarks => 'No bookmarks';

  @override
  String get messageNoBookmarksSubtitle => 'Posts you bookmark will appear here';

  @override
  String get messageNoBookmarksInSource => 'No bookmarks in this source';

  @override
  String get messageNoBookmarksInSourceSubtitle => 'Try switching tabs or saving posts to this source';

  @override
  String get messageNoInteractionsYet => 'No interactions yet';

  @override
  String get messageNoLikedPosts => 'No liked posts';

  @override
  String get messageNoLikedPostsSubtitle => 'Posts you like will appear here after sync';

  @override
  String get messageNoQuotesYet => 'No quotes yet';

  @override
  String get messageNoRepostsYet => 'No reposts yet';

  @override
  String get messageNoTrendingTopicsRightNow => 'No trending topics right now';

  @override
  String get messagePostDeleted => 'Post deleted';

  @override
  String get messageQuotePostSubtitle => 'Quote this post with your own text';

  @override
  String get messageQuotedPostBlocked => 'Quoted post is blocked';

  @override
  String get messageQuotedPostNotFound => 'Quoted post not found';

  @override
  String get messageQuotedPostUnavailable => 'Quoted post is unavailable';

  @override
  String get messageRemoveRepostSubtitle => 'Remove this repost';

  @override
  String get messageReplyInThread => 'Reply in a thread';

  @override
  String get messageShareThisPostSubtitle => 'Share this post';

  @override
  String get messageShowLikedUsersSubtitle => 'View who liked this post';

  @override
  String get messageShowQuoteRepostListSubtitle => 'View quote posts and expand reposts';

  @override
  String get messageRefreshProviderHealthSubtitle => 'Probe public AppView endpoints now';

  @override
  String get messageResetSignInDataSubtitle =>
      'Troubleshoot OAuth or account-switching issues by clearing local sessions on this device';

  @override
  String get messageSearchSubtitle => 'Search';

  @override
  String get messageClearSearchHistoryContent => 'This will delete all your recent searches.';

  @override
  String get messageClearSearchHistoryTitle => 'Clear search history?';

  @override
  String get messageStartTypingToSearchHandles => 'Start typing to search handles.';

  @override
  String get messageStarterPackSearchApiUnavailable => 'Starter pack search is not available in the API yet.';

  @override
  String get messageStarterPackSearchUnavailableTitle => 'Starter Pack Search Is Unavailable';

  @override
  String get messageStarterPackSearchUnavailableBody =>
      '(Starter Pack Search is not yet implemented in the BlueSky API)';

  @override
  String get messageTrackApiProgress => 'Track API progress';

  @override
  String get messageCouldNotOpenIssueLink => 'Could not open issue link.';

  @override
  String get messageSearchPostsPlaceholder => 'Search posts';

  @override
  String get messageSearchThisProfilesPostsPlaceholder => 'Search this profile\'s posts';

  @override
  String get messageSearchPeoplePlaceholder => 'Search people';

  @override
  String get messageSearchFeedsPlaceholder => 'Search feeds';

  @override
  String get messageStarterPackSearchUnavailablePlaceholder => 'Starter pack search unavailable';

  @override
  String get messageSlingshotIdentityFallbackSubtitle =>
      'If handle lookup fails, use Slingshot to find your DID and PDS so sign-in can continue';

  @override
  String get messageThreadAutoCollapseSubtitle => 'Collapse reply branches deeper than the selected level';

  @override
  String get messageTurnOffNonEssentialMotion => 'Turn off non-essential motion effects';

  @override
  String get messageVideoUploadLimitsSubtitle => 'Check your daily video quota';

  @override
  String get placeholderAppPassword => 'xxxx-xxxx-xxxx-xxxx';

  @override
  String get placeholderHandleOrDid => 'username.bsky.social or did:plc:...';

  @override
  String get promptHandleOrDid => 'Handle or DID';

  @override
  String get validationEnterAppPassword => 'Enter your app password';
}
