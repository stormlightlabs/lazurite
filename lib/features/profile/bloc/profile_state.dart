part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, error }

const _profileStateNoValue = Object();

class ProfileState extends Equatable {
  const ProfileState._({required this.status, this.profile, this.errorMessage, this.isRefreshing = false});

  const ProfileState.initial() : this._(status: ProfileStatus.initial);

  const ProfileState.loading() : this._(status: ProfileStatus.loading);

  const ProfileState.loaded({required ProfileViewDetailed profile})
    : this._(status: ProfileStatus.loaded, profile: profile);

  const ProfileState.error(String message) : this._(status: ProfileStatus.error, errorMessage: message);

  final ProfileStatus status;
  final ProfileViewDetailed? profile;
  final String? errorMessage;
  final bool isRefreshing;

  bool get isLoading => status == ProfileStatus.loading;
  bool get hasError => status == ProfileStatus.error;
  bool get hasProfile => profile != null;

  ProfileState copyWith({
    ProfileStatus? status,
    Object? profile = _profileStateNoValue,
    Object? errorMessage = _profileStateNoValue,
    bool? isRefreshing,
  }) => ProfileState._(
    status: status ?? this.status,
    profile: identical(profile, _profileStateNoValue) ? this.profile : profile as ProfileViewDetailed?,
    errorMessage: identical(errorMessage, _profileStateNoValue) ? this.errorMessage : errorMessage as String?,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );

  @override
  List<Object?> get props => [status, profile, errorMessage, isRefreshing];
}
