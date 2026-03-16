part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, error }

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
    ProfileViewDetailed? profile,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return ProfileState._(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage, isRefreshing];
}
