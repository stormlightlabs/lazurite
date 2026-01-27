import 'package:freezed_annotation/freezed_annotation.dart';

part 'repo_collection.freezed.dart';
part 'repo_collection.g.dart';

/// Represents an ATProto repository collection.
///
/// A collection is a type of record in a user's repository (e.g.,
/// app.bsky.feed.post, app.bsky.actor.profile).
///
/// Note: The com.atproto.repo.describeRepo API only returns collection NSIDs,
/// not record counts.
@freezed
abstract class RepoCollection with _$RepoCollection {
  const factory RepoCollection({required String nsid}) = _RepoCollection;

  factory RepoCollection.fromNsid(String nsid) => RepoCollection(nsid: nsid);

  factory RepoCollection.fromJson(Map<String, dynamic> json) => _$RepoCollectionFromJson(json);
}
