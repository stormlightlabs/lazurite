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

## Post & Profile Actions

All post and profile interactions use the AT Protocol record model. Actions
that create a relationship (like, repost, follow, block) write a record via
`com.atproto.repo.createRecord` and undo by deleting via
`com.atproto.repo.deleteRecord`. Muting is a server-side procedure call with
no persistent record.

### API

| Endpoint                              | Purpose                                 |
| ------------------------------------- | --------------------------------------- |
| `com.atproto.repo.createRecord`       | Create like/repost/follow/block records |
| `com.atproto.repo.deleteRecord`       | Delete like/repost/follow/block records |
| `app.bsky.graph.muteActor`            | Mute an account                         |
| `app.bsky.graph.unmuteActor`          | Unmute an account                       |
| `com.atproto.moderation.createReport` | Report a post or account                |

### Like

Collection: `app.bsky.feed.like`. Record contains a `subject` (RepoStrongRef
with the post's AT-URI and CID) and `createdAt`.

To unlike, extract the record key (rkey) from the `viewer.like` AT-URI and
call `deleteRecord` with collection `app.bsky.feed.like` and that rkey.

The `PostView.viewer.like` field is non-null when the current user has liked
the post. Use this to drive the filled/outlined heart icon state.

### Repost

Collection: `app.bsky.feed.repost`. Record structure is identical to like —
`subject` (RepoStrongRef) + `createdAt`.

To un-repost, extract the rkey from `viewer.repost` and delete the record.

The `PostView.viewer.repost` field is non-null when the current user has
reposted. Use this for the repost icon state.

### Follow

Collection: `app.bsky.graph.follow`. Record contains `subject` (the target
user's DID as a string) and `createdAt`.

To unfollow, extract the rkey from `viewer.following` and delete the record.

Viewer state fields on profiles:

- `viewer.following` — non-null AT-URI if the current user follows this profile
- `viewer.followedBy` — non-null AT-URI if this profile follows the current user

### Mute

Mute and unmute are procedure calls (not record creation):

- `app.bsky.graph.muteActor` — input: `{ actor: DID }`
- `app.bsky.graph.unmuteActor` — input: `{ actor: DID }`

Both return empty responses. The `viewer.muted` boolean on profiles reflects
the current mute state. Muted accounts' posts are still fetched but should be
visually de-emphasised or filtered in the UI based on user preference.

### Block

Collection: `app.bsky.graph.block`. Record contains `subject` (the target
user's DID) and `createdAt`.

To unblock, extract the rkey from `viewer.blocking` and delete the record.

Viewer state fields on profiles:

- `viewer.blocking` — non-null AT-URI if the current user blocks this profile
- `viewer.blockedBy` — boolean, true if this profile blocks the current user

When a user is blocked, their posts should be hidden from feeds and threads.
Display a "You have blocked this user" placeholder in their profile view.

### Report

Reports use `com.atproto.moderation.createReport` with two subject types:

| Subject Type    | Usage                  | Fields        |
| --------------- | ---------------------- | ------------- |
| `RepoStrongRef` | Report a specific post | `uri` + `cid` |
| `RepoRef`       | Report an account      | `did`         |

Report reasons (from `com.atproto.moderation.defs`):

| Reason             | Description                       |
| ------------------ | --------------------------------- |
| `reasonSpam`       | Spam or unsolicited content       |
| `reasonViolation`  | Violates community guidelines     |
| `reasonMisleading` | Misleading or deceptive content   |
| `reasonSexual`     | Unwanted sexual content           |
| `reasonRude`       | Harassment or rude behaviour      |
| `reasonOther`      | Other (requires text explanation) |

The report dialog should present the reason picker and an optional free-text
description field. Submitting returns a report ID for confirmation.

### Optimistic Updates

All toggle actions (like, repost, follow, mute, block) should use optimistic
UI updates:

1. Immediately update the local state (icon, count, button label).
2. Fire the API call in the background.
3. On success, reconcile with the server response (update the viewer URI).
4. On failure, roll back the local state and show a snackbar error.

Build a `PostActionCubit` that manages per-post action state (like, repost,
save). It accepts the initial `ViewerState` from the post and exposes
toggleable methods.

Build a `ProfileActionCubit` that manages per-profile action state (follow,
mute, block). It accepts the initial `ViewerState` from the profile and
exposes toggleable methods.

### Post Action Bar

The post action bar appears below every post and contains four buttons:

| Button | Icon   | Tap action    | Long-press        |
| ------ | ------ | ------------- | ----------------- |
| Reply  | chat   | Open compose  | —                 |
| Repost | repeat | Toggle repost | Quote post option |
| Like   | heart  | Toggle like   | —                 |
| Share  | share  | Share sheet   | —                 |

The bookmark (save) icon is placed in the post overflow menu alongside
"Report" and "Copy link".

Like and repost counts are displayed next to their respective icons. Counts
update optimistically. The repost long-press opens a bottom sheet with
"Repost" and "Quote Post" options.

### Profile Action Buttons

The profile header shows a primary action button based on the relationship:

| State            | Button label | Tap action     |
| ---------------- | ------------ | -------------- |
| Not following    | "Follow"     | Create follow  |
| Following        | "Following"  | Unfollow sheet |
| Blocked by them  | —            | No button      |
| You blocked them | "Unblock"    | Delete block   |

The profile overflow menu (three-dot icon) contains: Mute / Unmute, Block /
Unblock, Report, Copy DID, Share profile.

Mute and block actions should show a confirmation dialog before proceeding.

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
