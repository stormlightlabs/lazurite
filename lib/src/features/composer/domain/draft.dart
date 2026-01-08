enum DraftStatus { draft, publishing, failed, posted }

enum DraftMediaStatus { pending, uploading, uploaded, failed }

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

  bool get requiresUpload => uploadCid == null;
}

class DraftMediaInput {
  DraftMediaInput({required this.localPath, required this.mimeType, this.altText});

  final String localPath;
  final String mimeType;
  final String? altText;
}
