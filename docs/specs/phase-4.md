# Phase 4

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

## Media Playback & Download

Currently images open in an external browser and videos launch an external app
via `url_launcher`. This milestone adds in-app media viewing and the ability to
save media to the device gallery.

### Packages

| Package              | Purpose                                                         |
| -------------------- | --------------------------------------------------------------- |
| `photo_view`         | Pinch-to-zoom and pan for full-screen images                    |
| `video_player`       | Flutter's official video playback plugin (HLS support built-in) |
| `chewie`             | Material-styled controls wrapper around `video_player`          |
| `dio`                | HTTP downloads with progress callbacks                          |
| `gal`                | Save images and videos to the device gallery                    |
| `permission_handler` | Request photo-library / storage write permissions               |

### Image Viewer

Tapping an image in a post opens a full-screen `ImageViewerScreen`. The screen
is a `PageView` so multi-image posts are swipeable. Each page contains a
`PhotoView` widget wrapping an `Image.network` of the `fullsize` URL. A hero
animation on the thumbnail provides a smooth transition.

The viewer has a transparent app bar with a close button, a download button, and
a share button. Swiping down dismisses the viewer. The current page indicator
appears at the bottom for multi-image posts.

Alt text, when present, is shown in a semi-transparent bar at the bottom of
each page.

### Video Player

Tapping a video embed opens a `VideoPlayerScreen`. The player uses `chewie`
wrapping Flutter's `VideoPlayerController.networkUrl` pointed at the HLS
`playlist` URL. Controls include play/pause, seek bar, elapsed/total time,
fullscreen toggle, and a mute button.

The video thumbnail is shown as a placeholder until the player initialises. If
the embed has an `aspectRatio`, the player container uses it; otherwise it
defaults to 16:9. The player disposes its controller on screen pop.

For GIF-style videos (`presentation: "gif"`), the player auto-plays in a loop
with controls hidden and audio muted.

### Downloading Media

A download button appears in the image viewer toolbar and the video player
toolbar. The download flow:

1. Check and request write permission via `permission_handler` (photo library
   on iOS, storage or media-store on Android).
2. Download the file using `dio` with a progress callback driving a circular
   progress indicator on the button.
3. Save the file to the device gallery via `gal`.
4. Show a snackbar confirming success or displaying the error.

For images, the download URL is the `fullsize` URL. For videos, download the
highest-quality variant from the HLS playlist. Parse the `.m3u8` manifest to
find the highest-bandwidth variant URL, then download that MP4 stream.

Long-press on an image thumbnail in a post (without entering the viewer) should
show a context menu with "Save image" and "Share" options.

### Permissions

| Platform    | Permission                              | When Requested         |
| ----------- | --------------------------------------- | ---------------------- |
| iOS         | `NSPhotoLibraryAddUsageDescription`     | First download attempt |
| Android 13+ | `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO` | First download attempt |
| Android <13 | `WRITE_EXTERNAL_STORAGE`                | First download attempt |

Declare permissions in `AndroidManifest.xml` and `Info.plist`. The app only
requests permission at the moment of download, not on launch.

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

## Labelers & Content Moderation

Labelers are independent services that produce metadata labels about content
and accounts. Users subscribe to labelers and configure how each label type
affects their experience. The `bluesky` Dart package includes a built-in
moderation decision engine that handles label interpretation.

### Architecture Overview

```text
User Preferences ──► ModerationOpts ──► moderatePost() ──► ModerationDecision
Label Definitions ─┘                    moderateProfile()    └─► getUI(context)
                                        moderateNotification()    └─► ModerationUI
                                                                       ├─ filters
                                                                       ├─ blurs
                                                                       ├─ alerts
                                                                       └─ informs
```

### API

| Endpoint                        | Purpose                             |
| ------------------------------- | ----------------------------------- |
| `app.bsky.labeler.getServices`  | Fetch labeler details by DID        |
| `app.bsky.actor.getPreferences` | Read labeler subscriptions + prefs  |
| `app.bsky.actor.putPreferences` | Write labeler subscriptions + prefs |

### Labeler Subscriptions

Users subscribe to up to 20 labelers. Subscriptions are stored as a
`labelersPref` entry in the user's preferences. Each entry contains a labeler
DID. The official Bluesky moderation labeler is always active and does not
count against the 20-labeler limit.

On every XRPC request that returns content (feed, thread, profile, search,
notifications), include the `atproto-accept-labelers` HTTP header with a
comma-separated list of subscribed labeler DIDs. The AppView fetches labels
from those labelers and attaches them to the response.

### Label Data Model

A label is a lightweight annotation attached to content or an account:

| Field | Type      | Description                                         |
| ----- | --------- | --------------------------------------------------- |
| `src` | string    | DID of the labeler that created the label           |
| `uri` | string    | AT-URI of the target resource (or DID for accounts) |
| `cid` | string?   | Optional CID for a specific version of the target   |
| `val` | string    | Label value identifier (e.g. "porn", "spam")        |
| `neg` | bool?     | If true, negates (retracts) a previous label        |
| `cts` | datetime  | Creation timestamp                                  |
| `exp` | datetime? | Expiration timestamp                                |

### Label Behaviour Definitions

Each label value is defined by three axes that determine its UI effect:

