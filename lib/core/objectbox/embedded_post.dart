import 'package:objectbox/objectbox.dart';

@Entity()
class EmbeddedPost {
  @Id()
  int id = 0;

  /// AT URI of the post (e.g. at://did:plc:xxx/app.bsky.feed.post/yyy)
  @Unique()
  String postUri;

  /// Account DID that saved/liked this post
  String accountDid;

  /// 'saved' or 'liked'
  String source;

  /// Concatenated searchable text at embedding time
  String indexedText;

  /// 384-dimensional embedding vector
  @HnswIndex(dimensions: 384, distanceType: VectorDistanceType.cosine)
  @Property(type: PropertyType.floatVector)
  List<double>? embedding;

  /// When the embedding was generated (for staleness checks)
  @Property(type: PropertyType.dateNano)
  DateTime embeddedAt;

  // ignore: sort_constructors_first
  EmbeddedPost({
    this.id = 0,
    required this.postUri,
    required this.accountDid,
    required this.source,
    required this.indexedText,
    this.embedding,
    required this.embeddedAt,
  });
}
