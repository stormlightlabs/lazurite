# CHANGELOG

## v0.1.0 (Unreleased)

### Added

#### 2026-03-16

- OAuth2 authentication flow (app password for debugging)
- Theming - Oxocarbon, Rose Pine, Nord, Catppuccin

#### 2026-03-17

- Profile screen (post viewing)
- Feed view and management screens (reordering & pinning)
- Post actions (like, reply, repost)
- Local and ATProto/cloud saving of posts

#### 2026-03-18

- Post composer with persisted drafts
- Post deletion
- "Dev Tools" -> view logs and explore PDS records ([pdsls](https://pds.ls)) style

#### 2026-03-19

- Notification viewing
- Search screen for posts and users
- Jump to profile action from search screen with autocomplete
- Direct messages and requests
- Media players and downloading of images and videos

#### 2026-03-20

- Post thread screen
- Threaded replies with collapse/expand
- Auto-collapse replies after a certain depth

#### 2026-03-21

- Moderation service integration
- Labels added to users in posts

#### 2026-03-22

- Starter pack & list views

#### 2026-03-29

- Offline/low-connectivity detection and handling with cached data display

#### 2026-04-01

- Profile Context (Blocking/Blocked By, Lists, etc.) section accessible from profiles
- Suggested Follows tab (for non-currently authenticated users) in the Profile screen
- Video upload limits in settings

#### 2026-04-11

- Follow hygiene feature to identify and unfollow inactive or problematic accounts

#### 2026-04-12

- Multiple account support (controlled from settings and sidebar/menu)

#### 2026-04-14

- Post editing via delete-recreate
- Added url resolution for in-app links (profiles, posts, hashtags) with dedicated hashtag
  screen (matches bsky.app implementation with Top/Latest sorting)
- Jump to hashtag action from the hashtag screen with related hashtags & search

#### 2026-04-28

- Animated transitions between screens and micro animations for actions

#### 2026-04-29

- Configurable autocomplete/typeahead for login & profile/actor search
- Starter Pack search (not implemented upstream) screen
