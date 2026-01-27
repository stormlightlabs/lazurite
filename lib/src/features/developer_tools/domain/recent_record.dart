import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_record.freezed.dart';
part 'recent_record.g.dart';

/// Represents a recently visited record in the developer tools.
@freezed
abstract class RecentRecord with _$RecentRecord {
  const factory RecentRecord({
    required String uri,
    required String did,
    required String collection,
    required String rkey,
    String? cid,
    DateTime? indexedAt,
    required DateTime viewedAt,
  }) = _RecentRecord;

  factory RecentRecord.fromJson(Map<String, dynamic> json) => _$RecentRecordFromJson(json);
}
