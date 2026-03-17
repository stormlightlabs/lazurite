part of 'compose_bloc.dart';

/// Sentinel used by copyWith to distinguish "leave unchanged" from "set to null".
class _Undefined {
  const _Undefined();
}

enum ComposeStatus { initial, ready, submitting, success, error }

enum VideoUploadStatus { idle, checkingLimits, uploading, processing, ready, error }

class VideoAttachment extends Equatable {
  const VideoAttachment({
    required this.localPath,
    this.status = VideoUploadStatus.idle,
    this.uploadProgress = 0,
    this.blob,
    this.altText = '',
    this.jobId,
    this.errorMessage,
  });

  final String localPath;
  final VideoUploadStatus status;
  final int uploadProgress;
  final Blob? blob;
  final String altText;
  final String? jobId;
  final String? errorMessage;

  bool get isActive =>
      status == VideoUploadStatus.checkingLimits ||
      status == VideoUploadStatus.uploading ||
      status == VideoUploadStatus.processing;
  bool get isReady => status == VideoUploadStatus.ready;
  bool get hasError => status == VideoUploadStatus.error;

  VideoAttachment copyWith({
    String? localPath,
    VideoUploadStatus? status,
    int? uploadProgress,
    Object? blob = const _Undefined(),
    String? altText,
    Object? jobId = const _Undefined(),
    Object? errorMessage = const _Undefined(),
  }) {
    return VideoAttachment(
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      blob: blob is _Undefined ? this.blob : blob as Blob?,
      altText: altText ?? this.altText,
      jobId: jobId is _Undefined ? this.jobId : jobId as String?,
      errorMessage: errorMessage is _Undefined ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [localPath, status, uploadProgress, blob, altText, jobId, errorMessage];
}

class ComposeState extends Equatable {
  const ComposeState._({
    required this.status,
    this.text = '',
    this.graphemeCount = 0,
    this.isOverLimit = false,
    this.isEmpty = true,
    this.mediaAttachments = const [],
    this.draftId,
    this.scheduledAt,
    this.replyParentUri,
    this.replyParentCid,
    this.replyRootUri,
    this.replyRootCid,
    this.errorMessage,
    this.drafts = const [],
    this.isSavingDraft = false,
    this.isLoadingDrafts = false,
    this.canSubmit = false,
    this.videoAttachment,
  });

  const ComposeState.initial() : this._(status: ComposeStatus.initial);

  const ComposeState.ready({
    String text = '',
    int graphemeCount = 0,
    bool isOverLimit = false,
    bool isEmpty = true,
    List<MediaAttachment> mediaAttachments = const [],
    int? draftId,
    DateTime? scheduledAt,
    String? replyParentUri,
    String? replyParentCid,
    String? replyRootUri,
    String? replyRootCid,
    VideoAttachment? videoAttachment,
  }) : this._(
         status: ComposeStatus.ready,
         text: text,
         graphemeCount: graphemeCount,
         isOverLimit: isOverLimit,
         isEmpty: isEmpty,
         mediaAttachments: mediaAttachments,
         draftId: draftId,
         scheduledAt: scheduledAt,
         replyParentUri: replyParentUri,
         replyParentCid: replyParentCid,
         replyRootUri: replyRootUri,
         replyRootCid: replyRootCid,
         videoAttachment: videoAttachment,
         canSubmit: !isOverLimit && !isEmpty,
       );

  final ComposeStatus status;
  final String text;
  final int graphemeCount;
  final bool isOverLimit;
  final bool isEmpty;
  final List<MediaAttachment> mediaAttachments;
  final int? draftId;
  final DateTime? scheduledAt;
  final String? replyParentUri;
  final String? replyParentCid;
  final String? replyRootUri;
  final String? replyRootCid;
  final String? errorMessage;
  final List<DraftEntry> drafts;
  final bool isSavingDraft;
  final bool isLoadingDrafts;
  final bool canSubmit;
  final VideoAttachment? videoAttachment;

  bool get isSubmitting => status == ComposeStatus.submitting;
  bool get hasError => status == ComposeStatus.error;
  bool get isSuccess => status == ComposeStatus.success;
  bool get isReady => status == ComposeStatus.ready;
  bool get hasMedia => mediaAttachments.isNotEmpty;
  bool get hasVideo => videoAttachment != null;
  bool get canAddMoreMedia => mediaAttachments.length < 4 && videoAttachment == null;
  bool get canAddVideo => mediaAttachments.isEmpty && videoAttachment == null;
  bool get hasScheduledTime => scheduledAt != null;
  bool get isReply => replyParentUri != null;

  ComposeState copyWith({
    ComposeStatus? status,
    String? text,
    int? graphemeCount,
    bool? isOverLimit,
    bool? isEmpty,
    List<MediaAttachment>? mediaAttachments,
    Object? draftId = const _Undefined(),
    Object? scheduledAt = const _Undefined(),
    Object? replyParentUri = const _Undefined(),
    Object? replyParentCid = const _Undefined(),
    Object? replyRootUri = const _Undefined(),
    Object? replyRootCid = const _Undefined(),
    Object? errorMessage = const _Undefined(),
    List<DraftEntry>? drafts,
    bool? isSavingDraft,
    bool? isLoadingDrafts,
    bool? canSubmit,
    Object? videoAttachment = const _Undefined(),
  }) {
    return ComposeState._(
      status: status ?? this.status,
      text: text ?? this.text,
      graphemeCount: graphemeCount ?? this.graphemeCount,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isEmpty: isEmpty ?? this.isEmpty,
      mediaAttachments: mediaAttachments ?? this.mediaAttachments,
      draftId: draftId is _Undefined ? this.draftId : draftId as int?,
      scheduledAt: scheduledAt is _Undefined ? this.scheduledAt : scheduledAt as DateTime?,
      replyParentUri: replyParentUri is _Undefined ? this.replyParentUri : replyParentUri as String?,
      replyParentCid: replyParentCid is _Undefined ? this.replyParentCid : replyParentCid as String?,
      replyRootUri: replyRootUri is _Undefined ? this.replyRootUri : replyRootUri as String?,
      replyRootCid: replyRootCid is _Undefined ? this.replyRootCid : replyRootCid as String?,
      errorMessage: errorMessage is _Undefined ? this.errorMessage : errorMessage as String?,
      drafts: drafts ?? this.drafts,
      isSavingDraft: isSavingDraft ?? this.isSavingDraft,
      isLoadingDrafts: isLoadingDrafts ?? this.isLoadingDrafts,
      canSubmit: canSubmit ?? this.canSubmit,
      videoAttachment: videoAttachment is _Undefined ? this.videoAttachment : videoAttachment as VideoAttachment?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    text,
    graphemeCount,
    isOverLimit,
    isEmpty,
    mediaAttachments,
    draftId,
    scheduledAt,
    replyParentUri,
    replyParentCid,
    replyRootUri,
    replyRootCid,
    errorMessage,
    drafts,
    isSavingDraft,
    isLoadingDrafts,
    canSubmit,
    videoAttachment,
  ];
}

class MediaAttachment extends Equatable {
  const MediaAttachment({
    required this.localPath,
    this.blobRef,
    this.altText = '',
    this.width,
    this.height,
    this.isUploaded = false,
    this.isUploading = false,
    this.uploadError,
  });

  final String localPath;
  final BlobRef? blobRef;
  final String altText;
  final int? width;
  final int? height;
  final bool isUploaded;
  final bool isUploading;
  final String? uploadError;

  MediaAttachment copyWith({
    String? localPath,
    Object? blobRef = const _Undefined(),
    String? altText,
    Object? width = const _Undefined(),
    Object? height = const _Undefined(),
    bool? isUploaded,
    bool? isUploading,
    Object? uploadError = const _Undefined(),
  }) {
    return MediaAttachment(
      localPath: localPath ?? this.localPath,
      blobRef: blobRef is _Undefined ? this.blobRef : blobRef as BlobRef?,
      altText: altText ?? this.altText,
      width: width is _Undefined ? this.width : width as int?,
      height: height is _Undefined ? this.height : height as int?,
      isUploaded: isUploaded ?? this.isUploaded,
      isUploading: isUploading ?? this.isUploading,
      uploadError: uploadError is _Undefined ? this.uploadError : uploadError as String?,
    );
  }

  @override
  List<Object?> get props => [localPath, blobRef, altText, width, height, isUploaded, isUploading, uploadError];
}
