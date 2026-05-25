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
  String get buttonCompose => 'Compose';

  @override
  String get buttonClearCache => 'Clear Cache';

  @override
  String get buttonContinue => 'Continue';

  @override
  String get buttonClearLocal => 'Clear Local';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonDiscard => 'Discard';

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
  String get buttonCopyReport => 'Copy report';

  @override
  String get buttonClearAll => 'Clear all';

  @override
  String get buttonEmailReport => 'Email report';

  @override
  String get buttonOpen => 'Open';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonPost => 'Post';

  @override
  String get buttonResetSignInData => 'Reset Sign-In Data';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonSaveChanges => 'Save Changes';

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
  String get commonJustNow => 'Just now';

  @override
  String get commonNotCheckedYet => 'Not checked yet';

  @override
  String get commonOff => 'Off';

  @override
  String get commonUnknown => 'unknown';

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
  String get dialogDeleteDraftTitle => 'Delete Draft?';

  @override
  String get dialogDiscardChangesContent => 'You have unsaved edits. Discard them and leave?';

  @override
  String get dialogDiscardChangesTitle => 'Discard Changes?';

  @override
  String get dialogEditAlgorithmContent =>
      'Lazurite saves edits by deleting and recreating the post record with the same URI. During re-indexing, ranking, counters, and search visibility can shift, and updates may take time to appear everywhere.';

  @override
  String get dialogEditAlgorithmTitle => 'How Post Editing Works';

  @override
  String get dialogSaveDraftContent => 'You have unsaved content. Would you like to save it as a draft?';

  @override
  String get dialogSaveDraftTitle => 'Save Draft?';

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
  String formatFontSizeOption(String label, int size) {
    return '$label ($size)';
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
  String get labelRepostedByCard => 'Reposted by';

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
  String formatComposeFailedToPickImage(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String formatComposeFailedToPickVideo(Object error) {
    return 'Failed to pick video: $error';
  }

  @override
  String formatComposeFailedToSaveChanges(Object error) {
    return 'Failed to save changes: $error';
  }

  @override
  String formatComposeFailedToSubmitPost(Object error) {
    return 'Failed to submit post: $error';
  }

  @override
  String formatComposeImageTooLarge(String fileName, String sizeMb) {
    return 'Image \"$fileName\" is $sizeMb MB - max 1 MB.';
  }

  @override
  String formatComposeQuotingHandle(String handle) {
    return 'Quoting @$handle';
  }

  @override
  String formatComposeScheduledFor(String dateTime) {
    return 'Scheduled for $dateTime';
  }

  @override
  String formatComposeVideoReadyWithAltText(String altText) {
    return 'Ready - \"$altText\"';
  }

  @override
  String formatComposeVideoTooLarge(String sizeMb) {
    return 'Video is $sizeMb MB - exceeds the 100 MB limit.';
  }

  @override
  String formatDraftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count drafts', one: '1 draft');
    return '$_temp0';
  }

  @override
  String get actionLikeThisPost => 'like this post';

  @override
  String get actionReplyToThisPost => 'reply to this post';

  @override
  String get actionRepostThisPost => 'repost this post';

  @override
  String get actionPublishYourPost => 'publish your post';

  @override
  String get labelAbout => 'About';

  @override
  String get labelAccount => 'Account';

  @override
  String get labelAccountSettings => 'Account settings';

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
  String get labelBlacksky => 'Blacksky';

  @override
  String get labelAlt => 'ALT';

  @override
  String get labelCacheCleared => 'Cache cleared';

  @override
  String get labelChooseYourPortal => 'Choose your portal';

  @override
  String get labelCleanFollows => 'Clean Follows';

  @override
  String get labelCodeFont => 'Code Font';

  @override
  String get labelClose => 'Close';

  @override
  String get labelClearCache => 'Clear Cache';

  @override
  String get labelCommunity => 'Community';

  @override
  String get labelConstellationUrl => 'Constellation URL';

  @override
  String get labelContentModeration => 'Content Moderation';

  @override
  String get labelContentFont => 'Content Font';

  @override
  String get labelContinueSignIn => 'Continue sign in';

  @override
  String get labelCrashReporting => 'Crash Reporting';

  @override
  String get labelCrashlyticsTestCrash => 'Crashlytics Test Crash';

  @override
  String get labelCrashReportScreenTest => 'Crash Report Screen Test';

  @override
  String get labelCrashReportError => 'Error';

  @override
  String get labelCrashReportRelevantLogs => 'Relevant logs';

  @override
  String get labelCrashReportStackTrace => 'Stack trace';

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
  String get labelFontSize => 'Font Size';

  @override
  String get labelFontSizeSmall => 'Small';

  @override
  String get labelFontSizeNormal => 'Normal';

  @override
  String get labelFontSizeLarge => 'Large';

  @override
  String get labelGoOffline => 'Go Offline';

  @override
  String get labelGuest => 'Guest';

  @override
  String get labelHeadingFont => 'Heading Font';

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
  String get labelDeleteDraft => 'Delete draft';

  @override
  String get labelEditPost => 'Edit Post';

  @override
  String get labelLiked => 'Liked';

  @override
  String get labelLikedBy => 'LIKED BY';

  @override
  String get labelLikedPost => 'Liked Post';

  @override
  String get labelMoreInfo => 'More info';

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
  String get labelSchedule => 'Schedule';

  @override
  String get labelScheduled => 'Scheduled';

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
  String get labelVideo => 'Video';

  @override
  String get labelTopics => 'Topics';

  @override
  String get labelTrending => 'Trending';

  @override
  String get labelSuggested => 'Suggested';

  @override
  String get labelSuggestedFollows => 'Suggested Follows';

  @override
  String get labelUnrepost => 'Unrepost';

  @override
  String get labelTypeaheadProvider => 'Typeahead Provider';

  @override
  String get labelVideoUploadLimits => 'Video Upload Limits';

  @override
  String get messageAboutSubtitle => 'Stormlight Labs';

  @override
  String get messageAccountSettingsSubtitle => 'Feed display preferences and account defaults';

  @override
  String get messageAppPasswordGeneratedViaBluesky =>
      'Can be generated via Bluesky\'s App Passwords section at bsky.app.';

  @override
  String get messageAtExplorerSubtitle => 'View PDS Records';

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
  String get messageCrashReportScreenTestSubtitle =>
      'Open a recoverable Flutter error screen with copy and email actions';

  @override
  String get messageCrashReportCopied => 'Crash report copied';

  @override
  String get messageCrashReportInstructions =>
      'You can copy the crash report or open an email to send a summary to Stormlight Labs.';

  @override
  String get messageCrashReportPartial =>
      'Some report details could not be loaded. A minimal report is still available.';

  @override
  String get messageCrashReportEmailStackTraceTruncated => '[Stack trace truncated for email]';

  @override
  String formatCrashReportEmailBody(String error, String stackTrace) {
    return 'A Lazurite screen crashed.\n\nThe full report may be too large for email. Please use Copy report in the app if support asks for the full details.\n\nError:\n$error\n\nStack trace:\n$stackTrace';
  }

  @override
  String get messageCrossProviderFallbackSubtitle =>
      'Retry public reads on the alternate AppView when transient errors occur';

  @override
  String get messageDeveloperGoOfflineSubtitle => 'Turn off online connectivity';

  @override
  String get messageFeedLayoutComfortable => 'Comfortable';

  @override
  String get messageLoadingSavedAccounts => 'Loading saved accounts...';

  @override
  String get messageNoRecentLogLinesAvailable => 'No recent log lines were available.';

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
  String get messageLogsSubtitle => 'View app log files';

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
  String get messagePrivacyPolicySubtitle => 'How Lazurite handles data';

  @override
  String get messageLikedPostsUnavailable => 'Liked posts are unavailable right now.';

  @override
  String get messageChangesSaved => 'Changes saved.';

  @override
  String get messageComposeAddAltText => 'Add alt text';

  @override
  String get messageComposeAddImage => 'Add image';

  @override
  String get messageComposeAddVideo => 'Add video';

  @override
  String get messageComposeClearScheduledTime => 'Clear scheduled time';

  @override
  String get messageComposeDescribeImage => 'Describe the image';

  @override
  String get messageComposeDescribeVideo => 'Describe the video';

  @override
  String get messageComposeDraftSaved => 'Draft saved';

  @override
  String get messageComposeDrafts => 'Drafts';

  @override
  String get messageComposeEditNotice =>
      'Edits are saved by replacing the record while keeping this post URI. Ranking, counts, and visibility may shift while networks re-index.';

  @override
  String get messageComposeImageAltTextTitle => 'Alt text';

  @override
  String get messageComposeImageMaxCount => 'Maximum 4 images allowed';

  @override
  String get messageComposeImageMustBeJpegPngWebp => 'Image must be JPEG, PNG, or WebP';

  @override
  String get messageComposeImageMustBeUnder1Mb => 'Image must be smaller than 1MB';

  @override
  String get messageComposeNoDraftsSaved => 'No drafts saved';

  @override
  String get messageComposeNoText => '(No text)';

  @override
  String get messageComposePlaceholder => 'What\'s on your mind?';

  @override
  String get messageComposePreviewUnavailable => 'Preview unavailable';

  @override
  String get messageComposeQuotingPost => 'Quoting post';

  @override
  String get messageComposeRemoveExistingMediaBeforeVideo => 'Remove existing media before adding a video';

  @override
  String get messageComposeRemoveImage => 'Remove image';

  @override
  String get messageComposeRemoveQuotedPost => 'Remove quoted post';

  @override
  String get messageComposeSaveDraft => 'Save draft';

  @override
  String get messageComposeVideoAltTextTitle => 'Video alt text';

  @override
  String get messageVideoCheckingUploadLimits => 'Checking upload limits...';

  @override
  String get messageVideoDailyUploadLimitReached => 'Daily video upload limit reached.';

  @override
  String get messageVideoProcessing => 'Processing...';

  @override
  String get messageVideoProcessingFailed => 'Video processing failed.';

  @override
  String get messageVideoProcessingTimedOut => 'Video processing timed out.';

  @override
  String get messageVideoReady => 'Ready';

  @override
  String get messageVideoReadyToUpload => 'Ready to upload';

  @override
  String get messageVideoUploadFailed => 'Upload failed - please try again.';

  @override
  String get messageVideoUploading => 'Uploading...';

  @override
  String get errorComposeChangedElsewhere => 'This post was changed elsewhere. Reopen it and try editing again.';

  @override
  String get errorComposeCouldNotConfirmEdit =>
      'Edit was submitted but could not be confirmed yet. Please reopen the post and verify.';

  @override
  String get errorComposeCouldNotSaveAndConfirmRecovery =>
      'Could not save changes and we could not confirm recovery. Reopen the thread and verify the post.';

  @override
  String get errorComposeEditContextMissing => 'Edit context is missing. Please reopen the editor and try again.';

  @override
  String get errorComposeFailedToCreatePost => 'Failed to create post. Please try again.';

  @override
  String get errorComposeFailedToSaveChanges => 'Failed to save changes. Please try again.';

  @override
  String get errorComposeFailedToUploadImage => 'Failed to upload image. Please try again.';

  @override
  String get errorComposeImageFileNotFound => 'Image file not found. Please re-attach and try again.';

  @override
  String get errorComposeNetworkSavedAsDraft => 'Network error - post saved as draft.';

  @override
  String get errorComposeOriginalPostRestored => 'Could not save changes. Your original post was restored.';

  @override
  String get errorComposeUnsupportedImageFormat => 'Unsupported image format. Use JPEG, PNG, or WebP.';

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
  String get messageNoLikedPostsYet => 'No liked posts yet';

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
  String get messageReplyingTo => 'Replying to';

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
  String get messageSearchForPeoplePlaceholder => 'Search for people';

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
  String get messageTermsOfServiceSubtitle => 'Usage rules and responsibilities';

  @override
  String get messageVideoUploadLimitsSubtitle => 'Check your daily video quota';

  @override
  String get placeholderAppPassword => 'xxxx-xxxx-xxxx-xxxx';

  @override
  String get placeholderHandleOrDid => 'username.bsky.social or did:plc:...';

  @override
  String get promptHandleOrDid => 'Handle or DID';

  @override
  String get buttonAddFeed => 'Add feed';

  @override
  String get buttonAddMembers => 'Add members';

  @override
  String get buttonBlock => 'Block';

  @override
  String get buttonCreate => 'Create';

  @override
  String get buttonEdit => 'Edit';

  @override
  String get buttonFollow => 'Follow';

  @override
  String get buttonFollowAll => 'Follow all';

  @override
  String get buttonFollowing => 'Following';

  @override
  String get buttonFollowingInProgress => 'Following…';

  @override
  String get buttonLoadMore => 'Load more';

  @override
  String get buttonMute => 'Mute';

  @override
  String get buttonScan => 'Scan';

  @override
  String get buttonSeeAll => 'See all';

  @override
  String get buttonShowAccounts => 'Show accounts';

  @override
  String get buttonSubmitReport => 'Submit Report';

  @override
  String get buttonUnblock => 'Unblock';

  @override
  String get buttonUnfollow => 'Unfollow';

  @override
  String buttonUnfollowSelected(int count) {
    return 'Unfollow Selected ($count)';
  }

  @override
  String get buttonUnmute => 'Unmute';

  @override
  String get dialogBlockAccountContent =>
      'They will not be able to see your posts or interact with you. They will not be notified that you blocked them.';

  @override
  String get dialogBlockAccountTitle => 'Block Account?';

  @override
  String get dialogDeleteListTitle => 'Delete list?';

  @override
  String get dialogDeleteStarterPackContent =>
      'This will permanently delete this starter pack and its backing list. This cannot be undone.';

  @override
  String get dialogDeleteStarterPackTitle => 'Delete starter pack';

  @override
  String get dialogMuteAccountContent => 'You will no longer see their posts or receive notifications from them.';

  @override
  String get dialogMuteAccountTitle => 'Mute Account?';

  @override
  String get dialogUnblockAccountContent => 'They will be able to see your posts and interact with you again.';

  @override
  String get dialogUnblockAccountTitle => 'Unblock Account?';

  @override
  String get dialogUnfollowAccountContent => 'You will no longer see their posts in your feed.';

  @override
  String get dialogUnfollowAccountTitle => 'Unfollow?';

  @override
  String get dialogUnmuteAccountContent => 'You will see their posts and receive notifications again.';

  @override
  String get dialogUnmuteAccountTitle => 'Unmute Account?';

  @override
  String get errorFailedToCreateStarterPack => 'Failed to create starter pack';

  @override
  String get errorFailedToLoadAccounts => 'Failed to load accounts';

  @override
  String get errorFailedToLoadFeed => 'Failed to load feed';

  @override
  String get errorFailedToLoadFeeds => 'Failed to load feeds';

  @override
  String get errorFailedToLoadList => 'Failed to load list';

  @override
  String get errorFailedToLoadLists => 'Failed to load lists';

  @override
  String get errorFailedToLoadMembers => 'Failed to load members';

  @override
  String get errorFailedToLoadMore => 'Failed to load more';

  @override
  String get errorFailedToLoadPosts => 'Failed to load posts';

  @override
  String get errorFailedToLoadProfile => 'Unable to load profile';

  @override
  String get errorFailedToLoadStarterPack => 'Failed to load starter pack';

  @override
  String get errorFailedToLoadStarterPacks => 'Failed to load starter packs';

  @override
  String get errorFailedToLoadSuggestions => 'Failed to load suggestions';

  @override
  String get errorFollowAuditFailed => 'Failed to complete follow audit.';

  @override
  String get errorImageTooLarge => 'Image must be smaller than 1MB';

  @override
  String get errorInvalidProfileImageType => 'Use a JPEG or PNG image';

  @override
  String get errorProfileImageReadFailed => 'Unable to read selected image';

  @override
  String get errorReportFailed => 'Unable to submit your report. Please try again later.';

  @override
  String get errorReportFailedTitle => 'Report Failed';

  @override
  String errorUnableToLoadConnections(String tab) {
    return 'Unable to load $tab';
  }

  @override
  String get errorUnableToUpdateProfile => 'Unable to update profile';

  @override
  String formatAccountCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count accounts', one: '1 account');
    return '$_temp0';
  }

  @override
  String formatBlockedByAccountsUnavailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blocked-by accounts',
      one: '1 blocked-by account',
    );
    return 'Found $_temp0, but public Bluesky profile details could not be loaded.';
  }

  @override
  String formatConnectionsLoading(String tab) {
    return 'Loading $tab...';
  }

  @override
  String formatConnectionsNoMatches(String tab, String query) {
    return 'No $tab match \"$query\"';
  }

  @override
  String formatConnectionsNoneFound(String tab) {
    return 'No $tab found';
  }

  @override
  String formatConnectionsSearching(int count) {
    return 'Searching $count accounts...';
  }

  @override
  String formatConnectionsSearched(int count) {
    return 'Searched $count accounts';
  }

  @override
  String formatConnectionsSearchStopped(int count) {
    return 'Search stopped after $count accounts';
  }

  @override
  String formatKnownFollowersLink(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count followers', one: '1 follower');
    return 'You know $_temp0';
  }

  @override
  String formatClassifyingProgress(int progress, int total) {
    return 'Classifying: $progress/$total';
  }

  @override
  String get formatDidCopied => 'DID copied to clipboard';

  @override
  String formatFetchingFollowsProgress(int progress, int total) {
    return 'Fetching follows: $progress/$total';
  }

  @override
  String get messageGettingFollowCount => 'Getting follow count...';

  @override
  String formatFollowedMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count members', one: '1 member');
    return 'Followed $_temp0';
  }

  @override
  String formatFollowsScanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count follows scanned for problematic accounts',
      one: '1 follow scanned for problematic accounts',
    );
    return '$_temp0';
  }

  @override
  String formatFollowAuditPromptWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count follows', one: '1 follow');
    return 'Scan your $_temp0 for deleted, suspended, blocked, and hidden accounts.';
  }

  @override
  String formatHideStatus(String status) {
    return 'Hide $status';
  }

  @override
  String formatJoinedDate(String date) {
    return 'Joined $date';
  }

  @override
  String formatJoinedRelative(String relativeTime) {
    return 'Joined $relativeTime';
  }

  @override
  String formatListByHandle(String handle) {
    return 'by @$handle';
  }

  @override
  String formatMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count members', one: '1 member');
    return '$_temp0';
  }

  @override
  String formatProfileReportTitle(String title, String handle) {
    return '$title by @$handle';
  }

  @override
  String formatProfileTextLimit(String label, int count) {
    return '$label must be $count characters or fewer';
  }

  @override
  String formatProfileTextTooLong(String label) {
    return '$label is too long';
  }

  @override
  String formatProfilesFailedToLoad(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count profiles could not be loaded.',
      one: '1 profile could not be loaded.',
    );
    return '$_temp0';
  }

  @override
  String formatReportSubmitted(String reportId) {
    return 'Thank you. Your report (ID: $reportId) has been submitted.';
  }

  @override
  String formatSelectedCount(int selected, int total) {
    return 'Selected: $selected/$total';
  }

  @override
  String formatShowStatus(String status) {
    return 'Show $status';
  }

  @override
  String formatUnavailableAccounts(int count) {
    return 'Unavailable accounts ($count)';
  }

  @override
  String formatUnfollowedAccounts(int count) {
    return 'Unfollowed $count account(s)';
  }

  @override
  String formatValidationRequiredMaxCharacters(int count) {
    return 'Required, max $count characters';
  }

  @override
  String get labelAddToList => 'Add to list';

  @override
  String get labelAuditFollowers => 'Audit Followers';

  @override
  String get labelBanner => 'Banner';

  @override
  String get labelBlockViaList => 'Block via list';

  @override
  String get labelBlockedBy => 'Blocked By';

  @override
  String get labelBlocking => 'Blocking';

  @override
  String get labelConnections => 'Connections';

  @override
  String get labelCopyDid => 'Copy DID';

  @override
  String get labelCreateList => 'Create list';

  @override
  String get labelCreateStarterPack => 'Create starter pack';

  @override
  String get labelCurateShort => 'CURATE';

  @override
  String get labelCurrentMembers => 'Current Members';

  @override
  String get labelCurationLists => 'Curation Lists';

  @override
  String get labelDescription => 'Description';

  @override
  String get labelDescriptionOptional => 'Description (optional)';

  @override
  String get labelDisplayName => 'Display name';

  @override
  String get labelEditList => 'Edit list';

  @override
  String get labelEditProfile => 'Edit profile';

  @override
  String get labelEditStarterPack => 'Edit starter pack';

  @override
  String get labelFeed => 'Feed';

  @override
  String get labelFollowers => 'Followers';

  @override
  String get labelKnownFollowers => 'Known';

  @override
  String get labelJoinedThisWeek => 'joined this week';

  @override
  String get labelJoinedTotal => 'joined total';

  @override
  String get labelFollowing => 'Following';

  @override
  String get labelList => 'List';

  @override
  String get labelLists => 'Lists';

  @override
  String get labelMedia => 'Media';

  @override
  String get labelMembers => 'Members';

  @override
  String get labelModerationLists => 'Moderation Lists';

  @override
  String get labelModerationShort => 'MOD';

  @override
  String get labelMuteList => 'Mute list';

  @override
  String get labelMutuals => 'Mutuals';

  @override
  String get labelMyLists => 'My Lists';

  @override
  String get labelName => 'Name';

  @override
  String get labelNewStarterPack => 'New Starter Pack';

  @override
  String get labelOtherLists => 'Other Lists';

  @override
  String get labelPronouns => 'Pronouns';

  @override
  String get labelProfileContext => 'Profile Context';

  @override
  String get labelProfileTitle => 'Profile';

  @override
  String get labelRecommendedFeeds => 'Recommended Feeds';

  @override
  String get labelReferenceLists => 'Reference Lists';

  @override
  String get labelReferenceShort => 'REFERENCE';

  @override
  String get labelReplies => 'Replies';

  @override
  String get labelReport => 'Report';

  @override
  String get labelReportAccount => 'Report Account';

  @override
  String get labelReportReason => 'Reason';

  @override
  String get labelReportReasonExplanationRequired => 'Explanation (required)';

  @override
  String get labelReportReasonHarassment => 'Harassment';

  @override
  String get labelReportReasonMisleading => 'Misleading';

  @override
  String get labelReportReasonOther => 'Other';

  @override
  String get labelReportReasonSexualContent => 'Sexual Content';

  @override
  String get labelReportReasonSpam => 'Spam';

  @override
  String get labelReportReasonViolation => 'Violation';

  @override
  String get labelReportSubmitted => 'Report Submitted';

  @override
  String get labelSelectAll => 'Select All';

  @override
  String get labelSelectFeed => 'Select a feed';

  @override
  String get labelShareProfile => 'Share Profile';

  @override
  String get labelStarterPack => 'Starter Pack';

  @override
  String get labelType => 'Type';

  @override
  String get labelTotalJoined => 'total joined';

  @override
  String get labelUnavailableLikedPost => 'Unavailable liked post';

  @override
  String get labelUnblockViaList => 'Unblock via list';

  @override
  String get labelUnmuteList => 'Unmute list';

  @override
  String get labelUpToThree => '(up to 3)';

  @override
  String get labelWebsite => 'Website';

  @override
  String get labelYou => 'You';

  @override
  String get messageBlockedByContextNotice =>
      'Blocks are a normal part of social media. This data is public on the AT Protocol.';

  @override
  String get messageBlockingOnlyOwnProfile => 'Blocking information is only available when viewing your own profile.';

  @override
  String get messageChangeAvatarImage => 'Change avatar image';

  @override
  String get messageChangeBannerImage => 'Change banner image';

  @override
  String get messageEnterValidWebsite => 'Enter a valid website';

  @override
  String get messageFeedUnavailableForModerationLists => 'Feed not available for moderation lists';

  @override
  String get messageFollowAuditIntro => 'Scan your follows for deleted, suspended, blocked, and hidden accounts.';

  @override
  String get messageFollowAuditStartPrompt => 'Tap Scan to audit your follow list.';

  @override
  String get messageNoAccountsBlockedThisUser => 'No accounts have blocked this user';

  @override
  String get messageNoListsYet => 'No lists yet';

  @override
  String get messageNoMembers => 'No members';

  @override
  String get messageNoMembersYet => 'No members yet';

  @override
  String get messageNoMembersYetSearch => 'No members yet. Search above to add people.';

  @override
  String get messageNoMediaPostsYet => 'No media posts yet';

  @override
  String get messageNoPostsYet => 'No posts yet';

  @override
  String get messageNoProblematicFollows => 'No problematic follows found';

  @override
  String get messageNoRepliesYet => 'No replies yet';

  @override
  String get messageNoResultsForFilters => 'No results visible for the current filters.';

  @override
  String get messageNoStarterPacksYet => 'No starter packs yet';

  @override
  String get messageNoSuggestionsFound => 'No suggestions found';

  @override
  String get messageNotBlockingAnyone => 'Not blocking anyone';

  @override
  String get messageNotOnAnyLists => 'Not on any lists';

  @override
  String get messageProfileUnavailable => 'Profile unavailable';

  @override
  String get messageProfileUpdated => 'Profile updated';

  @override
  String get messageReportExplanationHint => 'Please explain why you are reporting this...';

  @override
  String get messageReportReasonHarassmentDescription => 'Harassment or rude behaviour';

  @override
  String get messageReportReasonMisleadingDescription => 'Misleading or deceptive content';

  @override
  String get messageReportReasonOtherDescription => 'Other reason (requires explanation)';

  @override
  String get messageReportReasonSexualContentDescription => 'Unwanted sexual content';

  @override
  String get messageReportReasonSpamDescription => 'Spam or unsolicited content';

  @override
  String get messageReportReasonViolationDescription => 'Violates community guidelines';

  @override
  String get messageSearchConnectionsPlaceholder => 'Search handle, name, or description';

  @override
  String get messageSearchPeopleToAddPlaceholder => 'Search for people to add';

  @override
  String get messageSomeBlockedAccountsUnavailable => 'Some blocked accounts are suspended or unavailable.';

  @override
  String get messageSuggestedFollowsUnavailable => 'Suggested follows are unavailable right now.';

  @override
  String get messageUnavailableAccountsDescription =>
      'These accounts are suspended or their public profile could not be fetched.';

  @override
  String get statusBlockedBy => 'Blocked by';

  @override
  String get statusBlocking => 'Blocking';

  @override
  String get statusDeactivated => 'Deactivated';

  @override
  String get statusDeleted => 'Deleted';

  @override
  String get statusHidden => 'Hidden';

  @override
  String get statusMutualBlock => 'Mutual block';

  @override
  String get statusSelfFollow => 'Self-follow';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get tooltipClearSearch => 'Clear search';

  @override
  String get tooltipJumpToTop => 'Jump to top';

  @override
  String get validationEnterValidWebsite => 'Enter a valid website';

  @override
  String get accountSwitcherNoOtherAccounts =>
      'No other signed-in accounts yet. Add an account to switch between profiles.';

  @override
  String get buttonAddAccount => 'Add Account';

  @override
  String get buttonCopyAll => 'Copy All';

  @override
  String get buttonMarkAllRead => 'Mark All Read';

  @override
  String get errorFailedToAddAccount => 'Failed to add account';

  @override
  String get errorFailedToLoadMessages => 'Failed to load messages';

  @override
  String get errorFailedToLoadNotifications => 'Failed to load notifications';

  @override
  String get errorUnableToRemoveAccountNow => 'Unable to remove account right now.';

  @override
  String formatActorListTwo(String first, String second) {
    return '$first and $second';
  }

  @override
  String formatActorListWithOthers(String first, String second, int count) {
    return '$first, $second, and $count others';
  }

  @override
  String formatMonthDay(String month, int day) {
    return '$month $day';
  }

  @override
  String formatRemoveAccountContent(String handle) {
    return 'Remove @$handle from this device?';
  }

  @override
  String get labelAccounts => 'Accounts';

  @override
  String get labelAlertsTitle => 'Alerts';

  @override
  String get labelConversation => 'Conversation';

  @override
  String get labelFollows => 'Follows';

  @override
  String get labelLikes => 'Likes';

  @override
  String get labelMessageRequests => 'Requests';

  @override
  String get labelOther => 'Other';

  @override
  String get labelPrimary => 'Primary';

  @override
  String get labelSomeone => 'Someone';

  @override
  String get messageCopied => 'Message copied';

  @override
  String get messageDeleted => 'Message deleted';

  @override
  String get messageLocalNotificationFallbackBody => 'sent a notification';

  @override
  String get messageNewNotification => 'New notification';

  @override
  String get messageNoConnection => 'No connection';

  @override
  String get messageNoConversationsYet => 'No conversations yet';

  @override
  String get messageNoMessageRequests => 'No message requests';

  @override
  String get messageNoMessagesYet => 'No messages yet';

  @override
  String get messageNoNotificationsYet => 'No notifications yet';

  @override
  String get messageNotificationContactMatch => 'joined from your contacts';

  @override
  String get messageNotificationFollow => 'followed you';

  @override
  String get messageNotificationInteracted => 'interacted with you';

  @override
  String get messageNotificationLike => 'liked your post';

  @override
  String get messageNotificationLikeViaRepost => 'liked your repost';

  @override
  String get messageNotificationMention => 'mentioned you';

  @override
  String get messageNotificationQuote => 'quoted your post';

  @override
  String get messageNotificationReply => 'replied to your post';

  @override
  String get messageNotificationRepost => 'reposted your post';

  @override
  String get messageNotificationRepostViaRepost => 'reposted your repost';

  @override
  String get messageNotificationStarterPackJoined => 'joined via your starter pack';

  @override
  String get messageNotificationSubscribedPost => 'posted a new update';

  @override
  String get messageNotificationUnverified => 'removed your verification';

  @override
  String get messageNotificationVerified => 'verified your account';

  @override
  String get messagePlaceholder => 'Message…';

  @override
  String get messagePleaseSignInAgainForAccount => 'Please sign in again for that account.';

  @override
  String get messageReconnectToLoadMessages => 'Reconnect to load messages.';

  @override
  String get messageReconnectToLoadNotifications => 'Reconnect to load notifications.';

  @override
  String get messageThreadCopied => 'Thread copied';

  @override
  String get messageToday => 'Today';

  @override
  String get messageYesterday => 'Yesterday';

  @override
  String get placeholderUsernameBskySocial => 'username.bsky.social';

  @override
  String get validationEnterBlueskyHandleOrDid => 'Enter a Bluesky handle or DID';

  @override
  String get validationEnterCompleteDid => 'Enter a complete DID like did:plc:... or did:web:...';

  @override
  String get validationEnterFullHandle => 'Enter a full handle like username.bsky.social';

  @override
  String get validationUseSupportedDid => 'Use a did:plc:... or did:web:... identifier';

  @override
  String get validationEnterAppPassword => 'Enter your app password';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonAdding => 'Adding...';

  @override
  String get buttonInspiredByPdsLs => 'Inspired by pds.ls';

  @override
  String get buttonCopyJson => 'Copy JSON';

  @override
  String get buttonResolve => 'Resolve';

  @override
  String get buttonUnsubscribe => 'Unsubscribe';

  @override
  String get dialogAddLabelerTitle => 'Add labeler';

  @override
  String get dialogClearAllLogsContent => 'This will permanently delete all log files. This action cannot be undone.';

  @override
  String get dialogClearAllLogsTitle => 'Clear all logs?';

  @override
  String get errorFailedToLoadLogs => 'Failed to load logs';

  @override
  String get errorFailedToLoadModerationSettings => 'Failed to load moderation settings';

  @override
  String errorFailedToUnsubscribeLabeler(Object error) {
    return 'Failed to unsubscribe: $error';
  }

  @override
  String errorFailedToUpdateAdultContent(Object error) {
    return 'Failed to update adult content: $error';
  }

  @override
  String errorFailedToUpdateLabelPreference(Object error) {
    return 'Failed to update preference: $error';
  }

  @override
  String errorFailedToUpdateLabelerSubscription(Object error) {
    return 'Failed to update subscription: $error';
  }

  @override
  String get errorLabelerDidRequired => 'Enter a labeler DID.';

  @override
  String get errorLabelerNotFound => 'Labeler not found.';

  @override
  String get errorNoLabelerFoundForDid => 'No labeler found for that DID.';

  @override
  String get errorUnableToLoadLabeler => 'Unable to load labeler';

  @override
  String formatAddLabelerLimit(int current, int max) {
    return 'Add ($current/$max)';
  }

  @override
  String formatCollectionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count collections', one: '1 collection');
    return '$_temp0';
  }

  @override
  String formatCid(String cid) {
    return 'CID: $cid';
  }

  @override
  String formatCustomLabelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count custom labels',
      one: '1 custom label',
    );
    return '$_temp0';
  }

  @override
  String formatDefinitionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count definitions', one: '1 definition');
    return '$_temp0';
  }

  @override
  String formatLoadedRecordsCount(int count) {
    return '$count loaded';
  }

  @override
  String formatLoadedRecordsOfTotal(int loaded, int total) {
    return '$loaded of $total';
  }

  @override
  String formatModerationSourceLabel(String source) {
    return '$source label';
  }

  @override
  String formatPolicyBlur(String value) {
    return 'Blur $value';
  }

  @override
  String formatPolicyDefault(String value) {
    return 'Default $value';
  }

  @override
  String formatPolicyId(String identifier) {
    return 'ID $identifier';
  }

  @override
  String formatPolicySeverity(String value) {
    return 'Severity $value';
  }

  @override
  String formatPublishedValueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count published values',
      one: '1 published value',
    );
    return '$_temp0';
  }

  @override
  String formatRecordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count records', one: '1 record');
    return '$_temp0';
  }

  @override
  String formatSubscribedToLabeler(String name) {
    return 'Subscribed to $name';
  }

  @override
  String get labelAdultContentSetting => 'Adult content';

  @override
  String get labelAdultOnlyShort => '18+';

  @override
  String get labelAlwaysOn => 'Always on';

  @override
  String get labelAutoScroll => 'Auto-scroll';

  @override
  String get labelBlueskyModeration => 'Bluesky moderation';

  @override
  String get labelBuiltIn => 'Built-in';

  @override
  String get labelBuiltInLabeler => 'Built-in labeler';

  @override
  String get labelBuiltInModeration => 'Built-in moderation';

  @override
  String get labelBlockedAccount => 'Blocked account';

  @override
  String get labelBlockedByAccount => 'Blocked by account';

  @override
  String get labelBlockedRelationship => 'Blocked relationship';

  @override
  String get labelCollections => 'COLLECTIONS';

  @override
  String get labelContentPreferenceHide => 'Hide';

  @override
  String get labelContentPreferenceIgnore => 'Ignore';

  @override
  String get labelContentPreferenceWarn => 'Warn';

  @override
  String get labelCustomLabelers => 'Custom labelers';

  @override
  String get labelLabeler => 'Labeler';

  @override
  String get labelLabelerDid => 'Labeler DID';

  @override
  String get labelLabelersAndContentModeration => 'Labelers and content moderation';

  @override
  String get labelLabelPreferences => 'Label preferences';

  @override
  String get labelHiddenContent => 'Hidden content';

  @override
  String get labelLogLevelDebug => 'Debug';

  @override
  String get labelLogLevelError => 'Error';

  @override
  String get labelLogLevelFatal => 'Fatal';

  @override
  String get labelLogLevelInfo => 'Info';

  @override
  String get labelLogLevelTrace => 'Trace';

  @override
  String get labelLogLevelWarning => 'Warning';

  @override
  String get labelModerationNote => 'Moderation note';

  @override
  String get labelModerationSourceBluesky => 'Bluesky';

  @override
  String get labelModerationSourceSubscribedLabeler => 'Subscribed labeler';

  @override
  String get labelMutedAccount => 'Muted account';

  @override
  String get labelMutedPhrase => 'Muted phrase';

  @override
  String get labelNoCustomLabelDefinitions => 'No custom label definitions';

  @override
  String get labelNoCustomLabelers => 'No custom labelers';

  @override
  String get labelPdsExplorer => 'PDS Explorer';

  @override
  String get labelPublishedPolicies => 'Published policies';

  @override
  String get labelRecordJson => 'Record JSON';

  @override
  String get labelRefresh => 'Refresh';

  @override
  String get labelRepository => 'Repository';

  @override
  String get labelSubscribed => 'Subscribed';

  @override
  String get labelSensitiveContent => 'Sensitive content';

  @override
  String get labelUnknown => 'Unknown';

  @override
  String get messageAddLabelerDidHelper => 'Paste a labeler DID to review and subscribe to its labels.';

  @override
  String get messageAdultContentRequiredForLabels => 'Required before 18+ label preferences can be changed.';

  @override
  String get messageBuiltInLabelerActiveWhenUnavailable =>
      'The built-in labeler is active even if its details cannot be loaded right now.';

  @override
  String get messageBuiltInLabelerAlwaysActive => 'This labeler is always active.';

  @override
  String get messageDevtoolsEmptyState => 'Enter a handle, DID, or AT-URI to explore\na user\'s repository.';

  @override
  String get messageEnableAdultContentForLabel => 'Enable adult content to change this 18+ label.';

  @override
  String get messageBlockedAccountDescription => 'This account is blocked';

  @override
  String get messageBlockedByAccountDescription => 'This account has blocked you';

  @override
  String get messageBlockedRelationshipDescription => 'This content is limited by a block relationship';

  @override
  String get messageHiddenContentDescription => 'This content is hidden by moderation rules';

  @override
  String get messageJsonCopiedToClipboard => 'JSON copied to clipboard';

  @override
  String get messageLogsEmpty => 'No logs yet';

  @override
  String get messageLogsEmptySubtitle => 'Log entries will appear here';

  @override
  String get messageModerationSettingsHeroSubtitle =>
      'Manage adult-content visibility, subscribed labelers, and the rules each labeler applies to posts and profiles.';

  @override
  String get messageModerationGuidanceApplies => 'Moderation guidance applies here';

  @override
  String get messageMutedAccountDescription => 'Muted content is being downranked here';

  @override
  String get messageMutedPhraseDescription => 'A muted phrase matched this content';

  @override
  String get messageNoCustomLabelDefinitions => 'This labeler publishes values, but not localized custom definitions.';

  @override
  String get messageNoCustomLabelers => 'Add a labeler DID to subscribe and configure its custom labels.';

  @override
  String get messageNoLabelDescriptionAvailable => 'No description available for this label.';

  @override
  String get messageNoLogFileAvailable => 'No log file available';

  @override
  String get messageRecordCountsUnavailable => 'Record counts unavailable';

  @override
  String get messageRecordCountsLoading => 'Counting records...';

  @override
  String get messageSubscribedLabelersHeaders =>
      'Subscribed labelers are added to your moderation headers and preferences.';

  @override
  String get messageUnableToOpenShareSheet => 'Unable to open share sheet. Please try again.';

  @override
  String get messageUnableToOpenEmailApp => 'Unable to open email app. Please copy the report instead.';

  @override
  String get placeholderHandleDidOrAtUri => 'Handle, DID, or at:// URI';

  @override
  String get placeholderLabelerDid => 'did:plc:examplelabeler';

  @override
  String get placeholderLogsFilter => 'Filter logs...';

  @override
  String get subjectLazuriteLogs => 'Lazurite logs';

  @override
  String get subjectLazuriteCrashReport => 'Lazurite crash report';

  @override
  String get tooltipClearAllLogs => 'Clear all logs';

  @override
  String get tooltipCollapseStackTrace => 'Collapse stack trace';

  @override
  String get tooltipExpandStackTrace => 'Expand stack trace';

  @override
  String get tooltipGoToPdsLs => 'Go to pds.ls';

  @override
  String get tooltipShareLogFile => 'Share log file';
}
