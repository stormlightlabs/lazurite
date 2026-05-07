import 'dart:async';

import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fuzzywuzzy;
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';

enum ProfileConnectionsTab { following, followers, mutuals }

extension ProfileConnectionsTabX on ProfileConnectionsTab {
  String get routeValue => switch (this) {
    ProfileConnectionsTab.following => 'following',
    ProfileConnectionsTab.followers => 'followers',
    ProfileConnectionsTab.mutuals => 'mutuals',
  };

  String get title => switch (this) {
    ProfileConnectionsTab.following => 'Following',
    ProfileConnectionsTab.followers => 'Followers',
    ProfileConnectionsTab.mutuals => 'Mutuals',
  };

  static ProfileConnectionsTab fromRouteValue(String? value) {
    return switch (value) {
      'followers' => ProfileConnectionsTab.followers,
      'mutuals' => ProfileConnectionsTab.mutuals,
      _ => ProfileConnectionsTab.following,
    };
  }
}

enum ProfileConnectionsStatus { initial, loading, loaded, error }

enum ProfileConnectionsSearchStatus { idle, searching, complete, error }

const _profileConnectionsNoValue = Object();

class ProfileConnectionsCubit extends Cubit<ProfileConnectionsState> {
  ProfileConnectionsCubit({
    required ProfileRepository repository,
    required String actor,
    ConstellationClient? constellationClient,
  }) : _repository = repository,
       _constellationClient = constellationClient,
       _actor = actor,
       super(const ProfileConnectionsState());

