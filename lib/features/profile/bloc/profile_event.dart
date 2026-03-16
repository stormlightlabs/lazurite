part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested({required this.actor});
  final String actor;

  @override
  List<Object?> get props => [actor];
}

class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}
