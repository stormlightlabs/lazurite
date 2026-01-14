import 'package:drift/drift.dart';

class Posts extends Table {
  TextColumn get uri => text()();
  TextColumn get cid => text()();
  TextColumn get authorDid => text().references(Profiles, #did)();
  TextColumn get record => text()();
  TextColumn get embed => text().nullable()();
  DateTimeColumn get indexedAt => dateTime().nullable()();
  IntColumn get replyCount => integer().withDefault(const Constant(0))();
  IntColumn get repostCount => integer().withDefault(const Constant(0))();
  IntColumn get likeCount => integer().withDefault(const Constant(0))();
  IntColumn get quoteCount => integer().withDefault(const Constant(0))();
  IntColumn get bookmarkCount => integer().withDefault(const Constant(0))();
  TextColumn get labels => text().nullable()(); // JSON array
  TextColumn get viewerLikeUri => text().nullable()();
  TextColumn get viewerRepostUri => text().nullable()();
  BoolColumn get viewerBookmarked => boolean().withDefault(const Constant(false))();
  BoolColumn get viewerThreadMuted => boolean().withDefault(const Constant(false))();
  BoolColumn get viewerReplyDisabled => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {uri};

  @override
  List<String> get customConstraints => [];
}

/// Normalized viewer interactions with posts.
///
/// Tracks likes, reposts, bookmarks, and thread mutes separately from post
/// content. This enables efficient querying of user engagement and prevents
/// duplication when the same post appears in multiple feeds.
class PostInteractions extends Table {
  /// Reference to the post this interaction applies to.
  TextColumn get postUri => text().references(Posts, #uri)();

  /// The DID of the user who owns this interaction.
  TextColumn get ownerDid => text()();

  /// AT URI of the like record (if liked).
  TextColumn get likeUri => text().nullable()();

  /// AT URI of the repost record (if reposted).
  TextColumn get repostUri => text().nullable()();

  /// AT URI of the bookmark record (if bookmarked).
  TextColumn get bookmarkUri => text().nullable()();

  /// Whether the post is bookmarked.
  BoolColumn get bookmarked => boolean().withDefault(const Constant(false))();

  /// Whether the thread is muted.
  BoolColumn get threadMuted => boolean().withDefault(const Constant(false))();

  /// When this interaction was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {postUri, ownerDid};
}

class Profiles extends Table {
  TextColumn get did => text()();
  TextColumn get handle => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get avatar => text().nullable()();
  TextColumn get banner => text().nullable()();
  DateTimeColumn get indexedAt => dateTime().nullable()();
  TextColumn get pronouns => text().nullable()();
  TextColumn get website => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  TextColumn get verificationStatus => text().nullable()();
  TextColumn get labels => text().nullable()(); // JSON array
  TextColumn get pinnedPostUri => text().nullable()();

