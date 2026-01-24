import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart' show Profile;

part 'author.freezed.dart';
part 'author.g.dart';

/// Represents an author/profile in posts and feeds.
@freezed
abstract class Author with _$Author {
  /// Creates an Author from a database Profile.
  factory Author.fromProfile(Profile profile) {
    return Author(
      did: profile.did,
      handle: profile.handle,
      displayName: profile.displayName,
      avatar: profile.avatar,
    );
  }
  const factory Author({
    required String did,
    required String handle,
    String? displayName,
    String? avatar,
  }) = _Author;

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthorToJson(this as _Author);
}
