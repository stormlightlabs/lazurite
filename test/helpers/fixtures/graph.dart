import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/defs.dart' as bsky_graph;
import 'package:poptart_core/poptart_core.dart';

ProfileView testProfileView({
  String did = 'did:plc:creator',
  String handle = 'creator.bsky.social',
  String? displayName,
  String? description,
  String? avatar,
}) => ProfileView(did: did, handle: handle, displayName: displayName, description: description, avatar: avatar);

bsky_graph.ListView testListView({
  AtUri? uri,
  String cid = 'cid-list',
  ProfileView? creator,
  String name = 'Core List',
  String? description,
  bsky_graph.ListPurpose purpose = const bsky_graph.ListPurpose.knownValue(
    data: bsky_graph.KnownListPurpose.appBskyGraphDefsCuratelist,
  ),
  int? listItemCount,
  DateTime? indexedAt,
  bool? viewerMuted,
  AtUri? viewerBlocked,
}) => bsky_graph.ListView(
  uri: uri ?? AtUri.parse('at://did:plc:creator/app.bsky.graph.list/list-1'),
  cid: cid,
  creator: creator ?? testProfileView(),
  name: name,
  description: description,
  purpose: purpose,
  listItemCount: listItemCount,
  indexedAt: indexedAt ?? DateTime.utc(2026, 3, 21),
  viewer: (viewerMuted != null || viewerBlocked != null)
      ? bsky_graph.ListViewerState(muted: viewerMuted, blocked: viewerBlocked)
      : null,
);

bsky_graph.ListItemView testListItemView({AtUri? uri, ProfileView? subject}) => bsky_graph.ListItemView(
  uri: uri ?? AtUri.parse('at://did:plc:creator/app.bsky.graph.listitem/item-1'),
  subject: subject ?? testProfileView(did: 'did:plc:member', handle: 'member.bsky.social', displayName: 'A Member'),
);

bsky_graph.StarterPackViewBasic testStarterPackViewBasic({
  AtUri? uri,
  String cid = 'cid-pack',
  ProfileViewBasic? creator,
  Map<String, dynamic>? record,
  String name = 'Starter Pack',
  String? description,
  int? listItemCount,
  int? joinedWeekCount,
  int? joinedAllTimeCount,
  DateTime? indexedAt,
}) => bsky_graph.StarterPackViewBasic(
  uri: uri ?? AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack-1'),
  cid: cid,
  record:
      record ??
      {
        r'$type': 'app.bsky.graph.starterpack',
        'name': name,
        ...(description == null ? const <String, dynamic>{} : {'description': description}),
      },
  creator: creator ?? const ProfileViewBasic(did: 'did:plc:creator', handle: 'creator.bsky.social'),
  listItemCount: listItemCount,
  joinedWeekCount: joinedWeekCount,
  joinedAllTimeCount: joinedAllTimeCount,
  indexedAt: indexedAt ?? DateTime.utc(2026, 3, 21),
);
