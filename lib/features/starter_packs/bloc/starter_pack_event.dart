part of 'starter_pack_bloc.dart';

sealed class StarterPackEvent extends Equatable {
  const StarterPackEvent();

  @override
  List<Object?> get props => [];
}

final class StarterPackRequested extends StarterPackEvent {
  const StarterPackRequested({required this.starterPackUri});

  final AtUri starterPackUri;

  @override
  List<Object?> get props => [starterPackUri];
}

final class StarterPackCreated extends StarterPackEvent {
  const StarterPackCreated({
    required this.userDid,
    required this.name,
    this.description,
    this.memberDids = const [],
    this.feedUris = const [],
  });

  final String userDid;
  final String name;
  final String? description;
  final List<String> memberDids;
  final List<AtUri> feedUris;

  @override
  List<Object?> get props => [userDid, name, description, memberDids, feedUris];
}

final class StarterPackUpdated extends StarterPackEvent {
  const StarterPackUpdated({required this.name, this.description, this.feedUris = const []});

  final String name;
  final String? description;
  final List<AtUri> feedUris;

  @override
  List<Object?> get props => [name, description, feedUris];
}

final class StarterPackDeleted extends StarterPackEvent {
  const StarterPackDeleted({required this.userDid});

  final String userDid;

  @override
  List<Object?> get props => [userDid];
}

final class MemberAdded extends StarterPackEvent {
  const MemberAdded({required this.subjectDid});

  final String subjectDid;

  @override
  List<Object?> get props => [subjectDid];
}

final class MemberRemoved extends StarterPackEvent {
  const MemberRemoved({required this.listItemUri});

  final AtUri listItemUri;

  @override
  List<Object?> get props => [listItemUri];
}
