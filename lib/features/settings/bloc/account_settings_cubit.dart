import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';

const String homeFeedPreferenceId = 'home';

enum AccountSettingsStatus { initial, loading, loaded, saving, error, saveError }

enum BlackskyAiPreferenceCategory { training, inference, syntheticContent, embedding }

enum BlackskyAiPreferenceValue {
  unset,
  allow,
  deny;

  String get label => switch (this) {
    BlackskyAiPreferenceValue.unset => 'Not Set',
    BlackskyAiPreferenceValue.allow => 'Allow',
    BlackskyAiPreferenceValue.deny => 'Deny',
  };

  static String labelFor(BlackskyAiPreferenceValue value) => value.label;
}

class BlackskyAiPreferences extends Equatable {
  const BlackskyAiPreferences({
    this.training = BlackskyAiPreferenceValue.unset,
    this.inference = BlackskyAiPreferenceValue.unset,
    this.syntheticContent = BlackskyAiPreferenceValue.unset,
    this.embedding = BlackskyAiPreferenceValue.unset,
  });

  factory BlackskyAiPreferences.fromRecord(Map<String, dynamic>? record) {
    final preferences = record?['preferences'];
    final preferenceMap = preferences is Map<String, dynamic> ? preferences : const <String, dynamic>{};
    return BlackskyAiPreferences(
      training: _valueFromField(preferenceMap['training']),
      inference: _valueFromField(preferenceMap['inference']),
      syntheticContent: _valueFromField(preferenceMap['syntheticContent']),
      embedding: _valueFromField(preferenceMap['embedding']),
    );
  }

  final BlackskyAiPreferenceValue training;
  final BlackskyAiPreferenceValue inference;
  final BlackskyAiPreferenceValue syntheticContent;
  final BlackskyAiPreferenceValue embedding;

  BlackskyAiPreferences copyWithCategory(BlackskyAiPreferenceCategory category, BlackskyAiPreferenceValue value) {
    return switch (category) {
      BlackskyAiPreferenceCategory.training => copyWith(training: value),
      BlackskyAiPreferenceCategory.inference => copyWith(inference: value),
      BlackskyAiPreferenceCategory.syntheticContent => copyWith(syntheticContent: value),
      BlackskyAiPreferenceCategory.embedding => copyWith(embedding: value),
    };
  }

  BlackskyAiPreferences copyWith({
    BlackskyAiPreferenceValue? training,
    BlackskyAiPreferenceValue? inference,
    BlackskyAiPreferenceValue? syntheticContent,
    BlackskyAiPreferenceValue? embedding,
  }) {
    return BlackskyAiPreferences(
      training: training ?? this.training,
      inference: inference ?? this.inference,
      syntheticContent: syntheticContent ?? this.syntheticContent,
      embedding: embedding ?? this.embedding,
    );
  }

  Map<String, dynamic> toRecord({required DateTime updatedAt}) {
    final timestamp = updatedAt.toUtc().toIso8601String();
    final preferences = <String, dynamic>{};
    _writeField(preferences, 'training', training, timestamp);
    _writeField(preferences, 'inference', inference, timestamp);
    _writeField(preferences, 'syntheticContent', syntheticContent, timestamp);
    _writeField(preferences, 'embedding', embedding, timestamp);

    return {
      r'$type': FeedRepository.blackskyAiPreferenceCollection,
      'updatedAt': timestamp,
      'scope': {r'$type': '${FeedRepository.blackskyAiPreferenceCollection}#globalScope'},
      'preferences': preferences,
    };
  }

  static BlackskyAiPreferenceValue _valueFromField(Object? field) {
    if (field is! Map) {
      return BlackskyAiPreferenceValue.unset;
    }
    return field['allow'] == true ? BlackskyAiPreferenceValue.allow : BlackskyAiPreferenceValue.deny;
  }

  static void _writeField(Map<String, dynamic> target, String key, BlackskyAiPreferenceValue value, String timestamp) {
    switch (value) {
      case BlackskyAiPreferenceValue.unset:
        return;
      case BlackskyAiPreferenceValue.allow:
        target[key] = {'allow': true, 'updatedAt': timestamp};
      case BlackskyAiPreferenceValue.deny:
        target[key] = {'allow': false, 'updatedAt': timestamp};
    }
  }

  @override
  List<Object?> get props => [training, inference, syntheticContent, embedding];
}

class AccountSettingsState extends Equatable {
  const AccountSettingsState._({
    required this.status,
    required this.feed,
    required this.feedDisplayName,
    required this.supportsBlackskyAiPreferences,
    this.feedViewPref,
    this.threadViewPref,
    this.blackskyAiPreferences,
    this.message,
  });

  const AccountSettingsState.initial({
    required String feed,
    required String feedDisplayName,
    bool supportsBlackskyAiPreferences = false,
  }) : this._(
         status: AccountSettingsStatus.initial,
         feed: feed,
         feedDisplayName: feedDisplayName,
         supportsBlackskyAiPreferences: supportsBlackskyAiPreferences,
         threadViewPref: null,
       );

  final AccountSettingsStatus status;
  final String feed;
  final String feedDisplayName;
  final bool supportsBlackskyAiPreferences;
  final FeedViewPref? feedViewPref;
  final ThreadViewPref? threadViewPref;
  final BlackskyAiPreferences? blackskyAiPreferences;
  final String? message;

  bool get isBusy => status == AccountSettingsStatus.loading || status == AccountSettingsStatus.saving;

