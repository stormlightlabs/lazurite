import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';

const String homeFeedPreferenceId = 'home';

enum AccountSettingsStatus { initial, loading, loaded, saving, error, saveError }

class AccountSettingsState extends Equatable {
  const AccountSettingsState._({
    required this.status,
    required this.feed,
    required this.feedDisplayName,
    this.feedViewPref,
    this.message,
  });

  const AccountSettingsState.initial({required String feed, required String feedDisplayName})
    : this._(status: AccountSettingsStatus.initial, feed: feed, feedDisplayName: feedDisplayName);

  final AccountSettingsStatus status;
  final String feed;
  final String feedDisplayName;
  final FeedViewPref? feedViewPref;
  final String? message;

  bool get isBusy => status == AccountSettingsStatus.loading || status == AccountSettingsStatus.saving;

  AccountSettingsState copyWith({
    AccountSettingsStatus? status,
    FeedViewPref? feedViewPref,
    String? message,
    bool clearMessage = false,
  }) {
    return AccountSettingsState._(
      status: status ?? this.status,
      feed: feed,
      feedDisplayName: feedDisplayName,
      feedViewPref: feedViewPref ?? this.feedViewPref,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, feed, feedDisplayName, feedViewPref, message];
}

class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  AccountSettingsCubit({required FeedRepository feedRepository, required String feed, required String feedDisplayName})
    : _feedRepository = feedRepository,
      super(AccountSettingsState.initial(feed: feed, feedDisplayName: feedDisplayName));

  final FeedRepository _feedRepository;

  Future<void> loadPreferences() async {
    _safeEmit(state.copyWith(status: AccountSettingsStatus.loading, clearMessage: true));

    try {
      final result = await _feedRepository.getPreferences();
      final feedViewPref = _feedViewPrefFrom(result.preferences) ?? FeedViewPref(feed: state.feed);
      _safeEmit(state.copyWith(status: AccountSettingsStatus.loaded, feedViewPref: feedViewPref, clearMessage: true));
    } catch (error, stackTrace) {
      log.e(
        'AccountSettingsCubit: Failed to load feed display preferences for ${state.feed}',
        error: error,
        stackTrace: stackTrace,
      );
      _safeEmit(
        state.copyWith(
          status: AccountSettingsStatus.error,
          feedViewPref: state.feedViewPref ?? FeedViewPref(feed: state.feed),
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> setHideReplies(bool value) => _updatePreference((pref) => pref.copyWith(hideReplies: value));

  Future<void> setHideRepliesByUnfollowed(bool value) =>
      _updatePreference((pref) => pref.copyWith(hideRepliesByUnfollowed: value));

  Future<void> setHideRepliesByLikeCount(int? value) =>
      _updatePreference((pref) => pref.copyWith(hideRepliesByLikeCount: value));

  Future<void> setHideReposts(bool value) => _updatePreference((pref) => pref.copyWith(hideReposts: value));

  Future<void> setHideQuotePosts(bool value) => _updatePreference((pref) => pref.copyWith(hideQuotePosts: value));

  Future<void> _updatePreference(FeedViewPref Function(FeedViewPref current) update) async {
    final current = state.feedViewPref ?? FeedViewPref(feed: state.feed);
    final updated = update(current);
    _safeEmit(state.copyWith(status: AccountSettingsStatus.saving, feedViewPref: updated, clearMessage: true));

    try {
      final result = await _feedRepository.getPreferences();
      final preferences = _replaceFeedViewPref(result.preferences, updated);
      await _feedRepository.putPreferences(preferences: preferences);
      _safeEmit(state.copyWith(status: AccountSettingsStatus.loaded, feedViewPref: updated, clearMessage: true));
    } catch (error, stackTrace) {
      log.e(
        'AccountSettingsCubit: Failed to save feed display preferences for ${state.feed}',
        error: error,
        stackTrace: stackTrace,
      );
      _safeEmit(
        state.copyWith(status: AccountSettingsStatus.saveError, feedViewPref: updated, message: error.toString()),
      );
    }
  }

  FeedViewPref? _feedViewPrefFrom(List<UPreferences> preferences) {
    for (final preference in preferences) {
      final feedViewPref = preference.feedViewPref;
      if (feedViewPref != null && feedViewPref.feed == state.feed) {
        return feedViewPref;
      }
    }
    return null;
  }

  List<UPreferences> _replaceFeedViewPref(List<UPreferences> preferences, FeedViewPref updated) {
    return [
      for (final preference in preferences)
        if (preference.feedViewPref?.feed != updated.feed) preference,
      UPreferences.feedViewPref(data: updated),
    ];
  }

  void _safeEmit(AccountSettingsState nextState) {
    if (isClosed) {
      return;
    }
    emit(nextState);
  }
}