  @override
  Set<Column> get primaryKey => {did};
}

@TableIndex(name: 'feed_content_sort_idx', columns: {#feedKey, #sortKey})
class FeedContentItems extends Table {
  TextColumn get feedKey => text()();
  TextColumn get postUri => text().references(Posts, #uri)();
  TextColumn get ownerDid => text()();
  TextColumn get reason => text().nullable()();
  TextColumn get sortKey => text()();

  @override
  Set<Column> get primaryKey => {feedKey, postUri, ownerDid};
}

class Accounts extends Table {
  TextColumn get did => text()();
  TextColumn get handle => text()();
  TextColumn get pdsUrl => text()();

  @override
  Set<Column> get primaryKey => {did};
}

class FeedCursors extends Table {
  TextColumn get feedKey => text()();
  TextColumn get ownerDid => text()();
  TextColumn get cursor => text()();
  DateTimeColumn get lastUpdated => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {feedKey, ownerDid};
}

@TableIndex(name: 'recent_searches_unique_idx', columns: {#ownerDid, #query}, unique: true)
class RecentSearches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ownerDid => text()();
  TextColumn get query => text()();
  DateTimeColumn get searchedAt => dateTime()();
}

/// Stores cached search result items per user.
///
/// Links search queries to Posts for offline access and performance.
/// Search results are scoped by ownerDid because different users may see
/// different results for the same query due to blocks, mutes, and other
/// per-user relationship states.
@TableIndex(name: 'search_cache_sort_idx', columns: {#queryKey, #ownerDid, #sortKey})
class SearchCacheItems extends Table {
  /// Normalized search query as cache key.
  TextColumn get queryKey => text()();

  /// The DID of the user who owns this cached search result.
  TextColumn get ownerDid => text()();

  /// Reference to cached post.
  TextColumn get postUri => text().references(Posts, #uri)();

  /// Ordering within results (index-based).
  TextColumn get sortKey => text()();

  @override
  Set<Column> get primaryKey => {queryKey, ownerDid, postUri};
}

/// Stores pagination cursors for cached search queries per user.
///
/// Cursors are scoped by ownerDid to match the per-user search cache isolation.
class SearchCacheCursors extends Table {
  /// Normalized search query as cache key.
  TextColumn get queryKey => text()();

  /// The DID of the user who owns this cached cursor.
  TextColumn get ownerDid => text()();

  /// Pagination cursor from API.
  TextColumn get cursor => text()();

  /// When the cache was last updated (for 7-day retention).
  DateTimeColumn get lastUpdated => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {queryKey, ownerDid};
}

/// Stores follow relationships for caching viewer state.
class Follows extends Table {
  /// The DID of the user doing the following.
  TextColumn get actorDid => text()();

  /// The DID of the user being followed.
  TextColumn get subjectDid => text()();

  /// The AT URI of the follow record (at://did:plc:xxx/app.bsky.graph.follow/yyy).
  TextColumn get uri => text()();

  /// When the follow was created.
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {actorDid, subjectDid};
}

/// Stores normalized viewer relationships for profiles.
class ProfileRelationships extends Table {
  /// The DID of the owner (the user who sees these relationships).
  TextColumn get ownerDid => text()();

  /// The DID of the profile this relationship applies to (subject).
  TextColumn get profileDid => text().references(Profiles, #did)();

  /// Whether the viewer is following this profile.
  BoolColumn get following => boolean().withDefault(const Constant(false))();

  /// The URI of the follow record (if following).
  TextColumn get followingUri => text().nullable()();

  /// Whether this profile follows the viewer.
  BoolColumn get followedBy => boolean().withDefault(const Constant(false))();

  /// Whether the viewer has muted this profile.
  BoolColumn get muted => boolean().withDefault(const Constant(false))();

  /// Whether the viewer has blocked this profile.
  BoolColumn get blocked => boolean().withDefault(const Constant(false))();

  /// Whether this profile has blocked the viewer.
  BoolColumn get blockedBy => boolean().withDefault(const Constant(false))();

  /// The URI of the block record (if blocking).
  TextColumn get blockingUri => text().nullable()();

  /// Reference to the list that muted this profile (if applicable).
  TextColumn get mutedByList => text().nullable()();

  /// Reference to the list that blocked this profile (if applicable).
  TextColumn get blockingByList => text().nullable()();

  /// When this relationship was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {ownerDid, profileDid};
}

/// Stores saved feed generators with metadata.
///
/// This table caches user preferences from app.bsky.actor.getPreferences
/// (savedFeedsPref) and enriches them with metadata from app.bsky.feed.getFeedGenerator.
class SavedFeeds extends Table {
  /// Feed generator AT URI (at://did:plc:xxx/app.bsky.feed.generator/yyy).
  TextColumn get uri => text()();

  /// The DID of the user who saved this feed.
  TextColumn get ownerDid => text()();

  /// Display name of the feed.
  TextColumn get displayName => text()();

  /// Feed description.
  TextColumn get description => text().nullable()();

  /// Feed avatar URL.
  TextColumn get avatar => text().nullable()();

  /// DID of the feed creator.
  TextColumn get creatorDid => text().references(Profiles, #did)();

  /// Number of likes the feed has received.
  IntColumn get likeCount => integer().withDefault(const Constant(0))();

  /// Sort order for display (lower values appear first).
  IntColumn get sortOrder => integer()();

  /// Whether the feed is pinned by the user.
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  /// When the feed metadata was last synced from remote.
  DateTimeColumn get lastSynced => dateTime()();

  /// When this feed was last modified locally (save, pin, reorder).
  /// Null means no local modifications since the last remote sync.
  DateTimeColumn get localUpdatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {uri, ownerDid};
}

/// Stores queued preference updates for offline synchronization.
///
/// Handles both feed preferences (save/remove/reorder) and Bluesky account
/// preferences (content labels, muted words, etc.).
class PreferenceSyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The DID of the user who owns this action.
  TextColumn get ownerDid => text()();

  /// Category of preference being synced: 'feed' or 'bluesky_pref'.
  TextColumn get category => text().withDefault(const Constant('feed'))();

  /// Type of operation.
  ///
  /// For feeds: 'save', 'remove', or 'reorder'.
  /// For bluesky preferences: 'update'.
  TextColumn get type => text()();

  /// Payload data for the sync operation.
  ///
  /// For feeds: the feed URI (or comma-separated URIs for reorder).
  /// For bluesky preferences: JSON string of the preference data.
  TextColumn get payload => text()();

  /// When the item was queued.
  DateTimeColumn get createdAt => dateTime()();

  /// Number of times we've tried to process this item.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

/// Stores queued notification mark-as-seen operations for offline synchronization.
///
/// When marking notifications as seen fails (e.g., due to network errors),
/// operations are queued here for retry when the connection is restored.
class NotificationsSyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The DID of the user who owns this action.
  TextColumn get ownerDid => text()();

  /// Type of operation: 'mark_seen'.
  TextColumn get type => text()();

  /// The timestamp to mark as seen (ISO8601 string).
  TextColumn get seenAt => text()();

  /// When the item was queued.
  DateTimeColumn get createdAt => dateTime()();

  /// Number of times we've tried to process this item.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

class Drafts extends Table {
  TextColumn get id => text()();
  TextColumn get ownerDid => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get replyParentUri => text().nullable()();
  TextColumn get replyParentCid => text().nullable()();
  TextColumn get replyRootUri => text().nullable()();
  TextColumn get replyRootCid => text().nullable()();
  TextColumn get quoteUri => text().nullable()();
  TextColumn get quoteCid => text().nullable()();
  TextColumn get facetsJson => text().nullable()();
  TextColumn get externalUri => text().nullable()();
  TextColumn get externalTitle => text().nullable()();
  TextColumn get externalDescription => text().nullable()();
  TextColumn get externalThumbBlobJson => text().nullable()();
  TextColumn get cachedMediaJson => text().nullable()();
  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id, ownerDid};
}

class DraftMedia extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get draftId => text()();
  TextColumn get ownerDid => text()();
  TextColumn get localPath => text()();
  TextColumn get mimeType => text()();
  TextColumn get altText => text().nullable()();
  TextColumn get uploadCid => text().nullable()();
  TextColumn get blobRefJson => text().nullable()();
  TextColumn get status => text()();
  IntColumn get sortOrder => integer()();
  IntColumn get durationSeconds => integer().nullable()();
  TextColumn get aspectRatio => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (draft_id, owner_did) REFERENCES drafts (id, owner_did)',
  ];
}

/// Stores device-level app settings as key-value pairs.
///
/// Used for theme mode, theme pack ID, font scale, and similar UI preferences.
/// These settings are intentionally global (not scoped by ownerDid) because they
/// represent device-level preferences that apply across all user accounts.
///
/// For example, if a user prefers dark mode or a specific font size, these
/// settings persist when switching between accounts on the same device.
///
/// Key-value design allows adding new settings without schema migrations.
class LocalSettings extends Table {
  /// Setting key (e.g., 'themeMode', 'themePackId').
  TextColumn get key => text()();

  /// Setting value (serialized as string).
  TextColumn get value => text()();

  /// When this setting was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Stores Bluesky account preferences synced from the remote server.
///
/// Each preference type is stored as a JSON blob, keyed by its AT Protocol
/// $type identifier. This enables caching content moderation, labeler, feed
/// view, thread view, and muted word preferences locally.
class BlueskyPreferences extends Table {
  /// The preference type identifier (e.g., 'contentLabel', 'adultContent').
  TextColumn get type => text()();

  /// The DID of the owner of these preferences.
  TextColumn get ownerDid => text()();

  /// The preference data serialized as JSON.
  TextColumn get data => text()();

  /// When this preference was last synced from the remote server.
  DateTimeColumn get lastSynced => dateTime()();

  @override
  Set<Column> get primaryKey => {type, ownerDid};
}

/// Stores device-level custom theme definitions.
///
/// Custom themes are based on a built-in theme pack with color role overrides.
/// These themes are intentionally global (not scoped by ownerDid) as they
/// represent device-level visual customizations that apply to all user accounts.
///
/// Users can create and share custom themes across their accounts on the device,
/// providing a consistent visual experience regardless of which account is active.
///
/// The overrides and other data are stored as JSON for flexibility.
class CustomThemes extends Table {
  /// Unique identifier for this custom theme.
  TextColumn get id => text()();

  /// User-provided display name.
  TextColumn get name => text()();

  /// ID of the base theme pack this customization extends.
  TextColumn get basePackId => text()();

  /// Color role overrides serialized as JSON.
  TextColumn get overridesJson => text()();

  /// Typography scale preference (small/normal/large).
  TextColumn get typographyScale => text().withDefault(const Constant('normal'))();

  /// When this theme was first created.
  DateTimeColumn get createdAt => dateTime()();

  /// When this theme was last modified.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stores device-level animation preferences for accessibility and motion control.
///
/// These preferences are intentionally global (not scoped by ownerDid) because
/// they reflect device-level accessibility needs that should apply consistently
/// across all user accounts.
/// For instance, if a user has motion sensitivity or
/// prefers reduced animations, this preference should persist when switching
/// between accounts on the same device.
///
/// Uses key-value storage for flexibility, similar to LocalSettings.
/// Keys: 'mode' (AnimationMode enum as string), 'speedMultiplier' (double as string).
class AnimationPreferencesTable extends Table {
  /// Setting key (e.g., 'mode', 'speedMultiplier').
  TextColumn get key => text()();

  /// Setting value (serialized as string).
  TextColumn get value => text()();

  /// When this setting was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Caches notifications from app.bsky.notification.listNotifications.
///
/// Stores notification metadata for offline display and efficient querying.
/// Links to Profiles via actorDid for author information.
@TableIndex(name: 'notifications_indexed_at_idx', columns: {#indexedAt})
class Notifications extends Table {
  /// Notification AT URI (primary key).
  TextColumn get uri => text()();

  /// The DID of the user receiving the notification.
  TextColumn get ownerDid => text()();

  /// DID of the user who triggered the notification.
  TextColumn get actorDid => text().references(Profiles, #did)();

  /// Notification type (like, repost, follow, mention, reply, quote, starterpack-joined).
  TextColumn get type => text()();

  /// URI of the subject (post/profile) this notification is about.
  TextColumn get reasonSubjectUri => text().nullable()();

  /// Associated record JSON (for displaying notification context).
  TextColumn get recordJson => text().nullable()();

  /// When the notification was indexed on the server.
  DateTimeColumn get indexedAt => dateTime()();

  /// Whether the notification has been read.
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  /// When the notification was marked as seen (null if not seen yet).
  DateTimeColumn get seenAt => dateTime().nullable()();

  /// When this notification was cached locally.
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uri, ownerDid};
}

/// Stores pagination cursor for notifications feed.
class NotificationCursors extends Table {
  /// Feed key identifier (e.g., 'notifications').
  TextColumn get feedKey => text()();

  /// The DID of the user this cursor belongs to.
  TextColumn get ownerDid => text()();

  /// Pagination cursor from API.
  TextColumn get cursor => text()();

  /// When the cursor was last updated.
  DateTimeColumn get lastUpdated => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {feedKey, ownerDid};
}

/// Stores direct message conversations from chat.bsky.convo.listConvos.
///
/// Caches conversation metadata for offline display and efficient querying.
/// Member profiles are stored separately in Profiles table.
class DmConvos extends Table {
  /// Conversation ID (unique identifier from API).
  TextColumn get convoId => text()();

  /// The DID of the user who owns this conversation view.
  TextColumn get ownerDid => text()();

  /// JSON array of participant DIDs.
  TextColumn get membersJson => text()();

  /// Preview text from the last message.
  TextColumn get lastMessageText => text().nullable()();

  /// Timestamp of the last message.
  DateTimeColumn get lastMessageAt => dateTime().nullable()();

  /// ID of the last message the user has read.
  TextColumn get lastReadMessageId => text().nullable()();

  /// Number of unread messages.
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();

  /// Whether the conversation is muted.
  BoolColumn get isMuted => boolean().withDefault(const Constant(false))();

  /// Whether the conversation request has been accepted.
  BoolColumn get isAccepted => boolean().withDefault(const Constant(true))();

  /// When this conversation was cached locally.
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {convoId, ownerDid};
}

/// Stores direct messages from chat.bsky.convo.getMessages.
///
/// Caches message content for offline display. Sender profiles are
/// stored separately in Profiles table and joined via senderDid.
@TableIndex(name: 'dm_messages_convo_idx', columns: {#convoId, #sentAt})
class DmMessages extends Table {
  /// Message ID (unique identifier from API).
  TextColumn get messageId => text()();

  /// The DID of the user who owns this message view.
  TextColumn get ownerDid => text()();

  /// Conversation this message belongs to.
  TextColumn get convoId => text()();

  /// DID of the message sender.
  TextColumn get senderDid => text().references(Profiles, #did)();

  /// Message text content.
  TextColumn get content => text()();

  /// When the message was sent.
  DateTimeColumn get sentAt => dateTime()();

  /// Message status: sent, read, deleted.
  TextColumn get status => text()();

  /// When this message was cached locally.
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {messageId, ownerDid};
}

/// Stores pending message sends for reliable offline delivery.
///
/// Messages are queued here before sending, allowing retry on failure
/// and ensuring messages are never lost. Uses exponential backoff for retries.
class DmOutbox extends Table {
  /// Local UUID for this outbox item.
  TextColumn get outboxId => text()();

  /// The DID of the user who sent this message.
  TextColumn get ownerDid => text()();

  /// Conversation to send the message to.
  TextColumn get convoId => text()();

  /// Message text content.
  TextColumn get messageText => text()();

  /// Status: pending, sending, failed.
  TextColumn get status => text()();

  /// Number of send attempts.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// When the message was queued.
  DateTimeColumn get createdAt => dateTime()();

  /// When the last send attempt was made.
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  /// Error message from the last failed attempt.
  TextColumn get errorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {outboxId};
}

/// Stores developer settings/flags (e.g., debug mode enabled).
class DevSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get value => text()();

  /// Type of value: 'boolean', 'string', 'int'
  TextColumn get type => text()();
}

/// Stores network logs for the debug inspector.
class DevNetworkLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get method => text()();
  TextColumn get url => text()();
  IntColumn get statusCode => integer()();
  TextColumn get requestHeaders => text()(); // JSON
  TextColumn get responseHeaders => text()(); // JSON
  TextColumn get requestBody => text().nullable()();
  TextColumn get responseBody => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get durationMs => integer()();
  TextColumn get error => text().nullable()();
}

/// Stores pinned collections and records for easy access in DevTools.
class DevPins extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The AT URI of the collection or record being pinned.
  TextColumn get uri => text().unique()();

  /// Optional custom label for the pin.
  TextColumn get label => text().nullable()();

  /// Type of item: 'collection' or 'record'.
  TextColumn get type => text()();

  /// When this pin was created.
  DateTimeColumn get createdAt => dateTime()();
}

/// LRU cache of recently viewed records in the Repository inspector.
class DevRecentRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The AT URI of the record.
  TextColumn get uri => text().unique()();

  /// The CID of the record at the time it was viewed.
  TextColumn get cid => text().nullable()();

  /// When this record was last viewed.
  DateTimeColumn get viewedAt => dateTime()();
}
