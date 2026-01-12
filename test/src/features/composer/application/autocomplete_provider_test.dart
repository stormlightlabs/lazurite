import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/application/autocomplete_provider.dart';
import 'package:lazurite/src/features/search/domain/search_actor.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

void main() {
  group('AutocompleteNotifier', () {
    late MockXrpcClient mockApi;
    late ProviderContainer container;

    setUp(() {
      mockApi = MockXrpcClient();
      container = ProviderContainer(overrides: [xrpcClientProvider.overrideWithValue(mockApi)]);
    });

    tearDown(() {
      container.dispose();
    });

    test('build returns empty list initially', () async {
      final future = container.read(autocompleteProvider.future);
      final result = await future;
      expect(result, []);
    });

    group('search', () {
      test('parses query segment correctly', () {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => <String, dynamic>{'actors': <dynamic>[]});

        final notifier = container.read(autocompleteProvider.notifier);
        container.listen(autocompleteProvider, (_, _) {});

        notifier.search('hello @test');
        notifier.search('just normal text');
        notifier.search('hello #flutter');
        notifier.search('end with newline\n#dart');

        verifyNever(() => mockApi.call(any(), params: any(named: 'params')));
      });

      test('clears state when calling clear()', () async {
        final notifier = container.read(autocompleteProvider.notifier);
        container.listen(autocompleteProvider, (_, _) {});

        notifier.clear();

        final result = await container.read(autocompleteProvider.future);
        expect(result, []);
      });
    });

    group('AutocompleteSuggestion', () {
      test('creates mention suggestion from actor', () {
        final suggestion = AutocompleteSuggestion.mention(
          SearchActorItem(
            did: 'did:plc:test',
            handle: 'test.bsky.social',
            displayName: 'Test User',
            avatar: 'https://example.com/avatar.jpg',
          ),
        );

        expect(suggestion.type, AutocompleteType.mention);
        expect(suggestion.label, 'Test User');
        expect(suggestion.handle, 'test.bsky.social');
        expect(suggestion.did, 'did:plc:test');
        expect(suggestion.avatar, 'https://example.com/avatar.jpg');
      });

      test('uses handle as label when display name is null', () {
        final suggestion = AutocompleteSuggestion.mention(
          SearchActorItem(did: 'did:plc:test', handle: 'test.bsky.social'),
        );

        expect(suggestion.label, 'test.bsky.social');
      });

      test('creates hashtag suggestion', () {
        final suggestion = AutocompleteSuggestion.hashtag('flutter');

        expect(suggestion.type, AutocompleteType.hashtag);
        expect(suggestion.label, 'flutter');
        expect(suggestion.handle, isNull);
        expect(suggestion.did, isNull);
        expect(suggestion.avatar, isNull);
      });

      test('implements equality correctly', () {
        final suggestion1 = AutocompleteSuggestion.hashtag('flutter');
        final suggestion2 = AutocompleteSuggestion.hashtag('flutter');
        final suggestion3 = AutocompleteSuggestion.hashtag('dart');

        expect(suggestion1, equals(suggestion2));
        expect(suggestion1, isNot(equals(suggestion3)));
      });
    });
  });
}
