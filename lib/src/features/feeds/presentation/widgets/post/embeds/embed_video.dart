import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:path_provider/path_provider.dart';

class EmbedVideo extends ConsumerWidget {
  const EmbedVideo({
    required this.playlist,
    this.thumbnail,
    this.alt,
    this.cid,
    this.authorDid,
    this.aspectRatio,
    this.durationSeconds,
    super.key,
  });

  final String playlist;
  final String? thumbnail;
  final String? alt;
  final String? cid;
  final String? authorDid;
  final Map<String, dynamic>? aspectRatio;
  final int? durationSeconds;

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _downloadVideo(BuildContext context, WidgetRef ref) async {
    if (cid == null || authorDid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot download video: missing metadata (CID/DID)')),
      );
      return;
    }

    try {
      String pdsUrl = 'https://bsky.social';
      try {
        final doc = await ref.read(identityRepositoryProvider).resolveDidDocument(authorDid!);
        final endpoint = doc?.pdsEndpoint;
        if (endpoint != null) {
          pdsUrl = endpoint;
        }
      } catch (e) {
        debugPrint('Failed to resolve DID, using fallback: $e');
      }

      final dio = ref.read(dioPublicProvider);
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final path = '${tempDir.path}/$fileName';

      final url = '$pdsUrl/xrpc/com.atproto.sync.getBlob?did=$authorDid&cid=$cid';

      await dio.download(url, path);
      await Gal.putVideo(path);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Video saved to gallery')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save video: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = (aspectRatio?['width'] as num?)?.toDouble();
    final height = (aspectRatio?['height'] as num?)?.toDouble();
    final ratio = (width != null && height != null && height > 0) ? width / height : 16 / 9;

    return Semantics(
      label: alt ?? 'Video',
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: ratio,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
                image: thumbnail != null
                    ? DecorationImage(image: NetworkImage(thumbnail!), fit: BoxFit.cover)
                    : null,
              ),
              child: thumbnail == null
                  ? const Center(child: Icon(Icons.movie, color: Colors.white54, size: 48))
                  : null,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
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
                onPressed: () => _downloadVideo(context, ref),
                tooltip: 'Download Video',
              ),
            ),
          ),
          if (durationSeconds != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(durationSeconds!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