  AccountSettingsState copyWith({
    AccountSettingsStatus? status,
    FeedViewPref? feedViewPref,
    ThreadViewPref? threadViewPref,
    BlackskyAiPreferences? blackskyAiPreferences,
    String? message,
    bool clearMessage = false,
  }) => AccountSettingsState._(
    status: status ?? this.status,
    feed: feed,
    feedDisplayName: feedDisplayName,
    supportsBlackskyAiPreferences: supportsBlackskyAiPreferences,
    feedViewPref: feedViewPref ?? this.feedViewPref,
    threadViewPref: threadViewPref ?? this.threadViewPref,
    blackskyAiPreferences: blackskyAiPreferences ?? this.blackskyAiPreferences,
    message: clearMessage ? null : message ?? this.message,
  );

  @override
  List<Object?> get props => [
    status,
    feed,
    feedDisplayName,
    supportsBlackskyAiPreferences,
    feedViewPref,
    threadViewPref,
    blackskyAiPreferences,
    message,
  ];
}

class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  AccountSettingsCubit({
    required FeedRepository feedRepository,
    required String feed,
    required String feedDisplayName,
    bool supportsBlackskyAiPreferences = false,
    DateTime Function()? clock,
  }) : _feedRepository = feedRepository,
       _clock = clock ?? DateTime.now,
       super(
         AccountSettingsState.initial(
           feed: feed,
           feedDisplayName: feedDisplayName,
           supportsBlackskyAiPreferences: supportsBlackskyAiPreferences,
         ),
       );

  final FeedRepository _feedRepository;
  final DateTime Function() _clock;

  Future<void> loadPreferences() async {
    _safeEmit(state.copyWith(status: AccountSettingsStatus.loading, clearMessage: true));

    try {
      final result = await _feedRepository.getPreferences();
      final feedViewPref = _feedViewPrefFrom(result.preferences) ?? FeedViewPref(feed: state.feed);
      final threadViewPref = _threadViewPrefFrom(result.preferences) ?? const ThreadViewPref();
      final blackskyAiPreferences = state.supportsBlackskyAiPreferences
          ? BlackskyAiPreferences.fromRecord(await _feedRepository.getBlackskyAiPreferenceRecord())
          : null;
      _safeEmit(
        state.copyWith(
          status: AccountSettingsStatus.loaded,
          feedViewPref: feedViewPref,
          threadViewPref: threadViewPref,
          blackskyAiPreferences: blackskyAiPreferences,
          clearMessage: true,
        ),
      );
    } catch (error, stackTrace) {
      log.e(
        'AccountSettingsCubit: Failed to load account display preferences for ${state.feed}',
        error: error,
        stackTrace: stackTrace,
      );
      _safeEmit(
        state.copyWith(
          status: AccountSettingsStatus.error,
          feedViewPref: state.feedViewPref ?? FeedViewPref(feed: state.feed),
          threadViewPref: state.threadViewPref ?? const ThreadViewPref(),
          blackskyAiPreferences:
              state.blackskyAiPreferences ??
              (state.supportsBlackskyAiPreferences ? const BlackskyAiPreferences() : null),
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

  Future<void> setThreadSort(ThreadViewPrefSort? value) =>
      _updateThreadPreference((pref) => pref.copyWith(sort: value));

  Future<void> setBlackskyAiPreference(BlackskyAiPreferenceCategory category, BlackskyAiPreferenceValue value) async {
    if (!state.supportsBlackskyAiPreferences) {
      return;
    }
    final current = state.blackskyAiPreferences ?? const BlackskyAiPreferences();
    final updated = current.copyWithCategory(category, value);
    _safeEmit(state.copyWith(status: AccountSettingsStatus.saving, blackskyAiPreferences: updated, clearMessage: true));

    try {
      await _feedRepository.putBlackskyAiPreferenceRecord(record: updated.toRecord(updatedAt: _clock()));
      _safeEmit(
        state.copyWith(status: AccountSettingsStatus.loaded, blackskyAiPreferences: updated, clearMessage: true),
      );
    } catch (error, stackTrace) {
      log.e('AccountSettingsCubit: Failed to save BlackSky AI preferences', error: error, stackTrace: stackTrace);
      _safeEmit(
        state.copyWith(
          status: AccountSettingsStatus.saveError,
          blackskyAiPreferences: updated,
          message: error.toString(),
        ),
      );
    }
  }

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

  Future<void> _updateThreadPreference(ThreadViewPref Function(ThreadViewPref current) update) async {
    final current = state.threadViewPref ?? const ThreadViewPref();
    final updated = update(current);
    _safeEmit(state.copyWith(status: AccountSettingsStatus.saving, threadViewPref: updated, clearMessage: true));

    try {
      final result = await _feedRepository.getPreferences();
      final preferences = _replaceThreadViewPref(result.preferences, updated);
      await _feedRepository.putPreferences(preferences: preferences);
      _safeEmit(state.copyWith(status: AccountSettingsStatus.loaded, threadViewPref: updated, clearMessage: true));
    } catch (error, stackTrace) {
      log.e('AccountSettingsCubit: Failed to save thread preferences', error: error, stackTrace: stackTrace);
      _safeEmit(
        state.copyWith(status: AccountSettingsStatus.saveError, threadViewPref: updated, message: error.toString()),
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

  ThreadViewPref? _threadViewPrefFrom(List<UPreferences> preferences) {
    for (final preference in preferences) {
      final threadViewPref = preference.threadViewPref;
      if (threadViewPref != null) {
        return threadViewPref;
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

  List<UPreferences> _replaceThreadViewPref(List<UPreferences> preferences, ThreadViewPref updated) {
    return [
      for (final preference in preferences)
        if (preference.threadViewPref == null) preference,
      UPreferences.threadViewPref(data: updated),
    ];
  }

  void _safeEmit(AccountSettingsState nextState) {
    if (isClosed) {
      return;
    }
    emit(nextState);
  }
}
