import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:lazurite/features/feed/presentation/media/image_viewer_route_args.dart';
import 'package:lazurite/features/feed/presentation/media/media_actions.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({super.key, required this.args});

  final ImageViewerRouteArgs args;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  double _dragOffset = 0;
  double _downloadProgress = 0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.args.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.args.images[_currentIndex];
    final theme = Theme.of(context);
    final progressValue = _downloadProgress > 0 && _downloadProgress < 1 ? _downloadProgress : null;
    final backgroundOpacity = (1 - (_dragOffset.abs() / 240)).clamp(0.45, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: backgroundOpacity),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black26,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close),
        ),
        actions: [
          IconButton(
            tooltip: 'Download',
            onPressed: _isDownloading ? null : _downloadCurrentImage,
            icon: _isDownloading
                ? SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(value: progressValue, strokeWidth: 2.4, color: Colors.white),
                  )
                : const Icon(Icons.download_outlined),
          ),
          IconButton(
            tooltip: 'Share',
            onPressed: () => MediaActions.shareImage(context, image.fullsizeUrl),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          setState(() {
            _dragOffset += details.delta.dy;
          });
        },
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (_dragOffset.abs() > 120 || velocity.abs() > 900) {
            Navigator.of(context).maybePop();
            return;
          }
          setState(() {
            _dragOffset = 0;
          });
        },
        onVerticalDragCancel: () {
          setState(() {
            _dragOffset = 0;
          });
        },
        child: Stack(
          children: [
            Transform.translate(
              offset: Offset(0, _dragOffset),
              child: PhotoViewGallery.builder(
                pageController: _pageController,
                itemCount: widget.args.images.length,
                backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                loadingBuilder: (context, event) {
                  final expected = event?.expectedTotalBytes;
                  final value = expected != null && expected > 0 ? event!.cumulativeBytesLoaded / expected : null;
                  return Center(
                    child: CircularProgressIndicator(value: value, color: Colors.white),
                  );
                },
                builder: (context, index) {
                  final item = widget.args.images[index];
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(item.fullsizeUrl),
                    heroAttributes: PhotoViewHeroAttributes(tag: item.heroTag),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2.6,
                    errorBuilder: (context, error, stackTrace) =>
                        Center(child: Icon(Icons.broken_image_outlined, color: theme.colorScheme.onSurface, size: 40)),
                  );
                },
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.args.images.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.args.images.length}',
                        style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                  if ((image.altText?.trim().isNotEmpty ?? false)) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        image.altText!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadCurrentImage() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    final image = widget.args.images[_currentIndex];
    await MediaActions.downloadImage(
      context,
      image.fullsizeUrl,
      onProgress: (value) {
        if (!mounted) {
          return;
        }
        setState(() {
          _downloadProgress = value;
        });
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isDownloading = false;
      _downloadProgress = 0;
    });
  }
}
