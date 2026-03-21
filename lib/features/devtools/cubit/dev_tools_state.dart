part of 'dev_tools_cubit.dart';

enum DevToolsStatus { initial, loading, repoLoaded, collectionLoaded, recordLoaded, loadingMore, error }

class CollectionSummary extends Equatable {
  const CollectionSummary(this.name, {this.recordCount});

  final String name;
  final int? recordCount;

  String get countLabel => recordCount == null ? '...' : '$recordCount';

  @override
  List<Object?> get props => [name, recordCount];
}

class RecordInfo extends Equatable {
  const RecordInfo({required this.uri, this.cid, required this.value});

  final String uri;
  final String? cid;
  final Map<String, dynamic> value;

  String get rkey {
    try {
      return AtUri.parse(uri).rkey;
    } catch (_) {
      return '';
    }
  }

  String get atUriToLink {
    final uriString = uri.replaceFirst('at://', '');
    return 'https://aturi.to/$uriString';
  }

  @override
  List<Object?> get props => [uri, cid, value];
}

const _devToolsStateNoChange = Object();

class DevToolsState extends Equatable {
  const DevToolsState({
    this.status = DevToolsStatus.initial,
    this.did,
    this.handle,
    this.repoHandle,
    this.collections = const [],
    this.isCollectionCountsLoading = false,
    this.selectedCollection,
    this.records,
    this.recordsCursor,
    this.selectedRecord,
    this.isCollectionLoading = false,
    this.isRecordLoading = false,
    this.errorMessage,
  });

  final DevToolsStatus status;
  final String? did;
  final String? handle;
  final String? repoHandle;
  final List<CollectionSummary> collections;
  final bool isCollectionCountsLoading;
  final String? selectedCollection;
  final List<RepoListRecordsRecord>? records;
  final String? recordsCursor;
  final RecordInfo? selectedRecord;
  final bool isCollectionLoading;
  final bool isRecordLoading;
  final String? errorMessage;

  bool get isLoading => status == DevToolsStatus.loading || status == DevToolsStatus.loadingMore;
  bool get isNavigating => isCollectionLoading || isRecordLoading;
  bool get hasMoreRecords => recordsCursor != null && recordsCursor!.isNotEmpty;
  int get totalRecords => records?.length ?? 0;
  int? get totalRepoRecords {
    if (collections.isEmpty) {
      return 0;
    }
    if (collections.any((collection) => collection.recordCount == null)) {
      return null;
    }

    return collections.fold<int>(0, (sum, collection) => sum + collection.recordCount!);
  }

  DevToolsState copyWith({
    DevToolsStatus? status,
    Object? did = _devToolsStateNoChange,
    Object? handle = _devToolsStateNoChange,
    Object? repoHandle = _devToolsStateNoChange,
    List<CollectionSummary>? collections,
    bool? isCollectionCountsLoading,
    Object? selectedCollection = _devToolsStateNoChange,
    Object? records = _devToolsStateNoChange,
    Object? recordsCursor = _devToolsStateNoChange,
    Object? selectedRecord = _devToolsStateNoChange,
    bool? isCollectionLoading,
    bool? isRecordLoading,
    Object? errorMessage = _devToolsStateNoChange,
  }) {
    return DevToolsState(
      status: status ?? this.status,
      did: identical(did, _devToolsStateNoChange) ? this.did : did as String?,
      handle: identical(handle, _devToolsStateNoChange) ? this.handle : handle as String?,
      repoHandle: identical(repoHandle, _devToolsStateNoChange) ? this.repoHandle : repoHandle as String?,
      collections: collections ?? this.collections,
      isCollectionCountsLoading: isCollectionCountsLoading ?? this.isCollectionCountsLoading,
      selectedCollection: identical(selectedCollection, _devToolsStateNoChange)
          ? this.selectedCollection
          : selectedCollection as String?,
      records: identical(records, _devToolsStateNoChange) ? this.records : records as List<RepoListRecordsRecord>?,
      recordsCursor: identical(recordsCursor, _devToolsStateNoChange) ? this.recordsCursor : recordsCursor as String?,
      selectedRecord: identical(selectedRecord, _devToolsStateNoChange)
          ? this.selectedRecord
          : selectedRecord as RecordInfo?,
      isCollectionLoading: isCollectionLoading ?? this.isCollectionLoading,
      isRecordLoading: isRecordLoading ?? this.isRecordLoading,
      errorMessage: identical(errorMessage, _devToolsStateNoChange) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    did,
    handle,
    repoHandle,
    collections,
    isCollectionCountsLoading,
    selectedCollection,
    records,
    recordsCursor,
    selectedRecord,
    isCollectionLoading,
    isRecordLoading,
    errorMessage,
  ];
}
