import 'dart:async';

import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/search/domain/search_actor.dart';
import 'package:lazurite/src/infrastructure/network/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'autocomplete_provider.g.dart';

enum AutocompleteType { mention, hashtag }

class AutocompleteSuggestion {
  factory AutocompleteSuggestion.mention(SearchActorItem actor) {
    return AutocompleteSuggestion(
      type: AutocompleteType.mention,
      label: actor.displayName ?? actor.handle,
      handle: actor.handle,
      did: actor.did,
      avatar: actor.avatar,
    );
  }

  factory AutocompleteSuggestion.hashtag(String tag) {
    return AutocompleteSuggestion(type: AutocompleteType.hashtag, label: tag);
  }
  const AutocompleteSuggestion({
    required this.type,
    required this.label,
    this.handle,
    this.did,
    this.avatar,
  });

  final AutocompleteType type;
  final String label;
  final String? handle;
  final String? did;
  final String? avatar;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutocompleteSuggestion &&
        other.type == type &&
        other.label == label &&
        other.handle == handle &&
        other.did == did &&
        other.avatar == avatar;
  }

  @override
  int get hashCode =>
      type.hashCode ^ label.hashCode ^ handle.hashCode ^ did.hashCode ^ avatar.hashCode;
}

@riverpod
class AutocompleteNotifier extends _$AutocompleteNotifier {
  Timer? _debounceTimer;

  XrpcClient get _api => ref.read(xrpcClientProvider);
  Logger get _logger => ref.read(loggerProvider('AutocompleteNotifier'));

  @override
  Future<List<AutocompleteSuggestion>> build() async {
    ref.onDispose(() => _debounceTimer?.cancel());
    return [];
  }

  void search(String text) {
    _debounceTimer?.cancel();

    final parsed = _parseAutocompleteQuery(text);
    if (parsed == null) {
      state = const AsyncValue.data([]);
      return;
    }

    final (type, query) = parsed;
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => _performSearch(type, query));
    });
  }

  (AutocompleteType, String)? _parseAutocompleteQuery(String text) {
    final lastSpaceIndex = text.lastIndexOf(' ');
    final lastNewlineIndex = text.lastIndexOf('\n');
    final lastSeparatorIndex = [lastSpaceIndex, lastNewlineIndex].reduce((a, b) => a > b ? a : b);

    final segment = lastSeparatorIndex >= 0 ? text.substring(lastSeparatorIndex + 1) : text;

    if (segment.startsWith('@')) {
      return (AutocompleteType.mention, segment.substring(1));
    }

    if (segment.startsWith('#')) {
      return (AutocompleteType.hashtag, segment.substring(1));
    }

    return null;
  }

  Future<List<AutocompleteSuggestion>> _performSearch(AutocompleteType type, String query) async {
    try {
      switch (type) {
        case AutocompleteType.mention:
          return await _searchMentions(query);
        case AutocompleteType.hashtag:
          return await _searchHashtags(query);
      }
    } catch (e, stack) {
      _logger.error('Autocomplete search failed for type $type, query: $query', e, stack);
      return [];
    }
  }

  Future<List<AutocompleteSuggestion>> _searchMentions(String query) async {
    _logger.debug('Searching mentions', {'query': query});

    final response = await _api.call(
      'app.bsky.actor.searchActorsTypeahead',
      params: {'q': query, 'limit': 10},
    );

    final actorsJson = response['actors'];
    if (actorsJson is! List) {
      return [];
    }

    final suggestions = <AutocompleteSuggestion>[];
    for (final actorJson in actorsJson) {
      if (actorJson is! Map<String, dynamic>) {
        continue;
      }
      try {
        final actor = SearchActorItem.fromJson(actorJson);
        suggestions.add(AutocompleteSuggestion.mention(actor));
      } catch (_) {
        continue;
      }
    }

    _logger.debug('Found ${suggestions.length} mention suggestions');
    return suggestions;
  }

  Future<List<AutocompleteSuggestion>> _searchHashtags(String query) async {
    _logger.debug('Searching hashtags', {'query': query});

    final response = await _api.call(
      'app.bsky.actor.searchActorsTypeahead',
      params: {'q': '#$query', 'limit': 10},
    );

    final actorsJson = response['actors'];
    if (actorsJson is! List) {
      return [];
    }

    final suggestions = <AutocompleteSuggestion>[];
    for (final actorJson in actorsJson) {
      if (actorJson is! Map<String, dynamic>) {
        continue;
      }

      final handle = actorJson['handle'] as String?;
      if (handle != null && handle.startsWith('#') && handle != '#') {
        suggestions.add(AutocompleteSuggestion.hashtag(handle.substring(1)));
      }
    }

    _logger.debug('Found ${suggestions.length} hashtag suggestions');
    return suggestions;
  }

  void clear() {
    _debounceTimer?.cancel();
    state = const AsyncValue.data([]);
  }
}
