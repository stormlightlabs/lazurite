import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:lazurite/src/core/widgets/fullscreen_viewer_overlay.dart';
import 'package:lazurite/src/core/widgets/video_player_widget.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:path_provider/path_provider.dart';

/// Fullscreen video viewer with immersive mode and landscape orientation.
///
/// Displays video in fullscreen with:
/// - Immersive mode (hidden system UI)
/// - Auto-landscape orientation support
/// - Download and share controls
/// - System UI and orientation restored on exit
class FullscreenVideoViewer extends ConsumerStatefulWidget {
  const FullscreenVideoViewer({
    required this.playlist,
    this.thumbnail,
    this.alt,
    this.cid,
    this.authorDid,
    this.aspectRatio,
    this.durationSeconds,
    super.key,
  });

  /// Local file path to the video.
  final String playlist;

  /// Thumbnail URL for the video.
  final String? thumbnail;

  /// Alt text description.
  final String? alt;

  /// Content ID for downloading from PDS.
  final String? cid;

  /// Author DID for resolving PDS endpoint.
  final String? authorDid;

  /// Aspect ratio data (width/height).
  final Map<String, dynamic>? aspectRatio;

  /// Video duration in seconds.
  final int? durationSeconds;

  @override
  ConsumerState<FullscreenVideoViewer> createState() => _FullscreenVideoViewerState();
}

class _FullscreenVideoViewerState extends ConsumerState<FullscreenVideoViewer>
    with WidgetsBindingObserver {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enterFullscreenMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _exitFullscreenMode();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setImmersiveMode();
    }
  }

  void _enterFullscreenMode() {
    _setImmersiveMode();
    _setLandscapeOrientation();
    setState(() {
      _isInitialized = true;
    });
  }

  void _exitFullscreenMode() {
    _setSystemUIMode();
    _setPortraitOrientation();
  }

  void _setImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _setSystemUIMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _setLandscapeOrientation() {
    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _setPortraitOrientation() {
    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  Future<void> _downloadVideo(BuildContext context) async {
    if (widget.cid == null || widget.authorDid == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot download video: missing metadata (CID/DID)')),
        );
      }
      return;
    }

    try {
      String pdsUrl = 'https://bsky.social';
      try {
        final doc = await ref
            .read(identityRepositoryProvider)
            .resolveDidDocument(widget.authorDid!);
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

      final url =
          '$pdsUrl/xrpc/com.atproto.sync.getBlob?did=${widget.authorDid}&cid=${widget.cid}';

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

  void _showAltTextDialog(BuildContext context) {
    final alt = widget.alt ?? '';
    if (alt.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Description'),
        content: SingleChildScrollView(child: Text(alt)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _exitFullscreenMode();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: VideoPlayerWidget(
                videoPath: widget.playlist,
                isExpanded: true,
                autoplay: true,
                showControls: true,
              ),
            ),
            FullscreenViewerOverlay(
              currentIndex: 0,
              totalCount: 1,
              onClose: () => Navigator.of(context).pop(),
              onDownload: () => _downloadVideo(context),
              shareUrl: widget.cid != null && widget.authorDid != null
                  ? 'https://bsky.app/profile/${widget.authorDid}/post/${widget.cid}'
                  : null,
              altText: widget.alt,
              onAltTextTap: () => _showAltTextDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
