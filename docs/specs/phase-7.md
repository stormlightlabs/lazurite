---
title: Phase 7 Spec
updated: 2026-04-04
---

## Monetization — Inline Ads & Tips

Revenue layer for iOS and Android: native ads that blend into content feeds, and repeatable tip purchases. First purchase of any tip removes ads permanently.

### Inline Native Ads

Ads are rendered as `NativeAd` (Google AdMob) styled to match `PostCard` dimensions so they feel like organic content rather than interruptions.

**Placement rules:**

- **Feed:** Insert one ad every 8 posts (configurable via `adInterval` constant). Position is deterministic per feed page — same scroll position always shows the ad slot, no layout jank.
- **Profile posts tab:** Same cadence, offset by 4 so the first ad appears later (the user came to see _this person's_ posts, not ads).
- **Grid layout:** Ad occupies a single grid cell, matching the card aspect ratio.
- **Linear layout:** Ad renders at full width between post cards with a subtle "Sponsored" label and muted divider.
- **No ads in:** Replies tab, Media tab, Lists, Starter Packs, DMs, Notifications, Compose, Settings, Social Graph.

**Ad lifecycle:**

1. `MobileAds.instance.initialize()` called once during app bootstrap (after auth, before first frame).
2. `AdCubit` pre-fetches deterministic ad slots for the currently loaded feed/profile page and requests slots on demand as they enter the tree.
3. Each `NativeAd` is created with `NativeTemplateStyle(templateType: TemplateType.medium)` styled to match the app's surface colors and typography.
4. `AdWidget` is inserted into the feed's item builder at calculated indices. The builder adjusts `itemCount` and maps visual indices back to data indices.
5. `NativeAd.dispose()` is called when the ad scrolls far off-screen (hybrid lifecycle: create on approach, dispose on distance).
6. If an ad fails to load (`onAdFailedToLoad`), the slot collapses — no blank space, no retry for that position.

**Ad-free flag:**

A persisted `ads_removed` value in the Drift-backed key/value `Settings` table. When `true`, the ad item builder is skipped entirely — no `MobileAds.initialize()`, no network requests, no ad widgets.

**Platform configuration:**

| Platform | Requirement                                                                                              |
| -------- | -------------------------------------------------------------------------------------------------------- |
| iOS      | `GADApplicationIdentifier` in `Info.plist`, `NSUserTrackingUsageDescription` for ATT, `SKAdNetworkItems` |
| Android  | `com.google.android.gms.ads.APPLICATION_ID` meta-data in `AndroidManifest.xml`                           |

Package: `google_mobile_ads: ^7.0.0`

### In-App Purchases (Tips)

Two consumable tip products let users support the app repeatedly. The first completed purchase of _either_ tip also flips `adsRemoved = true`, removing ads forever.

**Products:**

| ID           | Display Name | Price | Type       |
| ------------ | ------------ | ----- | ---------- |
| `tip_coffee` | Coffee       | $1.99 | Consumable |
| `tip_latte`  | Latte        | $4.99 | Consumable |

Both are consumable so they can be purchased multiple times.

**Ad removal on first purchase:**

Rather than a separate non-consumable "Remove Ads" SKU, we track whether the user has _ever_ completed a tip. This keeps the store listing simple (two products, not three) and gives the tip a tangible reward beyond goodwill.

Persistence: `adsRemoved` flag in Drift `Settings` table, set to `true` on first successful purchase completion. Since the flag is local-only, a "Restore Purchases" flow is not needed — consumables are not restorable via store APIs, and the flag is durable across app updates. On a fresh install the user sees ads again (acceptable trade-off vs. running a verification server).

**Purchase flow:**

1. `InAppPurchase.instance.isAvailable()` — gate the UI if the store is unreachable.
2. `queryProductDetails({'tip_coffee', 'tip_latte'})` — fetch localized prices.
3. User taps a tip button → `buyConsumable(purchaseParam: ...)`.
4. Listen on `purchaseStream`:
   - `PurchaseStatus.purchased` → set `adsRemoved = true` in DB, call `completePurchase()`.
   - `PurchaseStatus.error` → show snackbar with `error.message`.
   - `PurchaseStatus.pending` → show loading indicator on the button.
5. `completePurchase()` must be called for every terminal purchase to avoid auto-refund (3-day window).

Package: `in_app_purchase: ^3.2.3`

### Tip UI

**Entry point:** "Support Lazurite" row in Settings screen, below theme/layout preferences.

**Tip sheet** (modal bottom sheet):

- Header: app icon + "Support Lazurite"
- Body: two `ListTile`-style rows, each with icon (☕ / ☕☕), product name, localized price from `ProductDetails`, and a "Tip" `FilledButton`.
- If `adsRemoved` is already `true`: show a thank-you note ("Ads removed — thanks for your support!") above the tip rows. Tips remain available for repeat purchases.
- If `adsRemoved` is `false`: show a note below the rows: "Your first tip removes ads forever."
- Loading state: skeleton tiles while `queryProductDetails` resolves.
- Error state: "Store unavailable" with retry.

### Database Migration

Seed a persisted `ads_removed` setting for existing installs:

```sql
INSERT OR IGNORE INTO settings (key, value) VALUES ('ads_removed', 'false');
```

Migration index: next sequential migration in `AppDatabase`.

### Ad Helper

`AdHelper` utility class providing:

- `nativeAdUnitId` — returns platform-appropriate ad unit ID (test IDs in debug, real IDs in release).
- `adInterval` — `8` (posts between ads).
- `profileAdOffset` — `4` (delay before first ad on profile).

Test ad unit IDs (Google-provided):

- iOS: `ca-app-pub-3940256099942544/3986624511`
- Android: `ca-app-pub-3940256099942544/2247696110`
