import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lazurite/core/cache/offline_cache_policy.dart';

class LazuriteImageCacheManager {
  LazuriteImageCacheManager._();

  static final CacheManager instance = CacheManager(
    Config(
      'lazurite_image_cache_v1',
      stalePeriod: OfflineCachePolicy.imageStalePeriod,
      maxNrOfCacheObjects: OfflineCachePolicy.imageObjectLimit,
    ),
  );
}

ImageProvider<Object>? appCachedImageProvider(String? imageUrl) {
  final url = imageUrl?.trim();
  if (url == null || url.isEmpty) {
    return null;
  }

  return CachedNetworkImageProvider(url, cacheManager: LazuriteImageCacheManager.instance);
}
