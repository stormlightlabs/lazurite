import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class EmbedImages extends StatelessWidget {
  const EmbedImages({required this.images, super.key});

  final List<dynamic> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return _SingleImage(image: images.first as Map<String, dynamic>);
    }

    if (images.length == 2) {
      return Row(
        children: [
          Expanded(child: _SingleImage(image: images[0] as Map<String, dynamic>)),
          const SizedBox(width: 4),
          Expanded(child: _SingleImage(image: images[1] as Map<String, dynamic>)),
        ],
      );
    }

    if (images.length == 3) {
      return Column(
        children: [
          _SingleImage(image: images[0] as Map<String, dynamic>),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: _SingleImage(image: images[1] as Map<String, dynamic>)),
              const SizedBox(width: 4),
              Expanded(child: _SingleImage(image: images[2] as Map<String, dynamic>)),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _SingleImage(image: images[0] as Map<String, dynamic>)),
            const SizedBox(width: 4),
            Expanded(child: _SingleImage(image: images[1] as Map<String, dynamic>)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: _SingleImage(image: images[2] as Map<String, dynamic>)),
            const SizedBox(width: 4),
            Expanded(child: _SingleImage(image: images[3] as Map<String, dynamic>)),
          ],
        ),
      ],
    );
  }
}

class _SingleImage extends StatelessWidget {
  const _SingleImage({required this.image});

  final Map<String, dynamic> image;

  Future<void> _downloadImage(BuildContext context, String url) async {
    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '${tempDir.path}/$fileName';

      await dio.download(url, path);
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

  @override
  Widget build(BuildContext context) {
    final thumb = image['thumb'] as String? ?? '';
    final fullsize = image['fullsize'] as String? ?? thumb;
    final alt = image['alt'] as String? ?? '';

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: NetworkImage(thumb), fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.download, color: Colors.white, size: 20),
              onPressed: () => _downloadImage(context, fullsize),
              tooltip: 'Download',
            ),
          ),
        ),
        if (alt.isNotEmpty)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ALT',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
