part of 'group_details_cubit.dart';

enum GroupDetailsStatus { initial, loading, loaded, error }

const _groupDetailsNoValue = Object();

class GroupDetailsState extends Equatable {
  const GroupDetailsState({
    this.status = GroupDetailsStatus.initial,
    this.convo,
    this.members = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isLoadingJoinRequests = false,
    this.isMutating = false,
    this.leaveSucceeded = false,
    this.joinRequests = const [],
    this.joinRequestsCursor,
    this.hasMoreJoinRequests = false,
    this.errorMessage,
  });

  final GroupDetailsStatus status;
  final ConvoView? convo;
  final List<ProfileViewBasic> members;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isLoadingJoinRequests;
  final bool isMutating;
  final bool leaveSucceeded;
  final List<JoinRequestView> joinRequests;
  final String? joinRequestsCursor;
  final bool hasMoreJoinRequests;
  final String? errorMessage;

  GroupConvo? get group => convo?.kind?.groupConvo;

  bool canManage(String currentUserDid) {
    final viewer = members.where((member) => member.did == currentUserDid).firstOrNull;
    final role = viewer?.kind?.groupConvoMember?.role.knownValue;
    return role == KnownMemberRole.owner;
  }

  GroupDetailsState copyWith({
    GroupDetailsStatus? status,
    Object? convo = _groupDetailsNoValue,
    List<ProfileViewBasic>? members,
    Object? cursor = _groupDetailsNoValue,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isLoadingJoinRequests,
    bool? isMutating,
    bool? leaveSucceeded,
    List<JoinRequestView>? joinRequests,
    Object? joinRequestsCursor = _groupDetailsNoValue,
    bool? hasMoreJoinRequests,
    Object? errorMessage = _groupDetailsNoValue,
  }) {
    return GroupDetailsState(
      status: status ?? this.status,
      convo: identical(convo, _groupDetailsNoValue) ? this.convo : convo as ConvoView?,
      members: members ?? this.members,
      cursor: identical(cursor, _groupDetailsNoValue) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingJoinRequests: isLoadingJoinRequests ?? this.isLoadingJoinRequests,
      isMutating: isMutating ?? this.isMutating,
      leaveSucceeded: leaveSucceeded ?? this.leaveSucceeded,
      joinRequests: joinRequests ?? this.joinRequests,
      joinRequestsCursor: identical(joinRequestsCursor, _groupDetailsNoValue)
          ? this.joinRequestsCursor
          : joinRequestsCursor as String?,
      hasMoreJoinRequests: hasMoreJoinRequests ?? this.hasMoreJoinRequests,
      errorMessage: identical(errorMessage, _groupDetailsNoValue) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    convo,
    members,
    cursor,
    hasMore,
    isLoadingMore,
    isLoadingJoinRequests,
    isMutating,
    leaveSucceeded,
    joinRequests,
    joinRequestsCursor,
    hasMoreJoinRequests,
    errorMessage,
  ];
}
