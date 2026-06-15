# Bluesky Group Chats Milestones

## M0 - Dependency And Protocol Surface

- [x] Confirm `bluesky_poptart` version exposes `chat.bsky.group` generated APIs
- [x] Confirm `ConvoView.kind` supports direct and group variants in generated types
- [x] Confirm generated model names for group create/add/remove/edit outputs
- [x] Confirm whether `listMutualGroups` is available in the resolved package
- [x] Add or update package constraints only if the current lockfile is not enough
- [x] Add repository fixture JSON for direct convo, group convo, system messages,
      join link, and join request

### Notes

- Current lockfile resolves `bluesky_poptart` to `0.1.1`, which exposes generated
  `chat.bsky.group` APIs.
- `ConvoView.kind` is generated as `UConvoViewKind` with `directConvo`, `groupConvo`, and
  `unknown` variants.
- Generated output model names confirmed: `GroupCreateGroupOutput`, `GroupAddMembersOutput`,
  `GroupRemoveMembersOutput`, and `GroupEditGroupOutput`.
- `listMutualGroups` is present in the live lexicon but is not generated in the currently
  resolved package.
- No package constraint change is needed for M0.
- Shared message fixtures live in `test/helpers/fixtures/messages.dart` and include direct
  convo, group convo, member page, system message, join link, and join request JSON.

## M1 - Repository Layer

- [x] Extend `ConvoRepository` with `createGroup`
- [x] Extend `ConvoRepository` with `getConvoMembers`
- [x] Extend `ConvoRepository` with `addGroupMembers`
- [x] Extend `ConvoRepository` with `removeGroupMembers`
- [x] Extend `ConvoRepository` with `editGroupName`
- [x] Add join-link methods: create, edit, enable, disable, preview
- [x] Add join-request methods: request, withdraw, list, approve, reject, mark-read when
      available
- [x] Preserve unauthorized recovery for every new chat API call
- [x] Unit tests for success and API error mapping for each repository method

### Notes

- Added `BlueskyGroupService` to the local poptart adapter and wired generated
  `chat.bsky.group` APIs through `ConvoRepository`.
- Added available join-request methods for request, list, approve, and reject. The resolved
  `bluesky_poptart 0.1.1` package does not generate withdraw or mark-read endpoints, so no
  repository methods were added for unavailable APIs.
- Every new repository method runs through the existing `UnauthorizedRecoveryRunner`.
- Repository tests cover success and API error propagation for every added method.

## M2 - Conversation List Support

- [x] Render group conversations in the existing messages list
- [x] Use group name as the primary label for group conversations
- [x] Show member count when available
- [x] Render last group system update when there is no normal message text
- [x] Preserve current direct conversation rendering
- [x] Ensure request-status grouping still works for group invites
- [x] Widget tests for direct, group, muted, unread, request, and empty states

### Notes

- Group rows now show the group name, member count, unread count, muted state, and a
  generic group-update summary for system-message last messages.
- Direct conversation row rendering remains member-based.
- Request-status filtering continues to drive the Primary and Requests tabs for both
  direct and group conversations.

## M3 - Create Group Flow

- [x] Add `/alerts/messages/new-group` route
- [x] Add create group screen from the messages tab
- [x] Add group name input with protocol-aligned validation
- [x] Add profile search/member picker
- [x] Add selected member list/chips with removal
- [x] Disable create until name and at least one member are valid
- [x] Call `ConvoRepository.createGroup`
- [x] Navigate to the created conversation thread on success
- [x] Show actionable errors for blocked users, forbidden groups, follow restrictions,
      and recipient not found
- [x] Bloc/widget tests for validation, success, and error states

### Notes

- Added `GroupCreateCubit` to own name/member validation, duplicate/self-invite prevention,
  submission state, and protocol error mapping.
- Added the create group route and a messages-tab action that opens it.
- The create screen uses the existing `TypeaheadRepository` for profile search, selected
  member chips for removal, and navigates to the created thread after inserting the
  created conversation into the inbox state.
- Tests cover cubit validation, repository success, protocol error copy, member picker
  behavior, route construction, and success navigation.

## M4 - Group Message Thread

- [x] Load or pass `ConvoView` into `MessageThreadScreen` so group metadata is available
- [x] Use group name in the app bar for group conversations
- [x] Show member count in the thread header or details entry point
- [x] Render group system messages inline
- [x] Disable message input for locked/permanently locked group conversations
- [x] Respect request status before allowing sends
- [x] Keep direct conversation behavior unchanged
- [x] Widget tests for group title, system message rendering, locked input, and normal sends

### Notes

- `MessageThreadRouteArgs` now carries an optional `ConvoView`; inbox and create-group
  navigation pass the conversation metadata into the thread.
- Group threads derive the app bar title and member-count subtitle from `GroupConvo`.
- Group system messages render as concise inline status rows, with unknown/unstable events
  falling back to a generic group update.
- The message input is disabled for request conversations and for locked or permanently
  locked group conversations.
- Direct conversations keep the existing title and send behavior when no group metadata is
  present.

## M5 - Group Details And Member List

- [x] Add `/alerts/messages/:id/details` route
- [x] Fetch full members with `getConvoMembers`
- [x] Paginate member list
- [x] Show group name, member count, member limit, muted state, and lock status
- [x] Show leave conversation action
- [x] Show rename/add/remove controls only where appropriate
- [x] Handle `InsufficientRole` responses without leaving stale UI
- [x] Refresh conversation/member state after each mutation
- [x] Tests for member pagination, leave, rename, add member, remove member, and
      insufficient role

### Notes

- Added single-conversation fetch and leave methods to `ConvoRepository`, so deep-linked
  message routes can hydrate the full `ConvoView` instead of rendering a title-only thread.
- Added the group details route from the message thread app bar with paginated member
  loading, owner-only rename/add/remove controls, leave handling, and mutation refresh.
- Tests cover deep-linked group metadata hydration, repository get/leave calls, member
  pagination, leave, rename, add, remove, and insufficient-role errors.

## M6 - Join Links And Join Requests

- [ ] Add join-link display and copy/share affordance for owners
- [ ] Add create join link flow with join rule and approval requirement
- [ ] Add edit join link flow
- [ ] Add enable/disable join link actions
- [ ] Add join-link preview route for link opens
- [ ] Add viewer request-join and withdraw-request actions
- [ ] Add owner pending requests list
- [ ] Add approve/reject request actions
- [ ] Mark join requests as read when supported by generated API
- [ ] Tests for preview, request, withdraw, approve, reject, and disabled/invalid links

## M7 - Polish, Localization, And Verification

- [ ] Add all user-facing strings to l10n files
- [ ] Add accessibility labels for create group, member actions, join links, and system
      messages
- [ ] Ensure long group names and handles wrap cleanly on narrow screens
- [ ] Ensure parent row taps do not conflict with member/action buttons
- [ ] Review copy for privacy and trust boundaries around join links and group invites
- [ ] Run `flutter analyze`
- [ ] Run `gtimeout 1200s flutter test --reporter=failures-only`
