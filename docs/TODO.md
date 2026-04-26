---
title: To-Do/Parking Lot
updated: 2026-04-14
---

## Tests

- Integration test: save a post → verify it appears in semantic search results for a
  relevant query

## UI

- Show feed icons in the feed management UI
- (bug) In the side menu, navigation items scroll behind the logged in account label
- We should create a section for "Advanced Features" in the side menu, and include a
  link to dev tools and follow audits.
- Constellation URL should remain configurable internally but the option to change the
  URL should be removed from the UI.
- Saved posts should be a tabbed view for local & ATProto/BSky saved posts.

## UX

### Posts

- Holding the quote/repost button should show the quote/repost menu (it does so on the thread
  screen but not others)

### Composer

- Odd behavior when saving drafts: can save draft via the button but hitting cancel
  prompts to save or discard.

### Dev Tools

- Instead of tabs, navigating to a record through dev tools should instead show
  - A drawer on Tablet
  - Cards (stacked) on Mobile, with swipe to go back

## Enhancements

- Allow user to change fonts across the application (headings, body text, code -> for dev
  tools)
  - Serifs: Lora (default), Crimson Pro, Playfair Display, Merriweather, Avenir Serif Libre
  - Sans: DM Sans (default), Google Sans, Public Sans, Open Sans
  - Monospace: JetBrains Mono (default), Google Sans Code, Fira Code, Source Code Pro
- Adding `/rss` for public BlueSky profiles shows their profile as an RSS feed.
  It would be cool to display this and allow exporting the feed or a link to it.
- In dev tools, show Firehose, Jetstream, and [spacedust](https://spacedust.microcosm.blue/#GET/subscribe) as tabs.

---

- Markdown support (toggleable)
- ✅ Collapsible threads

---

- Render feed from cache if it goes down (> 500 error)

---

- Sidebar profile link should open account switcher, not go to profile. Long press to go to profile.

## Privacy Policy

- Should mention that Lazurite is an AppView that doesn't store any user data.
  A link to BlueSky's privacy policy should be included.

## Feature Completeness

In this section, we outline what's necessary for Lazurite to be a complete Bluesky client, i.e.
feature parity with the official app.

1. Settings map 1:1 with account level settings in the official app
2. Mutuals/Known Followers
3. Lists
4. Starter Packs
5. Download images & videos
