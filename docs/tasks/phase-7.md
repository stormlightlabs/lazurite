---
title: Phase 7 Task Breakdown
updated: 2026-04-04
---

# Phase 7 Milestones

## M26 - Inline Native Ads

### Core - Ad Infrastructure

- [x] Add `google_mobile_ads: ^7.0.0` to `pubspec.yaml`
- [x] iOS: add `GADApplicationIdentifier`, `NSUserTrackingUsageDescription`, `SKAdNetworkItems` to `Info.plist`
- [x] Android: add `com.google.android.gms.ads.APPLICATION_ID` meta-data to `AndroidManifest.xml`
- [x] `AdHelper` utility — platform-aware ad unit IDs (test IDs in debug), `adInterval = 8`, `profileAdOffset = 4`
- [x] Call `MobileAds.instance.initialize()` in app bootstrap, gated on `!adsRemoved`

### Core - Database

- [x] Drift migration: seed persisted `ads_removed` setting for existing installs in the `Settings` table
- [x] `SettingsCubit` — expose `adsRemoved` flag, `setAdsRemoved(bool)` method

### Cubit

- [x] `AdCubit` — manages ad loading lifecycle per feed/profile instance
- [x] `AdState` — fields: slot-indexed loaded ads map, `adsRemoved`
- [x] `loadAdsForPage(int pageIndex, int postCount)` — pre-fetches ad instances for calculated slot positions
- [x] `disposeAd(int slotIndex)` — dispose ads scrolled far off-screen
- [x] Skip all ad operations when `adsRemoved == true`

### UI - Feed Ads

- [x] `FeedLayoutView` — adjust `itemCount` to include ad slots at every `adInterval` posts
- [x] Index mapping — `visualIndex → dataIndex` translation accounting for injected ad slots
- [x] `AdPostCard` widget — wraps ad content in a card matching `PostCard` dimensions, "Sponsored" label
- [x] Linear layout: full-width ad card with muted dividers
- [x] Grid layout: ad occupies single grid cell matching card aspect ratio
- [x] Collapse slot silently on ad load failure (no blank space)

### UI - Profile Ads

- [x] Profile posts tab — same ad injection with `profileAdOffset = 4` (first ad appears later)
- [x] Shared index mapping logic with feed (extract to helper or mixin)
- [x] No ads in Replies, Media, Lists, or Starter Packs tabs

### Tests

- [x] Unit tests: `AdHelper` — correct ad unit IDs for the active debug platform
- [x] Unit tests: `AdCubit` — ad loading, disposal, `adsRemoved` gating, page pre-fetch
- [x] Unit tests: index mapping — `visualIndex ↔ dataIndex` round-trip for feed and profile offsets
- [x] Widget tests: `AdPostCard` renders with "Sponsored" label, slot failures collapse cleanly
- [x] Widget tests: feed with ads — correct post ordering, ad at expected positions, no ads when `adsRemoved`
- [x] Widget tests: profile posts — ad offset respected, no ads in non-post tabs

## M27 - In-App Purchase Tips

### Core - Purchase Infrastructure

- [x] Add `in_app_purchase: ^3.2.3` to `pubspec.yaml`
- [x] `PurchaseRepository` — wraps `InAppPurchase.instance`
- [x] `isAvailable()` — checks store reachability
- [x] `fetchProducts()` — `queryProductDetails({'tip_coffee', 'tip_latte'})`, returns `List<ProductDetails>`
- [x] `buyTip(ProductDetails)` — calls `buyConsumable(purchaseParam: ...)`
- [x] `purchaseStream` — exposes `InAppPurchase.instance.purchaseStream`
- [x] `completePurchase(PurchaseDetails)` — forwards to `InAppPurchase.instance.completePurchase`

### Cubit

- [x] `TipCubit` — depends on `PurchaseRepository` and `SettingsCubit`
- [x] `TipState` — fields: `storeStatus` (loading/available/unavailable), `List<ProductDetails> products`, `purchaseStatus` (idle/pending/success/error), `adsRemoved`
- [x] `loadProducts()` — checks availability, fetches product details
- [x] `purchaseTip(ProductDetails)` — initiates purchase, listens for result
- [x] On `PurchaseStatus.purchased` → call `settingsCubit.setAdsRemoved(true)`, then `completePurchase()`
- [x] On `PurchaseStatus.error` → emit error state with message
- [x] Subscribe to `purchaseStream` in constructor, handle all terminal states

### UI - Tip Sheet

- [x] "Support Lazurite" row in Settings screen — opens modal bottom sheet
- [x] `TipSheet` widget — header with app icon + title
- [x] Two `ListTile` rows: Coffee (☕ $1.99) and Latte (☕☕ $4.99) with "Tip" `FilledButton`
- [x] Localized prices from `ProductDetails.price` (not hardcoded)
- [x] Loading state: skeleton tiles while products load
- [x] Error state: "Store unavailable" with retry button
- [x] If `adsRemoved`: thank-you banner above tip rows ("Ads removed — thanks for your support!")
- [x] If `!adsRemoved`: note below rows ("Your first tip removes ads forever.")
- [x] Pending state: loading indicator on tapped button, other button disabled

### Tests

- [x] Unit tests: `PurchaseRepository` — product query, buy consumable, complete purchase, availability check
- [x] Unit tests: `TipCubit` — product loading, purchase flow (success → ads removed, error → error state, pending → loading), stream subscription
- [x] Widget tests: `TipSheet` — renders products with localized prices, loading skeleton, error + retry, thank-you banner when ads removed, note when ads not removed
- [x] Widget tests: Settings screen — "Support Lazurite" row present, opens tip sheet on tap
- [x] Integration: first purchase sets `adsRemoved = true` in DB, subsequent ad cubit skips loading
