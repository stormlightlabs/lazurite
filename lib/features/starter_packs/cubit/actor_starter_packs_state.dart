part of 'actor_starter_packs_cubit.dart';

enum ActorStarterPacksStatus { initial, loading, loaded, error }

class ActorStarterPacksState extends Equatable {
  const ActorStarterPacksState._({
    required this.status,
    this.actor,
    this.starterPacks = const [],
    this.cursor,
    this.hasMore = false,
    this.limit = 50,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  const ActorStarterPacksState.initial() : this._(status: ActorStarterPacksStatus.initial);

  const ActorStarterPacksState.loading({required String actor, int limit = 50})
    : this._(status: ActorStarterPacksStatus.loading, actor: actor, limit: limit);

  const ActorStarterPacksState.loaded({
    required String actor,
    required List<StarterPackViewBasic> starterPacks,
    String? cursor,
    required bool hasMore,
    int limit = 50,
    bool isRefreshing = false,
    bool isLoadingMore = false,
    String? errorMessage,
  }) : this._(
         status: ActorStarterPacksStatus.loaded,
         actor: actor,
         starterPacks: starterPacks,
         cursor: cursor,
         hasMore: hasMore,
         limit: limit,
         isRefreshing: isRefreshing,
         isLoadingMore: isLoadingMore,
         errorMessage: errorMessage,
       );

  const ActorStarterPacksState.error({required String message, String? actor, int limit = 50})
    : this._(status: ActorStarterPacksStatus.error, actor: actor, limit: limit, errorMessage: message);

  final ActorStarterPacksStatus status;
  final String? actor;
  final List<StarterPackViewBasic> starterPacks;
  final String? cursor;
  final bool hasMore;
  final int limit;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;

  ActorStarterPacksState copyWith({
    ActorStarterPacksStatus? status,
    Object? actor = _actorStarterPacksNoValue,
    List<StarterPackViewBasic>? starterPacks,
    Object? cursor = _actorStarterPacksNoValue,
    bool? hasMore,
    int? limit,
    bool? isRefreshing,
    bool? isLoadingMore,
    Object? errorMessage = _actorStarterPacksNoValue,
  }) {
    return ActorStarterPacksState._(
      status: status ?? this.status,
      actor: actor == _actorStarterPacksNoValue ? this.actor : actor as String?,
      starterPacks: starterPacks ?? this.starterPacks,
      cursor: cursor == _actorStarterPacksNoValue ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      limit: limit ?? this.limit,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage == _actorStarterPacksNoValue ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    actor,
    starterPacks,
    cursor,
    hasMore,
    limit,
    isRefreshing,
    isLoadingMore,
    errorMessage,
  ];
}

const _actorStarterPacksNoValue = Object();
