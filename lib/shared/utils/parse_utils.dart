import 'package:bluesky_poptart/app/bsky/feed/post.dart';

FeedPostRecord? tryParseRecord(Map<String, dynamic> record) {
  try {
    return FeedPostRecord.fromJson(record);
  } catch (_) {
    return null;
  }
}
