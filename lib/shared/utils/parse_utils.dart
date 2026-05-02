import 'package:bluesky/app_bsky_feed_post.dart';

FeedPostRecord? tryParseRecord(Map<String, dynamic> record) {
  try {
    return FeedPostRecord.fromJson(record);
  } catch (_) {
    return null;
  }
}
