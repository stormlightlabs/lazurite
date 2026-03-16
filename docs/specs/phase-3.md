# Phase 3

## Post Composition

Posts are created via `com.atproto.repo.createRecord` with collection
`app.bsky.feed.post`. The compose screen is a full-screen modal opened from a
floating action button on the home screen.

### Post Record Structure

| Field       | Type     | Description                                   |
| ----------- | -------- | --------------------------------------------- |
| `text`      | string   | Post body, max 300 graphemes                  |
| `facets`    | array    | Rich text annotations (mentions, links, tags) |
| `embed`     | union    | Attached media, link card, or quote post      |
| `reply`     | object   | `parent` + `root` refs for threaded replies   |
| `langs`     | array    | BCP-47 language tags                          |
| `createdAt` | datetime | ISO 8601 timestamp                            |

### Media Uploads

Upload images via `com.atproto.repo.uploadBlob`. Returns a `blob` ref used in
the embed object. No GIF support — images only.

| Constraint     | Value                              |
| -------------- | ---------------------------------- |
| Max images     | 4 per post                         |
| Max file size  | 1 MB per image                     |
| Accepted types | JPEG, PNG, WebP                    |
| Alt text       | Required UI field, optional in API |

Embed type for images: `app.bsky.embed.images`. Each image entry has `image`
(blob ref), `alt` (string), and optional `aspectRatio` (`width` / `height`).

### Facet Detection

Use **bluesky_text** to detect mentions, links, and hashtags in the post text
and produce the `facets` array automatically before submission. The compose
screen should render a live preview of detected facets with colour-coded
highlights as the user types.

### Grapheme Counter

Display a live character counter showing remaining graphemes (300 max). Use
Dart's `Characters` class for accurate grapheme cluster counting. Disable the
submit button when the count exceeds 300 or the text is empty.

### Drafts

Persist unsent posts locally in a Drift `drafts` table. On network failure or
explicit save, always store the draft. Drafts are account-scoped.

| Column        | Type     | Notes                                    |
| ------------- | -------- | ---------------------------------------- |
| `id`          | integer  | PK autoincrement                         |
| `account_did` | text     | FK to `accounts`                         |
| `text`        | text     | Post body                                |
| `reply_uri`   | text     | Nullable; parent post URI if reply       |
| `embed_json`  | text     | Nullable; serialised embed data          |
| `media_paths` | text     | Nullable; JSON array of local file paths |
| `created_at`  | datetime | When the draft was created               |
| `updated_at`  | datetime | Last modification                        |

Display a "Drafts" entry in the compose screen accessible via a toolbar icon.
Tapping a draft loads it back into the composer for editing / sending.

### Scheduled Posts

Schedule posts for future publication using a local scheduler. Store the
scheduled time alongside the draft. Use a `WorkManager` (Android) /
`BGTaskScheduler` (iOS) background task to submit the post at the scheduled
time. If the device is offline at the scheduled time, queue the post and retry
when connectivity resumes.

Add a `scheduled_at` (nullable datetime) column to the `drafts` table. When
non-null, the draft is treated as scheduled rather than a regular draft.

Build a `ComposeBloc` with events: `TextChanged`, `MediaAttached`,
`MediaRemoved`, `AltTextUpdated`, `DraftSaved`, `DraftLoaded`,
`PostScheduled`, `PostSubmitted`.

## Notifications

Render BlueSky notifications using `app.bsky.notification.listNotifications`.
No push notifications in this phase — polling only.

### API

| Endpoint                                  | Purpose                     |
| ----------------------------------------- | --------------------------- |
| `app.bsky.notification.listNotifications` | Paginated notification list |
| `app.bsky.notification.updateSeen`        | Mark notifications as read  |
| `app.bsky.notification.getUnreadCount`    | Badge count for nav bar     |

`listNotifications` returns `notification` objects with `reason`, `author`,
`record`, `isRead`, `indexedAt`. Paginate with `cursor`; `limit` 1–100.

### Notification Reasons

| Reason    | Display                                        |
| --------- | ---------------------------------------------- |
| `like`    | "[Author] liked your post" + post preview      |
| `repost`  | "[Author] reposted your post" + post preview   |
| `follow`  | "[Author] followed you"                        |
| `mention` | "[Author] mentioned you" + post preview        |
| `reply`   | "[Author] replied to your post" + post preview |
| `quote`   | "[Author] quoted your post" + post preview     |

### Rendering

Group notifications by day. Each notification row shows the author avatar, the
reason icon, a summary line, and an optional post preview snippet. Tapping a
notification navigates to the relevant post or profile.

Display an unread count badge on the Notifications nav bar item. Poll
`getUnreadCount` on a 30-second interval when the app is foregrounded. Call
`updateSeen` when the notifications screen is opened.

Build a `NotificationBloc` with events: `NotificationsRequested`,
`NotificationsRefreshed`, `NotificationsPageLoaded`, `NotificationsMarkedRead`.

## Direct Messages

DMs use the `chat.bsky.*` lexicon namespace. The DM feature has two views: a
conversation list and a message thread.

### API

