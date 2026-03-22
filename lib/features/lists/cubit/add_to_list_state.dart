part of 'add_to_list_cubit.dart';

enum AddToListStatus { initial, loading, loaded, error }

class AddToListState extends Equatable {
  const AddToListState._({
    required this.status,
    this.targetDid,
    this.lists = const [],
    this.togglingUris = const {},
    this.errorMessage,
  });

  const AddToListState.initial() : this._(status: AddToListStatus.initial);

  const AddToListState.loading({required String targetDid})
    : this._(status: AddToListStatus.loading, targetDid: targetDid);

  const AddToListState.loaded({required String targetDid, required List<ListWithMembership> lists})
    : this._(status: AddToListStatus.loaded, targetDid: targetDid, lists: lists);

  const AddToListState.error({required String message, String? targetDid})
    : this._(status: AddToListStatus.error, targetDid: targetDid, errorMessage: message);

  final AddToListStatus status;
  final String? targetDid;
  final List<ListWithMembership> lists;
  final Set<String> togglingUris;
  final String? errorMessage;

  AddToListState copyWith({
    AddToListStatus? status,
    String? targetDid,
    List<ListWithMembership>? lists,
    Set<String>? togglingUris,
    String? errorMessage,
  }) {
    return AddToListState._(
      status: status ?? this.status,
      targetDid: targetDid ?? this.targetDid,
      lists: lists ?? this.lists,
      togglingUris: togglingUris ?? this.togglingUris,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, targetDid, lists, togglingUris, errorMessage];
}
