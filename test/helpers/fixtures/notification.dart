import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/notification/list_notifications.dart' as bsky;
import 'package:poptart_core/poptart_core.dart';

bsky.Notification testNotification({
  bsky.KnownNotificationReason reason = bsky.KnownNotificationReason.like,
  Object uri = 'at://did:plc:author/app.bsky.feed.post/abc',
  String cid = 'cid-123',
  ProfileView author = const ProfileView(did: 'did:plc:author', handle: 'author.bsky.social'),
  AtUri? reasonSubject,
  Map<String, Object?> record = const {r'$type': 'app.bsky.feed.post', 'text': 'Hello world'},
  bool isRead = false,
  DateTime? indexedAt,
}) => bsky.Notification(
  uri: uri is AtUri ? uri : AtUri.parse(uri as String),
  cid: cid,
  author: author,
  reason: bsky.NotificationReason.knownValue(data: reason),
  reasonSubject: reasonSubject,
  record: record,
  isRead: isRead,
  indexedAt: indexedAt ?? DateTime.utc(2026, 3, 15),
);
