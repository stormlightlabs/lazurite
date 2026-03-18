part of 'convo_list_bloc.dart';

enum ConvoListStatus { initial, loading, loaded, error }

enum ConvoTab { primary, requests }

class ConvoListState extends Equatable {
  const ConvoListState._({
    required this.status,
    this.convos = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.activeTab = ConvoTab.primary,
    this.errorMessage,
  });

  const ConvoListState.initial() : this._(status: ConvoListStatus.initial);

  const ConvoListState.loading() : this._(status: ConvoListStatus.loading);

  const ConvoListState.loaded({
    required List<ConvoView> convos,
    String? cursor,
    bool hasMore = false,
    ConvoTab activeTab = ConvoTab.primary,
  }) : this._(status: ConvoListStatus.loaded, convos: convos, cursor: cursor, hasMore: hasMore, activeTab: activeTab);

  const ConvoListState.error(String message) : this._(status: ConvoListStatus.error, errorMessage: message);

  final ConvoListStatus status;
  final List<ConvoView> convos;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final ConvoTab activeTab;
  final String? errorMessage;

  ConvoListState copyWith({
    ConvoListStatus? status,
    List<ConvoView>? convos,
    String? cursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    ConvoTab? activeTab,
    String? errorMessage,
  }) {
    return ConvoListState._(
      status: status ?? this.status,
      convos: convos ?? this.convos,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      activeTab: activeTab ?? this.activeTab,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, convos, cursor, hasMore, isLoadingMore, isRefreshing, activeTab, errorMessage];
}
