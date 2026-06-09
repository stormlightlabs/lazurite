---
title: Bluesky Group Chats Spec
updated: 2026-06-15
---

## Summary

Add Bluesky group chat support by extending Lazurite's existing messages
feature. Group chats should appear in the current conversations inbox, open in
the existing message thread screen, and add management surfaces only where the
group protocol requires them.

The implementation should use the generated `bluesky_poptart` chat group API
when available. The local pub cache shows `bluesky_poptart 0.1.1` includes
generated `chat.bsky.group` clients and models, so the preferred path is to
wire those generated types rather than add raw JSON calls.

## Protocol/API Data Available

### Conversations

Existing direct message APIs remain under `chat.bsky.convo`.

`chat.bsky.convo.defs#convoView` now supports a `kind` union with direct and
group variants. Group conversation data includes:

```dart
GroupConvo(
  createdAt: DateTime,
  lockStatus: ConvoLockStatus,
  lockStatusModerationOverride: bool,
  memberCount: int,
  memberLimit: int,
  name: String,
  joinLink: JoinLinkView?,
  joinRequestCount: int?,
  unreadJoinRequestCount: int?,
)
```

`ConvoView.members` is not the complete group membership list. For direct
conversations it is the immutable two-person list. For group conversations it is
a partial list of important members, such as the viewer, the member who added
the viewer, and recent senders. Full membership must be fetched through
`chat.bsky.convo.getConvoMembers`.

### Creating groups

`chat.bsky.group.createGroup` creates a new group conversation. It is not
idempotent, so creating a group with the same members and name will create a
new group.

Input:

```json
{ "members": ["did:..."], "name": "Group name" }
```

Limits and behavior:

- `members` max length is 49.
- `name` max is 50 graphemes at creation.
- invited members are created with `request` membership status.
- the owner is created as `accepted`.

Relevant errors include `BlockedActor`, `BlockedSubject`,
`NewAccountCannotCreateGroup`, `NotFollowedBySender`, `RecipientNotFound`, and
`UserForbidsGroups`.

### Managing groups

The group namespace provides:

- `chat.bsky.group.addMembers`
- `chat.bsky.group.removeMembers`
- `chat.bsky.group.editGroup`
- `chat.bsky.group.createJoinLink`
- `chat.bsky.group.editJoinLink`
- `chat.bsky.group.enableJoinLink`
- `chat.bsky.group.disableJoinLink`
- `chat.bsky.group.requestJoin`
- `chat.bsky.group.withdrawJoinRequest`
- `chat.bsky.group.listJoinRequests`
- `chat.bsky.group.approveJoinRequest`
- `chat.bsky.group.rejectJoinRequest`
- `chat.bsky.group.getJoinLinkPreviews`
- `chat.bsky.group.listMutualGroups`, if present in the generated package

Most group-management lexicons are marked under active development. Lazurite
should keep unknown union values and unknown JSON fields survivable.

### Join links

Join links have:

```dart
JoinLinkView(
  code: String,
  enabledStatus: LinkEnabledStatus, // enabled, disabled
  requireApproval: bool,
  joinRule: JoinRule,               // anyone, followedByOwner
  createdAt: DateTime,
)
```

Join-link previews can be rendered for authenticated and unauthenticated
viewers. Authenticated viewers may also receive a `convo` when they are already
a member.

### System messages

Group operations appear as system messages in `chat.bsky.convo.defs`. The UI
should render at least these events:

- member added
- member removed
- member joined through a join link
- member left
- group locked/unlocked/permanently locked
- group name edited
- join link created/edited/enabled/disabled

System-message defs are also marked unstable, so unsupported system events
should render as a generic group update instead of disappearing.

## Product Behavior

### Conversation list

Group conversations should appear in the current messages tab alongside direct
conversations. The list item should show:

- group name
- member count when available
- last message or group system update
- unread count
- muted state
- request status when the viewer has not accepted

Direct conversations should keep their existing behavior.

### Creating a group

