---
title: Phase 7 Task Breakdown
updated: 2026-04-04
---

# Phase 7 Milestones

## M26 - Inline Native Ads

### Core - Ad Infrastructure

- [ ] Add `google_mobile_ads: ^7.0.0` to `pubspec.yaml`
- [ ] iOS: add `GADApplicationIdentifier`, `NSUserTrackingUsageDescription`, `SKAdNetworkItems` to `Info.plist`
- [ ] Android: add `com.google.android.gms.ads.APPLICATION_ID` meta-data to `AndroidManifest.xml`
- [ ] `AdHelper` utility — platform-aware ad unit IDs (test in debug, real in release), `adInterval = 8`, `profileAdOffset = 4`
- [ ] Call `MobileAds.instance.initialize()` in app bootstrap, gated on `!adsRemoved`

### Core - Database

- [ ] Drift migration: add `adsRemoved` (`INTEGER NOT NULL DEFAULT 0`) column to `Settings` table
- [ ] `SettingsCubit` — expose `adsRemoved` flag, `setAdsRemoved(bool)` method

### Cubit

- [ ] `AdCubit` — manages ad loading lifecycle per feed/profile instance
- [ ] `AdState` — fields: `Map<int, NativeAd> loadedAds` (keyed by slot index), `adsRemoved`
- [ ] `loadAdsForPage(int pageIndex, int postCount)` — pre-fetches `NativeAd` instances for calculated slot positions
- [ ] `disposeAd(int slotIndex)` — dispose ads scrolled far off-screen
- [ ] Skip all ad operations when `adsRemoved == true`

### UI - Feed Ads

- [ ] `FeedLayoutView` — adjust `itemCount` to include ad slots at every `adInterval` posts
- [ ] Index mapping — `visualIndex → dataIndex` translation accounting for injected ad slots
- [ ] `AdPostCard` widget — wraps `AdWidget` + `NativeAd` in a card matching `PostCard` dimensions, "Sponsored" label
- [ ] Linear layout: full-width ad card with muted dividers
- [ ] Grid layout: ad occupies single grid cell matching card aspect ratio
- [ ] Collapse slot silently on `onAdFailedToLoad` (no blank space)

### UI - Profile Ads

- [ ] Profile posts tab — same ad injection with `profileAdOffset = 4` (first ad appears later)
- [ ] Shared index mapping logic with feed (extract to helper or mixin)
- [ ] No ads in Replies, Media, Lists, or Starter Packs tabs

### Tests

- [ ] Unit tests: `AdHelper` — correct ad unit IDs per platform and build mode
- [ ] Unit tests: `AdCubit` — ad loading, disposal, `adsRemoved` gating, page pre-fetch
- [ ] Unit tests: index mapping — `visualIndex ↔ dataIndex` round-trip for feed and profile offsets
- [ ] Widget tests: `AdPostCard` renders with "Sponsored" label, handles load failure gracefully
- [ ] Widget tests: feed with ads — correct post ordering, ad at expected positions, no ads when `adsRemoved`
- [ ] Widget tests: profile posts — ad offset respected, no ads in non-post tabs

## M27 - In-App Purchase Tips

### Core - Purchase Infrastructure

- [ ] Add `in_app_purchase: ^3.2.3` to `pubspec.yaml`
- [ ] `PurchaseRepository` — wraps `InAppPurchase.instance`
- [ ] `isAvailable()` — checks store reachability
- [ ] `fetchProducts()` — `queryProductDetails({'tip_coffee', 'tip_latte'})`, returns `List<ProductDetails>`
- [ ] `buyTip(ProductDetails)` — calls `buyConsumable(purchaseParam: ...)`
- [ ] `purchaseStream` — exposes `InAppPurchase.instance.purchaseStream`
- [ ] `completePurchase(PurchaseDetails)` — forwards to `InAppPurchase.instance.completePurchase`

### Cubit

- [ ] `TipCubit` — depends on `PurchaseRepository` and `SettingsCubit`
- [ ] `TipState` — fields: `storeStatus` (loading/available/unavailable), `List<ProductDetails> products`, `purchaseStatus` (idle/pending/success/error), `adsRemoved`
- [ ] `loadProducts()` — checks availability, fetches product details
- [ ] `purchaseTip(ProductDetails)` — initiates purchase, listens for result
- [ ] On `PurchaseStatus.purchased` → call `settingsCubit.setAdsRemoved(true)`, then `completePurchase()`
- [ ] On `PurchaseStatus.error` → emit error state with message
- [ ] Subscribe to `purchaseStream` in constructor, handle all terminal states

### UI - Tip Sheet

- [ ] "Support Lazurite" row in Settings screen — opens modal bottom sheet
- [ ] `TipSheet` widget — header with app icon + title
- [ ] Two `ListTile` rows: Coffee (☕ $1.99) and Latte (☕☕ $4.99) with "Tip" `FilledButton`
- [ ] Localized prices from `ProductDetails.price` (not hardcoded)
- [ ] Loading state: skeleton tiles while products load
- [ ] Error state: "Store unavailable" with retry button
- [ ] If `adsRemoved`: thank-you banner above tip rows ("Ads removed — thanks for your support!")
- [ ] If `!adsRemoved`: note below rows ("Your first tip removes ads forever.")
- [ ] Pending state: loading indicator on tapped button, other button disabled

### Tests

- [ ] Unit tests: `PurchaseRepository` — product query, buy consumable, complete purchase, availability check
- [ ] Unit tests: `TipCubit` — product loading, purchase flow (success → ads removed, error → error state, pending → loading), stream subscription
- [ ] Widget tests: `TipSheet` — renders products with localized prices, loading skeleton, error + retry, thank-you banner when ads removed, note when ads not removed
- [ ] Widget tests: Settings screen — "Support Lazurite" row present, opens tip sheet on tap
- [ ] Integration: first purchase sets `adsRemoved = true` in DB, subsequent ad cubit skips loading
