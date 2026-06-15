part of 'group_create_cubit.dart';

enum GroupCreateStatus { editing, submitting, success, failure }

const _groupCreateStateNoValue = Object();

class GroupCreateMember extends Equatable {
  const GroupCreateMember({required this.did, required this.handle, this.displayName, this.avatar});

  factory GroupCreateMember.fromProfile(app_actor.ProfileViewBasic profile) {
    return GroupCreateMember(
      did: profile.did,
      handle: profile.handle,
      displayName: profile.displayName,
      avatar: profile.avatar,
    );
  }

  final String did;
  final String handle;
  final String? displayName;
  final String? avatar;

  String get label => displayName?.trim().isNotEmpty == true ? displayName! : handle;

  @override
  List<Object?> get props => [did, handle, displayName, avatar];
}

class GroupCreateState extends Equatable {
  const GroupCreateState({
    this.status = GroupCreateStatus.editing,
    this.name = '',
    this.members = const [],
    this.createdConvo,
    this.errorMessage,
  });

  final GroupCreateStatus status;
  final String name;
  final List<GroupCreateMember> members;
  final ConvoView? createdConvo;
  final String? errorMessage;

  String get trimmedName => name.trim();
  int get nameGraphemeCount => trimmedName.characters.length;
  bool get isSubmitting => status == GroupCreateStatus.submitting;

  String? get validationError {
    if (trimmedName.isEmpty) {
      return 'Add a group name.';
    }
    if (nameGraphemeCount > GroupCreateCubit.maxNameGraphemes) {
      return 'Group names can be up to 50 characters.';
    }
    if (members.isEmpty) {
      return 'Add at least one member.';
    }
    if (members.length > GroupCreateCubit.maxMembers) {
      return 'Groups can include up to 49 invited members.';
    }
    return null;
  }

  bool get canCreate => !isSubmitting && validationError == null;

  GroupCreateState copyWith({
    GroupCreateStatus? status,
    String? name,
    List<GroupCreateMember>? members,
    Object? createdConvo = _groupCreateStateNoValue,
    Object? errorMessage = _groupCreateStateNoValue,
  }) {
    return GroupCreateState(
      status: status ?? this.status,
      name: name ?? this.name,
      members: members ?? this.members,
      createdConvo: identical(createdConvo, _groupCreateStateNoValue) ? this.createdConvo : createdConvo as ConvoView?,
      errorMessage: identical(errorMessage, _groupCreateStateNoValue) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, name, members, createdConvo, errorMessage];
}
