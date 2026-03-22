part of 'starter_pack_bloc.dart';

enum StarterPackStatus { initial, loading, loaded, error, deleted }

class StarterPackState extends Equatable {
  const StarterPackState._({
    required this.status,
    this.packUri,
    this.starterPack,
    this.isRefreshing = false,
    this.isMutating = false,
    this.errorMessage,
  });

  const StarterPackState.initial() : this._(status: StarterPackStatus.initial);

  const StarterPackState.loading({AtUri? packUri}) : this._(status: StarterPackStatus.loading, packUri: packUri);

  const StarterPackState.loaded({
    required AtUri packUri,
    required StarterPackView starterPack,
    bool isRefreshing = false,
    bool isMutating = false,
    String? errorMessage,
  }) : this._(
         status: StarterPackStatus.loaded,
         packUri: packUri,
         starterPack: starterPack,
         isRefreshing: isRefreshing,
         isMutating: isMutating,
         errorMessage: errorMessage,
       );

  const StarterPackState.error({required String message, AtUri? packUri})
    : this._(status: StarterPackStatus.error, packUri: packUri, errorMessage: message);

  const StarterPackState.deleted() : this._(status: StarterPackStatus.deleted);

  final StarterPackStatus status;
  final AtUri? packUri;
  final StarterPackView? starterPack;
  final bool isRefreshing;
  final bool isMutating;
  final String? errorMessage;

  bool get isLoading => status == StarterPackStatus.loading;
  bool get hasError => status == StarterPackStatus.error || errorMessage != null;

  StarterPackState copyWith({
    StarterPackStatus? status,
    Object? packUri = _starterPackNoValue,
    Object? starterPack = _starterPackNoValue,
    bool? isRefreshing,
    bool? isMutating,
    Object? errorMessage = _starterPackNoValue,
  }) {
    return StarterPackState._(
      status: status ?? this.status,
      packUri: packUri == _starterPackNoValue ? this.packUri : packUri as AtUri?,
      starterPack: starterPack == _starterPackNoValue ? this.starterPack : starterPack as StarterPackView?,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: errorMessage == _starterPackNoValue ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, packUri, starterPack, isRefreshing, isMutating, errorMessage];
}

const _starterPackNoValue = Object();