  final ProfileRepository _repository;
  final ConstellationClient? _constellationClient;
  final String _actor;
  final Map<ProfileConnectionsTab, int> _searchGenerations = {
    ProfileConnectionsTab.following: 0,
    ProfileConnectionsTab.followers: 0,
    ProfileConnectionsTab.mutuals: 0,
  };
  Timer? _searchDebounce;
  static const _pageLimit = 100;
  static const _searchDebounceDuration = Duration(milliseconds: 300);
  static const _searchCutoff = 60;
  static const _maxSearchResults = 100;
  static const _mutualCandidateBatchSize = 50;
  static const _followSource = 'app.bsky.graph.follow:subject';

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    for (final tab in ProfileConnectionsTab.values) {
      _cancelSearch(tab);
    }
    return super.close();
  }

  Future<void> loadTab(ProfileConnectionsTab tab, {bool force = false}) async {
    final data = state.dataFor(tab);
    if (!force && (data.status == ProfileConnectionsStatus.loading || data.status == ProfileConnectionsStatus.loaded)) {
      return;
    }

    emit(
      state.copyWithTab(
        tab,
        data.copyWith(status: ProfileConnectionsStatus.loading, errorMessage: null, loadMoreErrorMessage: null),
      ),
    );

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
            loadMoreErrorMessage: null,
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
    ensureSearchForTab(tab, force: true);
  }

  Future<void> loadMore(ProfileConnectionsTab tab) async {
    final data = state.dataFor(tab);
    if (data.cursor == null || data.isLoadingMore || data.status != ProfileConnectionsStatus.loaded) {
      return;
    }

    emit(state.copyWithTab(tab, data.copyWith(isLoadingMore: true, loadMoreErrorMessage: null)));

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
            loadMoreErrorMessage: null,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWithTab(
          tab,
          data.copyWith(isLoadingMore: false, loadMoreErrorMessage: 'Failed to load more: $error'),
        ),
      );
    }
  }

  void setSearchQuery(String query, ProfileConnectionsTab activeTab) {
    final normalizedQuery = query.trim();
    _searchDebounce?.cancel();

    if (normalizedQuery != state.searchQuery) {
      for (final tab in ProfileConnectionsTab.values) {
        _cancelSearch(tab);
      }
      emit(
        state.copyWith(
          searchQuery: normalizedQuery,
          following: state.following.clearSearch(),
          followers: state.followers.clearSearch(),
          mutuals: state.mutuals.clearSearch(),
        ),
      );
    }

    if (normalizedQuery.isEmpty) {
      return;
    }

    _searchDebounce = Timer(_searchDebounceDuration, () {
      ensureSearchForTab(activeTab);
    });
  }

  void ensureSearchForTab(ProfileConnectionsTab tab, {bool force = false}) {
    final query = state.searchQuery;
    if (query.isEmpty) {
      return;
    }

    final data = state.dataFor(tab);
    if (!force &&
        data.searchQuery == query &&
        (data.searchStatus == ProfileConnectionsSearchStatus.searching ||
            data.searchStatus == ProfileConnectionsSearchStatus.complete)) {
      return;
    }

    unawaited(_searchFullList(tab, query));
  }

  Future<ProfileConnectionsPage> _fetch(ProfileConnectionsTab tab, {String? cursor}) {
    return switch (tab) {
      ProfileConnectionsTab.following => _repository.getFollowing(actor: _actor, cursor: cursor, limit: _pageLimit),
      ProfileConnectionsTab.followers => _repository.getFollowers(actor: _actor, cursor: cursor, limit: _pageLimit),
      ProfileConnectionsTab.mutuals => _getMutuals(cursor: cursor),
    };
  }

  Future<ProfileConnectionsPage> _getMutuals({String? cursor}) async {
    final constellationClient = _constellationClient;
    if (constellationClient == null) {
      throw StateError('Constellation client is required to load mutual follows.');
    }

    final mutualProfiles = <ProfileView>[];
    late ProfileView subject;
    String? nextCursor = cursor;

    do {
      final followsPage = await _repository.getFollowing(actor: _actor, cursor: nextCursor, limit: _pageLimit);
      subject = followsPage.subject;
      nextCursor = followsPage.cursor;

      final candidatesByDid = {for (final profile in followsPage.profiles) profile.did: profile};
      if (candidatesByDid.isEmpty) {
        continue;
      }

      final mutualDids = await _getMutualDids(
        constellationClient: constellationClient,
        subjectDid: followsPage.subject.did,
        candidateDids: candidatesByDid.keys.toList(growable: false),
      );
      for (final did in mutualDids) {
        final profile = candidatesByDid[did];
        if (profile != null) {
          mutualProfiles.add(profile);
        }
      }
    } while (mutualProfiles.isEmpty && nextCursor != null);

    return ProfileConnectionsPage(subject: subject, profiles: mutualProfiles, cursor: nextCursor);
  }

  Future<Set<String>> _getMutualDids({
    required ConstellationClient constellationClient,
    required String subjectDid,
    required List<String> candidateDids,
  }) async {
    final mutualDids = <String>{};
    for (var i = 0; i < candidateDids.length; i += _mutualCandidateBatchSize) {
      final batch = candidateDids.sublist(i, (i + _mutualCandidateBatchSize).clamp(0, candidateDids.length));
      String? cursor;
      do {
        final result = await constellationClient.getBacklinks(
          subjectDid,
          _followSource,
          limit: _pageLimit,
          cursor: cursor,
          dids: batch,
        );
        mutualDids.addAll(result.records.map((record) => record.did));
        cursor = result.cursor;
      } while (cursor != null);
    }
    return mutualDids;
  }

  Future<void> _searchFullList(ProfileConnectionsTab tab, String query) async {
    final generation = _nextSearchGeneration(tab);
    final matchesByDid = <String, _ProfileSearchMatch>{};
    var searchedCount = 0;
    String? cursor;

    emit(
      state.copyWithTab(
        tab,
        state
            .dataFor(tab)
            .copyWith(
              searchStatus: ProfileConnectionsSearchStatus.searching,
              searchQuery: query,
              searchResults: const [],
              searchedCount: 0,
              searchErrorMessage: null,
            ),
      ),
    );

    try {
      while (true) {
        if (!_isCurrentSearch(tab, generation, query)) {
          return;
        }

        final page = await _fetch(tab, cursor: cursor);
        if (!_isCurrentSearch(tab, generation, query)) {
          return;
        }

        searchedCount += page.profiles.length;
        _mergeSearchMatches(query, matchesByDid, page.profiles);
        final topMatches = _topSearchResults(matchesByDid);
        final currentData = state.dataFor(tab);
        emit(
          state.copyWithTab(
            tab,
            currentData.copyWith(
              status: currentData.status == ProfileConnectionsStatus.initial
                  ? ProfileConnectionsStatus.loaded
                  : currentData.status,
              subject: page.subject,
              searchStatus: ProfileConnectionsSearchStatus.searching,
              searchQuery: query,
              searchResults: topMatches,
              searchedCount: searchedCount,
              searchErrorMessage: null,
            ),
          ),
        );

        cursor = page.cursor;
        if (cursor == null) {
          break;
        }
        await Future<void>.delayed(Duration.zero);
      }

      if (!_isCurrentSearch(tab, generation, query)) {
        return;
      }

      emit(
        state.copyWithTab(
          tab,
          state
              .dataFor(tab)
              .copyWith(
                searchStatus: ProfileConnectionsSearchStatus.complete,
                searchQuery: query,
                searchedCount: searchedCount,
                searchErrorMessage: null,
              ),
        ),
      );
    } catch (error) {
      if (!_isCurrentSearch(tab, generation, query)) {
        return;
      }
      emit(
        state.copyWithTab(
          tab,
          state
              .dataFor(tab)
              .copyWith(
                searchStatus: ProfileConnectionsSearchStatus.error,
                searchQuery: query,
                searchedCount: searchedCount,
                searchErrorMessage: 'Search stopped: $error',
              ),
        ),
      );
    }
  }

  int _nextSearchGeneration(ProfileConnectionsTab tab) {
    final next = (_searchGenerations[tab] ?? 0) + 1;
    _searchGenerations[tab] = next;
    return next;
  }

  void _cancelSearch(ProfileConnectionsTab tab) {
    _searchGenerations[tab] = (_searchGenerations[tab] ?? 0) + 1;
  }

  bool _isCurrentSearch(ProfileConnectionsTab tab, int generation, String query) {
    return !isClosed && _searchGenerations[tab] == generation && state.searchQuery == query;
  }

  void _mergeSearchMatches(String query, Map<String, _ProfileSearchMatch> matchesByDid, List<ProfileView> profiles) {
    for (final profile in profiles) {
      final score = fuzzywuzzy.weightedRatio(query, ProfileConnectionsState.searchTextForProfile(profile));
      if (score < _searchCutoff) {
        continue;
      }

      final existing = matchesByDid[profile.did];
      if (existing == null || score > existing.score) {
        matchesByDid[profile.did] = _ProfileSearchMatch(profile: profile, score: score);
      }
    }

    final ranked = matchesByDid.values.toList()..sort(_compareSearchMatches);
    if (ranked.length <= _maxSearchResults) {
      return;
    }

    matchesByDid
      ..clear()
      ..addEntries(ranked.take(_maxSearchResults).map((match) => MapEntry(match.profile.did, match)));
  }

  List<ProfileView> _topSearchResults(Map<String, _ProfileSearchMatch> matchesByDid) {
    final ranked = matchesByDid.values.toList()..sort(_compareSearchMatches);
    return ranked.map((match) => match.profile).toList(growable: false);
  }

  int _compareSearchMatches(_ProfileSearchMatch a, _ProfileSearchMatch b) {
    final scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) {
      return scoreCompare;
    }
    return a.profile.handle.compareTo(b.profile.handle);
  }
}

