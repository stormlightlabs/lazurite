import 'dart:io';

import 'package:video_player/video_player.dart';

class VideoProcessor {
  VideoProcessor();

  Future<VideoMetadata> extractMetadata(String videoPath) async {
    final file = File(videoPath);
    if (!file.existsSync()) {
      throw StateError('Video file not found: $videoPath');
    }

    final controller = VideoPlayerController.file(file);
    try {
      await controller.initialize();

      return VideoMetadata(
        durationSeconds: controller.value.duration.inSeconds,
        width: controller.value.size.width.toInt(),
        height: controller.value.size.height.toInt(),
      );
    } finally {
      await controller.dispose();
    }
  }

  bool isVideoMimeType(String mimeType) {
    return mimeType.startsWith('video/');
  }
}

class VideoMetadata {
  const VideoMetadata({required this.durationSeconds, required this.width, required this.height});

  final int durationSeconds;
  final int width;
  final int height;

  Map<String, dynamic> toJson() {
    return {'width': width, 'height': height};
  }

  static VideoMetadata fromJson(Map<String, dynamic> json) {
    return VideoMetadata(
      durationSeconds: json['durationSeconds'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }
}
