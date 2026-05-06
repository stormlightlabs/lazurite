import 'package:flutter/widgets.dart';
import 'package:lazurite/core/cache/lazurite_image_cache.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/objectbox/embedded_post.dart';
import 'package:lazurite/core/objectbox/objectbox_store.dart';
import 'package:lazurite/objectbox.g.dart';

class LocalCacheMaintenanceService {
  LocalCacheMaintenanceService({
    required AppDatabase database,
    required ObjectBoxStore objectBoxStore,
    Future<void> Function()? clearImageDiskCache,
    VoidCallback? clearImageMemoryCache,
  }) : _database = database,
       _objectBoxStore = objectBoxStore,
       _clearImageDiskCache = clearImageDiskCache ?? LazuriteImageCacheManager.instance.emptyCache,
       _clearImageMemoryCache = clearImageMemoryCache ?? _defaultClearImageMemoryCache;

  final AppDatabase _database;
  final ObjectBoxStore _objectBoxStore;
  final Future<void> Function() _clearImageDiskCache;
  final VoidCallback _clearImageMemoryCache;

  Future<void> clearCaches() async {
    await _database.clearLocalCaches();
    Box<EmbeddedPost>(_objectBoxStore.store).removeAll();
    await _clearImageDiskCache();
    _clearImageMemoryCache();
  }

  static void _defaultClearImageMemoryCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
    imageCache.clearLiveImages();
  }
}
