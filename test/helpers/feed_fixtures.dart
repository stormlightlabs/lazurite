import 'package:bluesky_poptart/app/bsky/actor/defs.dart' hide ViewerState;
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:poptart_core/poptart_core.dart';

const testAuthorDid = 'did:plc:author';
const testAuthorHandle = 'author.bsky.social';
const testPostUri = 'at://did:plc:author/app.bsky.feed.post/abc';

ProfileViewBasic testProfileViewBasic({
  String did = testAuthorDid,
  String handle = testAuthorHandle,
  String? displayName,
  String? avatar,
}) => ProfileViewBasic(did: did, handle: handle, displayName: displayName, avatar: avatar);

Map<String, Object?> testPostRecordJson({
  String text = 'Test post',
  DateTime? createdAt,
  Map<String, Object?> extra = const {},
}) => {
  r'$type': 'app.bsky.feed.post',
  'text': text,
  'createdAt': (createdAt ?? DateTime.utc(2026, 3, 15)).toUtc().toIso8601String(),
  ...extra,
};

PostView testPostView({
  String uri = testPostUri,
  String? cid,
  ProfileViewBasic? author,
  Map<String, Object?>? record,
  DateTime? indexedAt,
  int? replyCount,
  int? repostCount,
  int? likeCount,
  int? quoteCount,
  UPostViewEmbed? embed,
}) => PostView(
  uri: AtUri.parse(uri),
  cid: cid ?? 'cid-${uri.hashCode}',
  author: author ?? testProfileViewBasic(),
  record: record ?? testPostRecordJson(),
  indexedAt: indexedAt ?? DateTime.utc(2026, 3, 15),
  replyCount: replyCount,
  repostCount: repostCount,
  likeCount: likeCount,
  quoteCount: quoteCount,
  embed: embed,
);

FeedViewPost testFeedViewPost({
  String uri = testPostUri,
  String? cid,
  ProfileViewBasic? author,
  Map<String, Object?>? record,
  DateTime? indexedAt,
  int? replyCount,
  int? repostCount,
  int? likeCount,
  int? quoteCount,
  UPostViewEmbed? embed,
}) => FeedViewPost(
  post: testPostView(
    uri: uri,
    cid: cid,
    author: author,
    record: record,
    indexedAt: indexedAt,
    replyCount: replyCount,
    repostCount: repostCount,
    likeCount: likeCount,
    quoteCount: quoteCount,
    embed: embed,
  ),
);
