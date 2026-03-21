part of 'my_lists_cubit.dart';

enum MyListsStatus { initial, loading, loaded, error }

class MyListsState extends Equatable {
  const MyListsState._({
    required this.status,
    this.actor,
    this.lists = const [],
    this.cursor,
    this.hasMore = false,
    this.limit = 50,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  const MyListsState.initial() : this._(status: MyListsStatus.initial);

  const MyListsState.loading({required String actor, int limit = 50})
    : this._(status: MyListsStatus.loading, actor: actor, limit: limit);

  const MyListsState.loaded({
    required String actor,
    required List<ListView> lists,
    String? cursor,
    required bool hasMore,
    int limit = 50,
    bool isRefreshing = false,
    bool isLoadingMore = false,
    String? errorMessage,
  }) : this._(
         status: MyListsStatus.loaded,
         actor: actor,
         lists: lists,
         cursor: cursor,
         hasMore: hasMore,
         limit: limit,
         isRefreshing: isRefreshing,
         isLoadingMore: isLoadingMore,
         errorMessage: errorMessage,
       );

  const MyListsState.error({required String message, String? actor, int limit = 50})
    : this._(status: MyListsStatus.error, actor: actor, limit: limit, errorMessage: message);

  final MyListsStatus status;
  final String? actor;
  final List<ListView> lists;
  final String? cursor;
  final bool hasMore;
  final int limit;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;

  List<ListView> get curationLists => lists.where(_isCurationList).toList(growable: false);
  List<ListView> get moderationLists => lists.where(_isModerationList).toList(growable: false);
  List<ListView> get referenceLists => lists.where(_isReferenceList).toList(growable: false);

  MyListsState copyWith({
    MyListsStatus? status,
    Object? actor = _myListsNoValue,
    List<ListView>? lists,
    Object? cursor = _myListsNoValue,
    bool? hasMore,
    int? limit,
    bool? isRefreshing,
    bool? isLoadingMore,
    Object? errorMessage = _myListsNoValue,
  }) {
    return MyListsState._(
      status: status ?? this.status,
      actor: actor == _myListsNoValue ? this.actor : actor as String?,
      lists: lists ?? this.lists,
      cursor: cursor == _myListsNoValue ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      limit: limit ?? this.limit,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage == _myListsNoValue ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, actor, lists, cursor, hasMore, limit, isRefreshing, isLoadingMore, errorMessage];
}

bool _isCurationList(ListView list) {
  return list.purpose.knownValue == KnownListPurpose.appBskyGraphDefsCuratelist;
}

bool _isModerationList(ListView list) {
  return list.purpose.knownValue == KnownListPurpose.appBskyGraphDefsModlist;
}

bool _isReferenceList(ListView list) {
  return list.purpose.knownValue == KnownListPurpose.appBskyGraphDefsReferencelist;
}

const _myListsNoValue = Object();
