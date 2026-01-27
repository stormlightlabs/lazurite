import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:lazurite/src/core/widgets/fullscreen_viewer_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

/// Fullscreen image viewer with zoom, pan, and gallery navigation.
///
/// Displays a list of images in fullscreen with:
/// - Pinch-to-zoom and pan via [InteractiveViewer]
/// - Swipe to navigate between images (if multiple)
/// - Double-tap to toggle between 1x and 2x zoom
/// - Swipe down to dismiss
/// - Download, share, and alt text controls
class FullscreenImageViewer extends StatefulWidget {
  const FullscreenImageViewer({required this.images, required this.initialIndex, super.key});

  /// List of image data maps containing 'thumb', 'fullsize', 'alt', 'aspectRatio'
  final List<Map<String, dynamic>> images;

  /// Initial image index to display.
  final int initialIndex;

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();

  /// Generate a unique hero tag for an image at index.
  static String heroTag(String fullsizeUrl, int index) {
    return 'image_hero_${fullsizeUrl}_$index';
  }
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAdjacentImages(widget.initialIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _downloadImage(BuildContext context) async {
    final image = widget.images[_currentIndex];
    final fullsize = image['fullsize'] as String? ?? '';

    if (fullsize.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cannot download: no image URL')));
      }
      return;
    }

    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '${tempDir.path}/$fileName';

      await dio.download(fullsize, path);
      await Gal.putImage(path);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image saved to gallery')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save image: $e')));
      }
    }
  }

  void _showAltTextDialog(BuildContext context) {
    final image = widget.images[_currentIndex];
    final alt = image['alt'] as String? ?? '';

    if (alt.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Description'),
        content: SingleChildScrollView(child: Text(alt)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _handlePageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _preloadAdjacentImages(index);
  }

  /// Preloads adjacent images for smoother navigation.
  void _preloadAdjacentImages(int index) {
    if (index > 0) {
      final prevImage = widget.images[index - 1];
      final prevUrl = prevImage['fullsize'] as String?;
      if (prevUrl != null && prevUrl.isNotEmpty) {
        precacheImage(NetworkImage(prevUrl), context);
      }
    }
    if (index < widget.images.length - 1) {
      final nextImage = widget.images[index + 1];
      final nextUrl = nextImage['fullsize'] as String?;
      if (nextUrl != null && nextUrl.isNotEmpty) {
        precacheImage(NetworkImage(nextUrl), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: _DismissDetector(
        onDismiss: () => Navigator.of(context).pop(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _handlePageChanged,
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final img = widget.images[index];
                final tag = FullscreenImageViewer.heroTag(img['fullsize'] as String? ?? '', index);
                return _ZoomableImagePage(image: img, heroTag: tag);
              },
            ),
            FullscreenViewerOverlay(
              currentIndex: _currentIndex,
              totalCount: widget.images.length,
              onClose: () => Navigator.of(context).pop(),
              onDownload: () => _downloadImage(context),
              shareUrl: widget.images[_currentIndex]['fullsize'] as String?,
              altText: widget.images[_currentIndex]['alt'] as String?,
              onAltTextTap: () => _showAltTextDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single zoomable image page with double-tap to zoom.
class _ZoomableImagePage extends StatefulWidget {
  const _ZoomableImagePage({required this.image, required this.heroTag});

  final Map<String, dynamic> image;
  final Object heroTag;

  @override
  State<_ZoomableImagePage> createState() => _ZoomableImagePageState();
}

class _ZoomableImagePageState extends State<_ZoomableImagePage> {
  final TransformationController _transformationController = TransformationController();
  double _doubleTapScale = 1.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDetails(TapDownDetails details) {
    setState(() {
      if (_doubleTapScale == 1.0) {
        _doubleTapScale = 2.0;
        final position = details.localPosition;
        _transformationController.value = Matrix4.identity()
          ..translateByVector3(
            vector.Vector3(
              -position.dx * (_doubleTapScale - 1),
              -position.dy * (_doubleTapScale - 1),
              0,
            ),
          )
          ..scaleByVector3(vector.Vector3.all(_doubleTapScale));
      } else {
        _doubleTapScale = 1.0;
        _transformationController.value = Matrix4.identity();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final img = widget.image;
    final fullsize = img['fullsize'] as String? ?? '';
    final alt = img['alt'] as String? ?? '';
    final aspectRatioData = img['aspectRatio'] as Map<String, dynamic>?;
    final width = (aspectRatioData?['width'] as num?)?.toDouble();
    final height = (aspectRatioData?['height'] as num?)?.toDouble();
    final aspectRatio = (width != null && height != null && height > 0) ? width / height : 16 / 9;

    return Semantics(
      label: alt.isNotEmpty ? alt : 'Image',
      image: true,
      child: Hero(
        tag: widget.heroTag,
        child: Center(
          child: GestureDetector(
            onDoubleTapDown: _handleDoubleTapDetails,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 4.0,
              child: _buildResponsiveNetworkImage(fullsize, aspectRatio),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveNetworkImage(String fullsize, double aspectRatio) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: CachedNetworkImage(
        imageUrl: fullsize,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.black,
          child: const Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 64)),
        ),
      ),
    );
  }
}

/// Detects vertical swipe-down gesture to dismiss the fullscreen viewer.
class _DismissDetector extends StatelessWidget {
  const _DismissDetector({required this.child, required this.onDismiss});

  final Widget child;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        final isDismissable = details.primaryVelocity != null && details.primaryVelocity! > 500;
        if (isDismissable) onDismiss();
      },
      child: child,
    );
  }
}
