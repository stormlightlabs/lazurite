class ComposeRouteArgs {
  const ComposeRouteArgs({
    this.replyParentUri,
    this.replyParentCid,
    this.replyRootUri,
    this.replyRootCid,
    this.replyAuthorHandle,
    this.quoteUri,
    this.quoteCid,
    this.quoteAuthorHandle,
    this.draftId,
    this.initialText,
    this.editPostUri,
    this.editPostCid,
    this.editRecord,
  });

  final String? replyParentUri;
  final String? replyParentCid;
  final String? replyRootUri;
  final String? replyRootCid;
  final String? replyAuthorHandle;
  final String? quoteUri;
  final String? quoteCid;
  final String? quoteAuthorHandle;
  final int? draftId;
  final String? initialText;
  final String? editPostUri;
  final String? editPostCid;
  final Map<String, dynamic>? editRecord;
}
