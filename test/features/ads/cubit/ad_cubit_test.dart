import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/ads/cubit/ad_cubit.dart';
import 'package:lazurite/features/ads/data/native_ad_repository.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';

class _FakeNativeAdHandle implements NativeAdHandle {
  _FakeNativeAdHandle(this.label);

  final String label;
  bool disposed = false;

  @override
  Widget buildWidget() => Text(label);

  @override
  void dispose() {
    disposed = true;
  }
}

class _FakeNativeAdRepository implements NativeAdRepository {
  _FakeNativeAdRepository({Set<int>? failSlots}) : failSlots = failSlots ?? {};

  final Set<int> failSlots;
  final List<int> requestedSlots = <int>[];
  final Map<int, _FakeNativeAdHandle> handles = <int, _FakeNativeAdHandle>{};

  @override
  Future<NativeAdHandle?> loadAd({required int slotIndex}) async {
    requestedSlots.add(slotIndex);
    if (failSlots.contains(slotIndex)) {
      return null;
    }
    return handles.putIfAbsent(slotIndex, () => _FakeNativeAdHandle('ad-$slotIndex'));
  }
}

void main() {
  late AppDatabase database;
  late SettingsCubit settingsCubit;

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
    settingsCubit = SettingsCubit(database: database);
  });

  tearDown(() async {
    await settingsCubit.close();
    await database.close();
  });

  test('loads and stores ad slots for a page', () async {
    final repository = _FakeNativeAdRepository();
    final cubit = AdCubit(settingsCubit: settingsCubit, nativeAdRepository: repository);

    await cubit.loadAdsForPage(0, 10);

    expect(repository.requestedSlots, [8]);
    expect(cubit.state.loadedAds.keys, [8]);

    await cubit.close();
  });

  test('does not reload slots that are already cached', () async {
    final repository = _FakeNativeAdRepository();
    final cubit = AdCubit(settingsCubit: settingsCubit, nativeAdRepository: repository);

    await cubit.loadAdsForPage(0, 10);
    await cubit.loadAdsForPage(1, 18);

    expect(repository.requestedSlots, [8, 17]);
    expect(cubit.state.loadedAds.keys.toList()..sort(), [8, 17]);

    await cubit.close();
  });

  test('supports profile offset slot calculation', () async {
    final repository = _FakeNativeAdRepository();
    final cubit = AdCubit(settingsCubit: settingsCubit, nativeAdRepository: repository);

    await cubit.loadAdsForPage(0, 12, offset: 4);

    expect(repository.requestedSlots, [12]);
    expect(cubit.state.loadedAds.keys, [12]);

    await cubit.close();
  });

  test('disposeAd disposes the loaded handle and removes it from state', () async {
    final repository = _FakeNativeAdRepository();
    final cubit = AdCubit(settingsCubit: settingsCubit, nativeAdRepository: repository);

    await cubit.loadAdsForPage(0, 10);
    final handle = repository.handles[8]!;

    cubit.disposeAd(8);

    expect(handle.disposed, isTrue);
    expect(cubit.state.loadedAds, isEmpty);

    await cubit.close();
  });

  test('ads removed skips new loads and clears loaded ads', () async {
    final repository = _FakeNativeAdRepository();
    final cubit = AdCubit(settingsCubit: settingsCubit, nativeAdRepository: repository);

    await cubit.loadAdsForPage(0, 10);
    final handle = repository.handles[8]!;

    await settingsCubit.setAdsRemoved(true);
    await Future<void>.delayed(Duration.zero);
    await cubit.loadAdsForPage(1, 18);

    expect(handle.disposed, isTrue);
    expect(cubit.state.adsRemoved, isTrue);
    expect(cubit.state.loadedAds, isEmpty);
    expect(repository.requestedSlots, [8]);

    await cubit.close();
  });
}
