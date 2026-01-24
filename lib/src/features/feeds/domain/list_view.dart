import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/src/features/feeds/domain/feed_generator.dart';

part 'list_view.freezed.dart';
part 'list_view.g.dart';

/// Represents list metadata from app.bsky.graph.getList.
@freezed
abstract class ListView with _$ListView {
  const factory ListView({
    required String uri,
    required String cid,
    required ActorBasic creator,
    required String name,
    required String purpose,
    String? description,
    String? avatar,
    int? listItemCount,
    DateTime? indexedAt,
  }) = _ListView;

  factory ListView.fromJson(Map<String, dynamic> json) => _$ListViewFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ListViewToJson(this as _ListView);
}
