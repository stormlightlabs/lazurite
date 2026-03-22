part of 'list_bloc.dart';

enum ListStatus { initial, loading, loaded, error, deleted }

class ListState extends Equatable {
  const ListState._({
    required this.status,
    this.listUri,
    this.list,
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.limit = 50,
    this.isRefreshing = false,
    this.isMutating = false,
    this.errorMessage,
  });

  const ListState.initial() : this._(status: ListStatus.initial);

  const ListState.loading({required AtUri listUri, int limit = 50})
    : this._(status: ListStatus.loading, listUri: listUri, limit: limit);

  const ListState.loaded({
    required AtUri listUri,
    required ListView list,
    required List<ListItemView> items,
    String? cursor,
    required bool hasMore,
    int limit = 50,
    bool isRefreshing = false,
    bool isMutating = false,
    String? errorMessage,
  }) : this._(
         status: ListStatus.loaded,
         listUri: listUri,
         list: list,
         items: items,
         cursor: cursor,
         hasMore: hasMore,
         limit: limit,
         isRefreshing: isRefreshing,
         isMutating: isMutating,
         errorMessage: errorMessage,
       );

  const ListState.error({required String message, AtUri? listUri, int limit = 50})
    : this._(status: ListStatus.error, listUri: listUri, limit: limit, errorMessage: message);

  const ListState.deleted() : this._(status: ListStatus.deleted);

  final ListStatus status;
  final AtUri? listUri;
  final ListView? list;
  final List<ListItemView> items;
  final String? cursor;
  final bool hasMore;
  final int limit;
  final bool isRefreshing;
  final bool isMutating;
  final String? errorMessage;

  bool get isLoading => status == ListStatus.loading;
  bool get hasError => status == ListStatus.error || errorMessage != null;
  bool get hasItems => items.isNotEmpty;

  ListState copyWith({
    ListStatus? status,
    Object? listUri = _listNoValue,
    Object? list = _listNoValue,
    List<ListItemView>? items,
    Object? cursor = _listNoValue,
    bool? hasMore,
    int? limit,
    bool? isRefreshing,
    bool? isMutating,
    Object? errorMessage = _listNoValue,
  }) {
    return ListState._(
      status: status ?? this.status,
      listUri: listUri == _listNoValue ? this.listUri : listUri as AtUri?,
      list: list == _listNoValue ? this.list : list as ListView?,
      items: items ?? this.items,
      cursor: cursor == _listNoValue ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      limit: limit ?? this.limit,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: errorMessage == _listNoValue ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    listUri,
    list,
    items,
    cursor,
    hasMore,
    limit,
    isRefreshing,
    isMutating,
    errorMessage,
  ];
}

const _listNoValue = Object();
