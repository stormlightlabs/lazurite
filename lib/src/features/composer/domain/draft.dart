import 'package:freezed_annotation/freezed_annotation.dart';

part 'draft.freezed.dart';
part 'draft.g.dart';

enum DraftStatus { draft, publishing, failed, posted }

enum DraftMediaStatus { pending, uploading, uploaded, failed }

/// Thread gate types for controlling who can reply to a post.
enum ThreadGateType {
  /// Only mentioned users can reply.
  mention,

  /// Only users followed by the author can reply.
  following,

  /// Both mentioned and followed users can reply.
  mentionAndFollowing,
}

/// Converts string from database to ThreadGateType enum.
ThreadGateType? threadGateTypeFromString(String? value) {
  if (value == null) return null;
  return ThreadGateType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ThreadGateType.mention,
  );
}

/// Converts ThreadGateType enum to string for database storage.
String? threadGateTypeToString(ThreadGateType? value) {
  return value?.name;
}

@freezed
abstract class Draft with _$Draft {
  const factory Draft({
    required String id,
    required String text,
    required DraftStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<DraftMediaAttachment> media,
    String? replyParentUri,
    String? replyParentCid,
    String? replyRootUri,
    String? replyRootCid,
    String? quoteUri,
    String? quoteCid,
    String? facetsJson,
    String? externalUri,
    String? externalTitle,
    String? externalDescription,
    String? externalThumbBlobJson,
    String? errorMessage,
    @Default([]) List<String> langs,
    @Default([]) List<String> labels,
    ThreadGateType? threadGateType,
    @Default(false) bool quoteDisabled,
  }) = _Draft;

  const Draft._();

  factory Draft.fromJson(Map<String, dynamic> json) => _$DraftFromJson(json);

  /// Returns true if this is a root post (not a reply or quote).
  bool get isRootPost => replyParentUri == null && quoteUri == null;
}

@freezed
abstract class DraftMediaAttachment with _$DraftMediaAttachment {
  const factory DraftMediaAttachment({
    required int id,
    required String draftId,
    required String localPath,
    required String mimeType,
    required DraftMediaStatus status,
    required int sortOrder,
    String? altText,
    String? uploadCid,
    String? blobRefJson,
    int? durationSeconds,
    String? aspectRatio,
  }) = _DraftMediaAttachment;

  const DraftMediaAttachment._();

  factory DraftMediaAttachment.fromJson(Map<String, dynamic> json) =>
      _$DraftMediaAttachmentFromJson(json);

  bool get requiresUpload => uploadCid == null;

  bool get isVideo => mimeType.startsWith('video/');
}

@freezed
abstract class DraftMediaInput with _$DraftMediaInput {
  const factory DraftMediaInput({
    required String localPath,
    required String mimeType,
    String? altText,
  }) = _DraftMediaInput;

  factory DraftMediaInput.fromJson(Map<String, dynamic> json) => _$DraftMediaInputFromJson(json);
}
