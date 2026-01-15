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

class Draft {
  Draft({
    required this.id,
    required this.text,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.media,
    this.replyParentUri,
    this.replyParentCid,
    this.replyRootUri,
    this.replyRootCid,
    this.quoteUri,
    this.quoteCid,
    this.facetsJson,
    this.externalUri,
    this.externalTitle,
    this.externalDescription,
    this.externalThumbBlobJson,
    this.errorMessage,
    this.langs = const [],
    this.labels = const [],
    this.threadGateType,
    this.quoteDisabled = false,
  });

  final String id;
  final String text;
  final String? replyParentUri;
  final String? replyParentCid;
  final String? replyRootUri;
  final String? replyRootCid;
  final String? quoteUri;
  final String? quoteCid;
  final String? facetsJson;
  final String? externalUri;
  final String? externalTitle;
  final String? externalDescription;
  final String? externalThumbBlobJson;
  final DraftStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DraftMediaAttachment> media;

  /// ISO 639 language codes for this post (e.g., ["en", "es"]).
  final List<String> langs;

  /// Self-applied content labels (e.g., ["sexual", "graphic-media"]).
  final List<String> labels;

  /// Thread gate type for reply restrictions (null = no restriction).
  final ThreadGateType? threadGateType;

  /// Whether quote posts are disabled for this draft.
  final bool quoteDisabled;

  /// Returns true if this is a root post (not a reply or quote).
  bool get isRootPost => replyParentUri == null && quoteUri == null;
}

class DraftMediaAttachment {
  DraftMediaAttachment({
    required this.id,
    required this.draftId,
    required this.localPath,
    required this.mimeType,
    required this.status,
    required this.sortOrder,
    this.altText,
    this.uploadCid,
    this.blobRefJson,
    this.durationSeconds,
    this.aspectRatio,
  });

  final int id;
  final String draftId;
  final String localPath;
  final String mimeType;
  final String? altText;
  final String? uploadCid;
  final DraftMediaStatus status;
  final int sortOrder;
  final String? blobRefJson;
  final int? durationSeconds;
  final String? aspectRatio;

  bool get requiresUpload => uploadCid == null;

  bool get isVideo => mimeType.startsWith('video/');
}

class DraftMediaInput {
  DraftMediaInput({required this.localPath, required this.mimeType, this.altText});

  final String localPath;
  final String mimeType;
  final String? altText;
}
