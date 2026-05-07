import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fuzzywuzzy;
import 'package:lazurite/features/profile/data/profile_repository.dart';

enum ProfileConnectionsTab { following, followers }

extension ProfileConnectionsTabX on ProfileConnectionsTab {
  String get routeValue => switch (this) {
    ProfileConnectionsTab.following => 'following',
    ProfileConnectionsTab.followers => 'followers',
  };

  String get title => switch (this) {
    ProfileConnectionsTab.following => 'Following',
    ProfileConnectionsTab.followers => 'Followers',
  };

  static ProfileConnectionsTab fromRouteValue(String? value) {
    return value == ProfileConnectionsTab.followers.routeValue
        ? ProfileConnectionsTab.followers
        : ProfileConnectionsTab.following;
  }
}

enum ProfileConnectionsStatus { initial, loading, loaded, error }

const _profileConnectionsNoValue = Object();

class ProfileConnectionsCubit extends Cubit<ProfileConnectionsState> {
  ProfileConnectionsCubit({required ProfileRepository repository, required String actor})
    : _repository = repository,
      _actor = actor,
      super(const ProfileConnectionsState());

  final ProfileRepository _repository;
  final String _actor;
  static const _pageLimit = 50;

  Future<void> loadTab(ProfileConnectionsTab tab, {bool force = false}) async {
    final data = state.dataFor(tab);
    if (!force && (data.status == ProfileConnectionsStatus.loading || data.status == ProfileConnectionsStatus.loaded)) {
      return;
    }

    emit(state.copyWithTab(tab, data.copyWith(status: ProfileConnectionsStatus.loading, errorMessage: null)));

    try {
      final page = await _fetch(tab);
      emit(
        state.copyWithTab(
          tab,
          data.copyWith(
            status: ProfileConnectionsStatus.loaded,
            profiles: page.profiles,
            cursor: page.cursor,
            subject: page.subject,
            errorMessage: null,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWithTab(
          tab,
          data.copyWith(status: ProfileConnectionsStatus.error, errorMessage: 'Failed to load ${tab.title}: $error'),
        ),
      );
    }
  }

  Future<void> refreshTab(ProfileConnectionsTab tab) async {
    emit(state.copyWithTab(tab, state.dataFor(tab).copyWith(cursor: null, profiles: const [])));
    await loadTab(tab, force: true);
  }

  Future<void> loadMore(ProfileConnectionsTab tab) async {
    final data = state.dataFor(tab);
    if (data.cursor == null || data.isLoadingMore || data.status != ProfileConnectionsStatus.loaded) {
      return;
    }

    emit(state.copyWithTab(tab, data.copyWith(isLoadingMore: true, errorMessage: null)));

    try {
      final page = await _fetch(tab, cursor: data.cursor);
      emit(
        state.copyWithTab(
          tab,
          data.copyWith(
            profiles: [...data.profiles, ...page.profiles],
            cursor: page.cursor,
            subject: page.subject,
            isLoadingMore: false,
            errorMessage: null,
          ),
        ),
      );
    } catch (error) {
      emit(state.copyWithTab(tab, data.copyWith(isLoadingMore: false, errorMessage: 'Failed to load more: $error')));
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query.trim()));
  }

  Future<ProfileConnectionsPage> _fetch(ProfileConnectionsTab tab, {String? cursor}) {
    return switch (tab) {
      ProfileConnectionsTab.following => _repository.getFollowing(actor: _actor, cursor: cursor, limit: _pageLimit),
      ProfileConnectionsTab.followers => _repository.getFollowers(actor: _actor, cursor: cursor, limit: _pageLimit),
    };
  }
}

class ProfileConnectionsState extends Equatable {
  const ProfileConnectionsState({
    this.following = const ProfileConnectionsTabData(),
    this.followers = const ProfileConnectionsTabData(),
    this.searchQuery = '',
  });

  final ProfileConnectionsTabData following;
  final ProfileConnectionsTabData followers;
  final String searchQuery;

  ProfileConnectionsTabData dataFor(ProfileConnectionsTab tab) => switch (tab) {
    ProfileConnectionsTab.following => following,
    ProfileConnectionsTab.followers => followers,
  };

  List<ProfileView> visibleProfilesFor(ProfileConnectionsTab tab) {
    final profiles = dataFor(tab).profiles;
    if (searchQuery.isEmpty) {
      return profiles;
    }

    return fuzzywuzzy
        .extractAllSorted<ProfileView>(query: searchQuery, choices: profiles, cutoff: 60, getter: _searchTextForProfile)
        .map((result) => result.choice)
        .toList(growable: false);
  }

  ProfileConnectionsState copyWith({
    ProfileConnectionsTabData? following,
    ProfileConnectionsTabData? followers,
    String? searchQuery,
  }) {
    return ProfileConnectionsState(
      following: following ?? this.following,
      followers: followers ?? this.followers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  ProfileConnectionsState copyWithTab(ProfileConnectionsTab tab, ProfileConnectionsTabData data) {
    return switch (tab) {
      ProfileConnectionsTab.following => copyWith(following: data),
      ProfileConnectionsTab.followers => copyWith(followers: data),
    };
  }

  static String _searchTextForProfile(ProfileView profile) {
    return [
      profile.handle,
      profile.displayName,
      profile.description,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');
  }

  @override
  List<Object?> get props => [following, followers, searchQuery];
}

class ProfileConnectionsTabData extends Equatable {
  const ProfileConnectionsTabData({
    this.status = ProfileConnectionsStatus.initial,
    this.profiles = const [],
    this.cursor,
    this.subject,
    this.errorMessage,
    this.isLoadingMore = false,
  });

  final ProfileConnectionsStatus status;
  final List<ProfileView> profiles;
  final String? cursor;
  final ProfileView? subject;
  final String? errorMessage;
  final bool isLoadingMore;

  bool get isLoading => status == ProfileConnectionsStatus.loading;
  bool get hasError => status == ProfileConnectionsStatus.error;
  bool get hasMore => cursor != null;

  ProfileConnectionsTabData copyWith({
    ProfileConnectionsStatus? status,
    List<ProfileView>? profiles,
    Object? cursor = _profileConnectionsNoValue,
    Object? subject = _profileConnectionsNoValue,
    Object? errorMessage = _profileConnectionsNoValue,
    bool? isLoadingMore,
  }) {
    return ProfileConnectionsTabData(
      status: status ?? this.status,
      profiles: profiles ?? this.profiles,
      cursor: identical(cursor, _profileConnectionsNoValue) ? this.cursor : cursor as String?,
      subject: identical(subject, _profileConnectionsNoValue) ? this.subject : subject as ProfileView?,
      errorMessage: identical(errorMessage, _profileConnectionsNoValue) ? this.errorMessage : errorMessage as String?,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [status, profiles, cursor, subject, errorMessage, isLoadingMore];
}
