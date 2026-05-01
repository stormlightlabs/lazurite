class ComposeRouteArgs {
  factory ComposeRouteArgs.parseExtra(Object? extra) {
    if (extra is ComposeRouteArgs) {
      return extra;
    }

    if (extra is Map) {
      String? readString(String key) {
        final value = extra[key];
        return value is String ? value : null;
      }

      int? readInt(String key) {
        final value = extra[key];
        if (value is int) {
          return value;
        }
        if (value is String) {
          return int.tryParse(value);
        }
        return null;
      }

      Map<String, dynamic>? readMap(String key) {
        final value = extra[key];
        if (value is Map<String, dynamic>) {
          return value;
        }
        if (value is Map) {
          return Map<String, dynamic>.from(value);
        }
        return null;
      }

      return ComposeRouteArgs(
        replyParentUri: readString('replyParentUri'),
        replyParentCid: readString('replyParentCid'),
        replyRootUri: readString('replyRootUri'),
        replyRootCid: readString('replyRootCid'),
        replyAuthorHandle: readString('replyAuthorHandle'),
        quoteUri: readString('quoteUri'),
        quoteCid: readString('quoteCid'),
        quoteAuthorHandle: readString('quoteAuthorHandle'),
        quoteText: readString('quoteText'),
        draftId: readInt('draftId'),
        initialText: readString('initialText'),
        editPostUri: readString('editPostUri'),
        editPostCid: readString('editPostCid'),
        editRecord: readMap('editRecord'),
      );
    }

    return const ComposeRouteArgs();
  }
  const ComposeRouteArgs({
    this.replyParentUri,
    this.replyParentCid,
    this.replyRootUri,
    this.replyRootCid,
    this.replyAuthorHandle,
    this.quoteUri,
    this.quoteCid,
    this.quoteAuthorHandle,
    this.quoteText,
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
  final String? quoteText;
  final int? draftId;
  final String? initialText;
  final String? editPostUri;
  final String? editPostCid;
  final Map<String, dynamic>? editRecord;
}
