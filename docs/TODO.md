# To-Do/Parking Lot

## UI

- Show feed icons in the feed management UI

## UX

- Odd behavior when saving drafts: can save draft via the button but hitting cancel
  prompts to save or discard.
- Character count doesn't have "initial state" (completely full)
- Composer is collosal -> We should show drafts on half the screen, with the option
  to toggle it closed.
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

## Privacy Policy

- Should mention that Lazurite is an AppView that doesn't store any user data.
  A link to BlueSky's privacy policy should be included.
