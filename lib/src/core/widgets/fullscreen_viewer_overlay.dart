import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Overlay widget for fullscreen media viewer.
///
/// Provides position indicator, close button, download button, and share button.
/// Auto-hides after 3 seconds of inactivity.
class FullscreenViewerOverlay extends StatefulWidget {
  const FullscreenViewerOverlay({
    required this.currentIndex,
    required this.totalCount,
    required this.onClose,
    this.onDownload,
    this.shareUrl,
    this.altText,
    this.onAltTextTap,
    super.key,
  });

  /// Current page index (0-based).
  final int currentIndex;

  /// Total number of items.
  final int totalCount;

  /// Callback when close button is pressed.
  final VoidCallback onClose;

  /// Callback when download button is pressed.
  final VoidCallback? onDownload;

  /// URL to share (if provided, share button is shown).
  final String? shareUrl;

  /// Alt text for the current media.
  final String? altText;

  /// Callback when alt text is tapped.
  final VoidCallback? onAltTextTap;

  @override
  State<FullscreenViewerOverlay> createState() => _FullscreenViewerOverlayState();
}

class _FullscreenViewerOverlayState extends State<FullscreenViewerOverlay>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  Timer? _autoHideTimer;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
    _startAutoHideTimer();
  }

  @override
  void didUpdateWidget(FullscreenViewerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _show();
      _startAutoHideTimer();
    }
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _hide();
      }
    });
  }

  void _show() {
    setState(() {
      _isVisible = true;
    });
    _fadeController.forward();
  }

  void _hide() {
    setState(() {
      _isVisible = false;
    });
    _fadeController.reverse();
  }

  void _handleShare() {
    if (widget.shareUrl != null) {
      Share.share(widget.shareUrl!, subject: 'Image from Bluesky');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isVisible ? _hide : _show,
      behavior: HitTestBehavior.translucent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: _OverlayButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onTap: widget.onClose,
                  tooltip: 'Close',
                ),
              ),
              if (widget.altText != null && widget.altText!.isNotEmpty)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        widget.onAltTextTap?.call();
                        _startAutoHideTimer();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'ALT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 16,
                right: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.onDownload != null)
                      _OverlayButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onTap: () {
                          widget.onDownload!();
                          _startAutoHideTimer();
                        },
                        tooltip: 'Download',
                      ),
                    if (widget.shareUrl != null) ...[
                      const SizedBox(width: 8),
                      _OverlayButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onTap: () {
                          _handleShare();
                          _startAutoHideTimer();
                        },
                        tooltip: 'Share',
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.totalCount > 1)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Semantics(
                        label: 'Image ${widget.currentIndex + 1} of ${widget.totalCount}',
                        child: Text(
                          '${widget.currentIndex + 1} / ${widget.totalCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular button with dark background for overlay controls.
class _OverlayButton extends StatelessWidget {
  const _OverlayButton({required this.icon, required this.onTap, required this.tooltip});

  final Icon icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(icon: icon, onPressed: onTap, tooltip: tooltip),
      ),
    );
  }
}
