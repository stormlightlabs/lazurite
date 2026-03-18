class ImageViewerRouteArgs {
  const ImageViewerRouteArgs({required this.images, required this.initialIndex});

  final List<ImageViewerItem> images;
  final int initialIndex;
}

class ImageViewerItem {
  const ImageViewerItem({required this.fullsizeUrl, required this.thumbnailUrl, required this.heroTag, this.altText});

  final String fullsizeUrl;
  final String thumbnailUrl;
  final String heroTag;
  final String? altText;
}