class _ProfileSearchMatch {
  const _ProfileSearchMatch({required this.profile, required this.score});

  final ProfileView profile;
  final int score;
}

class ProfileConnectionsState extends Equatable {
  const ProfileConnectionsState({
    this.following = const ProfileConnectionsTabData(),
    this.followers = const ProfileConnectionsTabData(),
    this.mutuals = const ProfileConnectionsTabData(),
    this.searchQuery = '',
  });

  final ProfileConnectionsTabData following;
  final ProfileConnectionsTabData followers;
  final ProfileConnectionsTabData mutuals;
  final String searchQuery;

  ProfileConnectionsTabData dataFor(ProfileConnectionsTab tab) => switch (tab) {
    ProfileConnectionsTab.following => following,
    ProfileConnectionsTab.followers => followers,
    ProfileConnectionsTab.mutuals => mutuals,
  };

  List<ProfileView> visibleProfilesFor(ProfileConnectionsTab tab) {
    if (searchQuery.isEmpty) {
      return dataFor(tab).profiles;
    }

    final data = dataFor(tab);
    if (data.searchQuery != searchQuery) {
      return const [];
    }
    return data.searchResults;
  }

  ProfileConnectionsState copyWith({
    ProfileConnectionsTabData? following,
    ProfileConnectionsTabData? followers,
    ProfileConnectionsTabData? mutuals,
    String? searchQuery,
  }) {
    return ProfileConnectionsState(
      following: following ?? this.following,
      followers: followers ?? this.followers,
      mutuals: mutuals ?? this.mutuals,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  ProfileConnectionsState copyWithTab(ProfileConnectionsTab tab, ProfileConnectionsTabData data) {
    return switch (tab) {
      ProfileConnectionsTab.following => copyWith(following: data),
      ProfileConnectionsTab.followers => copyWith(followers: data),
      ProfileConnectionsTab.mutuals => copyWith(mutuals: data),
    };
  }

  static String searchTextForProfile(ProfileView profile) {
    return [
      profile.handle,
      profile.displayName,
      profile.description,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');
  }

  @override
  List<Object?> get props => [following, followers, mutuals, searchQuery];
}

class ProfileConnectionsTabData extends Equatable {
  const ProfileConnectionsTabData({
    this.status = ProfileConnectionsStatus.initial,
    this.profiles = const [],
    this.cursor,
    this.subject,
    this.errorMessage,
    this.loadMoreErrorMessage,
    this.isLoadingMore = false,
    this.searchStatus = ProfileConnectionsSearchStatus.idle,
    this.searchQuery = '',
    this.searchResults = const [],
    this.searchedCount = 0,
    this.searchErrorMessage,
  });

  final ProfileConnectionsStatus status;
  final List<ProfileView> profiles;
  final String? cursor;
  final ProfileView? subject;
  final String? errorMessage;
  final String? loadMoreErrorMessage;
  final bool isLoadingMore;
  final ProfileConnectionsSearchStatus searchStatus;
  final String searchQuery;
  final List<ProfileView> searchResults;
  final int searchedCount;
  final String? searchErrorMessage;

  bool get isLoading => status == ProfileConnectionsStatus.loading;
  bool get hasError => status == ProfileConnectionsStatus.error;
  bool get hasMore => cursor != null;
  bool get isSearching => searchStatus == ProfileConnectionsSearchStatus.searching;
  bool get hasActiveSearch => searchQuery.isNotEmpty;

  ProfileConnectionsTabData clearSearch() {
    return copyWith(
      searchStatus: ProfileConnectionsSearchStatus.idle,
      searchQuery: '',
      searchResults: const [],
      searchedCount: 0,
      searchErrorMessage: null,
    );
  }

  ProfileConnectionsTabData copyWith({
    ProfileConnectionsStatus? status,
    List<ProfileView>? profiles,
    Object? cursor = _profileConnectionsNoValue,
    Object? subject = _profileConnectionsNoValue,
    Object? errorMessage = _profileConnectionsNoValue,
    Object? loadMoreErrorMessage = _profileConnectionsNoValue,
    bool? isLoadingMore,
    ProfileConnectionsSearchStatus? searchStatus,
    String? searchQuery,
    List<ProfileView>? searchResults,
    int? searchedCount,
    Object? searchErrorMessage = _profileConnectionsNoValue,
  }) {
    return ProfileConnectionsTabData(
      status: status ?? this.status,
      profiles: profiles ?? this.profiles,
      cursor: identical(cursor, _profileConnectionsNoValue) ? this.cursor : cursor as String?,
      subject: identical(subject, _profileConnectionsNoValue) ? this.subject : subject as ProfileView?,
      errorMessage: identical(errorMessage, _profileConnectionsNoValue) ? this.errorMessage : errorMessage as String?,
      loadMoreErrorMessage: identical(loadMoreErrorMessage, _profileConnectionsNoValue)
          ? this.loadMoreErrorMessage
          : loadMoreErrorMessage as String?,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchStatus: searchStatus ?? this.searchStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      searchedCount: searchedCount ?? this.searchedCount,
      searchErrorMessage: identical(searchErrorMessage, _profileConnectionsNoValue)
          ? this.searchErrorMessage
          : searchErrorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profiles,
    cursor,
    subject,
    errorMessage,
    loadMoreErrorMessage,
    isLoadingMore,
    searchStatus,
    searchQuery,
    searchResults,
    searchedCount,
    searchErrorMessage,
  ];
}