| Axis             | Values                     | Description                      |
| ---------------- | -------------------------- | -------------------------------- |
| `blurs`          | `content`, `media`, `none` | What gets blurred                |
| `severity`       | `inform`, `alert`, `none`  | Badge type (neutral vs warning)  |
| `defaultSetting` | `ignore`, `warn`, `hide`   | Default user-configurable action |

Global (protocol-defined) label values include:

| Label            | Blurs   | Default | Notes                           |
| ---------------- | ------- | ------- | ------------------------------- |
| `!hide`          | content | hide    | Non-configurable, no override   |
| `!warn`          | content | warn    | Non-configurable, click-through |
| `porn`           | media   | hide    | Adult, 18+ required             |
| `sexual`         | media   | warn    | Adult, 18+ required             |
| `graphic-media`  | media   | warn    | Adult, 18+ required             |
| `nudity`         | media   | ignore  | Not 18+ restricted              |
| `dmca-violation` | content | hide    | Non-configurable                |
| `doxxing`        | content | hide    | Non-configurable                |

Labelers may also define custom label values with localised names and
descriptions via `LabelValueDefinition`.

### Self-Labels

Authors can embed `selfLabels` directly in their posts and profiles. Only
global label values are valid as self-labels. Self-labels are treated as if
the author is the label source and follow the same behaviour rules.

### Moderation Decision Pipeline

Use the `bluesky` package's moderation engine for all content display:

1. **Build `ModerationOpts`** from user preferences:
   - `adultContentEnabled` — boolean from preferences
   - `labels` — map of label value → preference (`ignore` / `warn` / `hide`)
   - `labelers` — list of subscribed labeler DIDs
   - `labelDefs` — map of labeler DID → list of custom `InterpretedLabelValueDefinition`

2. **Run moderation** on every piece of content before display:
   - `moderatePost(subject, opts)` for posts
   - `moderateProfile(subject, opts)` for profiles
   - `moderateNotification(subject, opts)` for notifications

3. **Apply `ModerationUI`** via `decision.getUI(context)` for each display
   context:
   - `contentList` — post in a feed or search results
   - `contentView` — post in a thread view
   - `contentMedia` — images/media within a post
   - `avatar` — profile avatar
   - `profileList` — profile in a list
   - `profileView` — full profile screen

The `ModerationUI` object contains:

- `filters` — content should be removed from the list entirely
- `blurs` — content should be placed behind a click-through overlay
- `alerts` — show a warning badge (negative connotation)
- `informs` — show an informational badge (neutral)
- `noOverride` — blur cannot be dismissed by the user

### Content Label Preferences

Users configure per-label visibility via `contentLabelPref` entries in
preferences. Each entry specifies:

| Field        | Description                                 |
| ------------ | ------------------------------------------- |
| `labelerDid` | Scope to a specific labeler (null = global) |
| `label`      | The label value string                      |
| `visibility` | `ignore`, `warn`, `hide`, or `show`         |

Labels with `adultOnly: true` in their definition require the user to have
`adultContentEnabled` set to true. If adult content is disabled, these labels
always apply as `hide` regardless of user preference.

### Rendering Rules

**Blur overlay**: When `blurs` is non-empty, render a semi-transparent overlay
with the label name and a "Show" button. If `noOverride` is true, omit the
"Show" button — the content cannot be revealed.

**Alert badge**: When `alerts` is non-empty, show a warning icon with the
label name below the content or next to the profile name.

**Inform badge**: When `informs` is non-empty, show an info icon with the
label name. Use a neutral colour (not red/warning).

**Filtering**: When `filters` is non-empty, remove the content from the
current list view entirely. Do not render a placeholder.

**Media blur**: When the `contentMedia` context has blurs, blur only images
and embedded media while leaving the post text visible.

**Avatar blur**: When the `avatar` context has blurs, show a generic
placeholder avatar.

### ModerationService

Build a `ModerationService` that:

1. Loads labeler subscriptions and label preferences from user preferences on
   login and account switch.
2. Fetches labeler details (`getServices` with `detailed: true`) for all
   subscribed labelers to obtain custom label definitions.
3. Caches label definitions in a Drift `labeler_cache` table for offline use.
4. Constructs `ModerationOpts` and exposes it as a stream that updates when
   preferences change.
5. Provides convenience methods: `moderatePost()`, `moderateProfile()`,
   `moderateNotification()`.

### Labeler Cache Table

| Column          | Type     | Notes                            |
| --------------- | -------- | -------------------------------- |
| `labeler_did`   | text     | PK, DID of the labeler           |
| `policies_json` | text     | Serialised `LabelerViewDetailed` |
| `fetched_at`    | datetime | When the data was last refreshed |

Refresh the cache when the user opens the labeler management screen or when a
subscribed labeler's data is older than 24 hours.

### Labeler Management UI

The labeler management screen (accessible from Settings) shows:

- A list of subscribed labelers, each showing: creator avatar, display name,
  description, and number of label definitions.
- Tapping a labeler opens a detail screen showing all label values the labeler
  publishes, with the user's current preference (ignore/warn/hide) for each.
- A toggle for subscribing/unsubscribing to the labeler.
- An "Adult content" toggle at the top of the settings screen that gates all
  18+ label preferences.

### Header Integration

The XRPC client must be modified to include the `atproto-accept-labelers`
header on all outgoing requests. The header value is a comma-separated list of
labeler DIDs from the user's `labelersPref`. This should be set once on login
and updated whenever preferences change.