The create flow should be reachable from the messages tab. It should include:

- group name field
- member search/picker using existing actor search/profile components where
  practical
- selected member chips/list
- create button disabled until name and at least one member are present
- clear error handling for blocked users, users who forbid groups, and
  follow-based restrictions

After successful creation, navigate to the new conversation thread.

### Message thread

The existing `MessageThreadScreen` should support both direct and group
conversations. Add group-specific behavior only when `ConvoView.kind` is group:

- app bar title uses the group name
- member count can appear in subtitle or details
- system messages render inline
- input is disabled when the conversation is locked or permanently locked
- accepted/request status is respected
- message sending keeps the existing `chat.bsky.convo.sendMessage` path

### Group details

Add a group details surface from the message thread app bar. It should show:

- group name
- full member list from `getConvoMembers`
- owner/admin role indicators when exposed by generated profile kind data
- muted state
- lock status
- join link state, if present
- leave conversation action

Owner/moderator actions should be shown only when the server exposes enough
state to justify them. Do not infer permissions from UI state alone; call the
API and handle `InsufficientRole`.

### Member management

For users with sufficient role:

- add members through `chat.bsky.group.addMembers`
- remove members through `chat.bsky.group.removeMembers`
- rename group through `chat.bsky.group.editGroup`

Every mutation should refresh the conversation view and member list.

### Join links and requests

Owner-facing controls:

- create join link
- edit approval requirement
- edit join rule
- enable/disable link
- list pending join requests
- approve/reject requests
- mark join requests read when the API supports it

Viewer-facing controls:

- preview join link
- request to join when approval is required
- withdraw pending request
- join immediately when approval is not required and the server accepts it

## Data And Architecture

### Repository

Extend `ConvoRepository` rather than introduce a parallel group repository.
The messages feature already owns chat auth recovery, conversation listing,
message loading, sending, deletion, mute/unmute, and read state.

Recommended additions:

```dart
Future<ConvoView> createGroup({
  required String name,
  required List<String> memberDids,
});

Future<ConvoMembersResult> getConvoMembers(
  String convoId, {
  String? cursor,
  int limit = 50,
});

Future<ConvoView> addGroupMembers(String convoId, List<String> memberDids);
Future<ConvoView> removeGroupMembers(String convoId, List<String> memberDids);
Future<ConvoView> editGroupName(String convoId, String name);
```

Add join-link and join-request methods behind the same repository once the
generated package surface is confirmed.

### State

Existing `ConvoListBloc` can continue loading all conversations. Add events for
group creation and conversation replacement after group mutations.

For thread details, either extend `MessageBloc` with a loaded `ConvoView` or add
a small `GroupDetailsCubit` scoped to the group details route/sheet. Keep the
member list paginated and independent from message pagination.

### Routing

Existing message route:

- `/alerts/messages/:id`

Recommended additions:

- `/alerts/messages/new-group`
- `/alerts/messages/:id/details`
- `/alerts/messages/join/:code`

If join links use public URLs, add equivalent public route parsing so Lazurite
can open the link into the preview/join flow.

## Testing

Add repository tests with scripted transports for:

- create group success
- create group blocked/forbidden/follow restriction errors
- member pagination
- add/remove members
- edit group name
- join-link create/edit/disable/enable
- join-request approve/reject

Add bloc/widget tests for:

- group conversations in the list
- create-group form validation
- navigation to created group
- group thread title and locked input
- system message rendering
- full member list loading and pagination
- owner actions hidden or failed gracefully when role is insufficient

## Open Questions

- Does `bluesky_poptart 0.1.1` expose `listMutualGroups`, or is that lexicon
  newer than the package currently resolved?
- Should group chat creation be limited to mutuals/followed users in the UI, or
  should the UI allow any selected profile and rely on server errors?
- What public URL shape does Bluesky use for group join links, and does Lazurite
  need to parse it before the official web route stabilizes?
- Should group join requests live under the messages tab or a group details
  subview?