| Endpoint                               | Purpose                       |
| -------------------------------------- | ----------------------------- |
| `chat.bsky.convo.listConvos`           | Paginated conversation list   |
| `chat.bsky.convo.getConvo`             | Single conversation metadata  |
| `chat.bsky.convo.getMessages`          | Paginated messages in a convo |
| `chat.bsky.convo.sendMessage`          | Send a message                |
| `chat.bsky.convo.deleteMessageForSelf` | Delete a message locally      |
| `chat.bsky.convo.muteConvo`            | Mute a conversation           |
| `chat.bsky.convo.unmuteConvo`          | Unmute a conversation         |
| `chat.bsky.convo.updateRead`           | Mark conversation as read     |
| `chat.bsky.convo.getLog`               | Polling for new events        |

### Conversation List

`listConvos` returns conversations sorted by last message time. Each convo
includes `id`, `members` (array of `profileViewBasic`), `lastMessage`,
`unreadCount`, `muted`.

Filter conversations into two tabs: **Primary** (accepted) and **Requests**
(conversations the user has not yet responded to). A conversation is a
"request" if the user has never sent a message in it.

### Message Thread

`getMessages` returns paginated `messageView` objects. Each message has `id`,
`text`, `sender` (DID), `sentAt`. Messages are displayed in a standard chat
bubble layout — the current user's messages right-aligned, others left-aligned.

Support long-press to copy individual messages. Provide a "Copy All" option in
the conversation overflow menu to copy the full thread.

### Sending Messages

`sendMessage` takes `convoId` and `message` (object with `text`). To start a
new conversation, the app calls `chat.bsky.convo.getConvoForMembers` with the
target DID(s) — this returns an existing convo or creates a new one.

| Endpoint                             | Purpose               |
| ------------------------------------ | --------------------- |
| `chat.bsky.convo.getConvoForMembers` | Get or create a convo |

Build a `ConvoListBloc` with events: `ConvosRequested`, `ConvosRefreshed`,
`ConvoMuted`, `ConvoUnmuted`.

Build a `MessageBloc` with events: `MessagesRequested`, `MessagesPageLoaded`,
`MessageSent`, `MessageDeleted`, `ConvoMarkedRead`.

## Account Switching

Support multiple authenticated accounts with full data isolation. The
`accounts` table (from Phase 1) already supports multiple rows keyed by DID.

### Active Account

Store the active account DID in the Drift `settings` table under key
`active_account_did`. On launch, read this value and restore the session for
that account.

### Data Isolation

All user-scoped tables must include an `account_did` FK column. Queries always
filter by the active account's DID. Tables requiring this constraint:

- `drafts`
- `saved_posts`
- `search_history` (Phase 2)
- `cached_posts` (add `account_did` if not present)

### Switching Flow

1. User opens account switcher (bottom sheet or settings).
2. Selects a different account.
3. App updates `active_account_did` in settings.
4. All Blocs receive a `AccountSwitched` event and reload their state for the
   new account.
5. If the selected account's tokens are expired, attempt silent refresh. If
   refresh fails, navigate to login.

### Adding Accounts

"Add Account" triggers the same OAuth flow from Phase 1. On success, a new row
is inserted into `accounts`. The new account becomes the active account.

Build an `AccountSwitcherCubit` that exposes the list of accounts and the
active DID.

## Offline Reading

The app should render cached data when the network is unavailable. This builds
on the `cached_posts` and `cached_profiles` tables from Phase 1.

### Cache Strategy

Cache the last-fetched page of each feed (timeline, pinned generators) in Drift
as serialised JSON. On launch or feed switch, display cached data immediately,
then fetch fresh data in the background. If the fetch fails, keep showing the
cache with a "You're offline" banner.

### Offline Indicators

- A persistent banner at the top of the screen when connectivity is lost.
- Disable actions that require network (compose, like, repost, follow) and show
  a tooltip explaining why.
- Notifications and DM screens show an empty state with "No connection" when
  offline and no cached data exists.

### Network Detection

Use the **connectivity_plus** package to monitor network state changes. Expose
connectivity as a stream via a `ConnectivityCubit` that all screens observe.

## Saved Posts

Allow users to bookmark posts locally for later reading. Saved posts are stored
only in Drift — nothing is written to the network. This is intentionally
private and local-only.

### Drift Table

| Column        | Type     | Notes                        |
| ------------- | -------- | ---------------------------- |
| `id`          | integer  | PK autoincrement             |
| `account_did` | text     | FK to `accounts`             |
| `post_uri`    | text     | AT-URI of the saved post     |
| `post_json`   | text     | Full serialised post payload |
| `saved_at`    | datetime | When the user saved the post |

Unique constraint on (`account_did`, `post_uri`).

### UI

Add a "Save" action (bookmark icon) to the post action bar. Tapping toggles
the saved state. Saved posts are viewable from a "Saved" section in the
profile screen or settings.

Build a `SavedPostsCubit` that reads/writes the `saved_posts` table and
exposes a stream of saved post URIs for quick lookup (to show filled vs
outlined bookmark icons in the feed).

## Jump to Profile

Add a floating action button on the search screen. Tapping it opens a dialog
with a text field for entering a handle. Use
`app.bsky.actor.searchActorsTypeahead` to provide autocomplete suggestions as
the user types. Selecting a result or pressing enter navigates to that user's
profile screen.

| Endpoint                               | Purpose             |
| -------------------------------------- | ------------------- |
| `app.bsky.actor.searchActorsTypeahead` | Handle autocomplete |
| `app.bsky.actor.getProfile`            | Full profile fetch  |
