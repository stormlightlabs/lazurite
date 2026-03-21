import 'dart:convert';

import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_labeler_getservices.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

const _customLabelerDid = 'did:plc:custom-labeler';
const _accountDid = 'did:plc:test-user';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('ModerationService', () {
    test('initializes moderation opts, userDid, and accepted labeler headers', () async {
      final service = ModerationService(
        bluesky: _FakeBlueskyClient(
          actor: _FakeActorService(
            preferences: [
              const UPreferences.adultContentPref(data: AdultContentPref(enabled: false)),
              const UPreferences.labelersPref(
                data: LabelersPref(labelers: [LabelerPrefItem(did: _customLabelerDid)]),
              ),
            ],
          ),
          labeler: const _FakeLabelerService(),
        ),
        database: database,
        accountDid: _accountDid,
        userDid: _accountDid,
      );

      await service.ensureInitialized();

      expect(service.currentOpts, isNotNull);
      expect(service.currentOpts!.userDid, _accountDid);
      expect(service.currentHeaders['atproto-accept-labelers'], contains(_customLabelerDid));
      expect(service.currentPrefs?.labelers.map((labeler) => labeler.did), contains(_customLabelerDid));

      service.dispose();
    });

    test('filters labeled posts in list contexts', () async {
      final service = ModerationService(
        bluesky: _FakeBlueskyClient(
          actor: _FakeActorService(
            preferences: [const UPreferences.adultContentPref(data: AdultContentPref(enabled: false))],
          ),
          labeler: const _FakeLabelerService(),
        ),
        database: database,
        accountDid: _accountDid,
        userDid: _accountDid,
      );

      await service.ensureInitialized();

      final labeledPost = PostView(
        uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/abc'),
        cid: 'cid-123',
        author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social'),
        record: {
          r'$type': 'app.bsky.feed.post',
          'text': 'sensitive',
          'createdAt': DateTime.utc(2026, 3, 15).toIso8601String(),
        },
        indexedAt: DateTime.utc(2026, 3, 15),
        labels: [
          Label(
            src: 'did:plc:ar7c4by46qjdydhdevvrndac',
            uri: 'at://did:plc:author/app.bsky.feed.post/abc',
            val: 'porn',
            cts: DateTime.utc(2026, 3, 15),
          ),
        ],
      );

      expect(service.shouldFilterPostInList(labeledPost), isTrue);

      service.dispose();
    });

    test('falls back to cached preferences after a request failure', () async {
      final seededService = ModerationService(
        bluesky: _FakeBlueskyClient(
          actor: _FakeActorService(
            preferences: [
              const UPreferences.labelersPref(
                data: LabelersPref(labelers: [LabelerPrefItem(did: _customLabelerDid)]),
              ),
            ],
          ),
          labeler: const _FakeLabelerService(),
        ),
        database: database,
        accountDid: _accountDid,
        userDid: _accountDid,
      );
      await seededService.ensureInitialized();
      seededService.dispose();

      final fallbackService = ModerationService(
        bluesky: _FakeBlueskyClient(
          actor: _FakeActorService(error: Exception('offline')),
          labeler: _FakeLabelerService(error: Exception('offline')),
        ),
        database: database,
        accountDid: _accountDid,
        userDid: _accountDid,
      );

      await fallbackService.ensureInitialized();

      expect(fallbackService.currentPrefs, isNotNull);
      expect(fallbackService.currentHeaders['atproto-accept-labelers'], contains(_customLabelerDid));

      fallbackService.dispose();
    });

    test('subscribeToLabeler writes updated preferences and refreshes headers', () async {
      final actor = _FakeActorService(preferences: const []);
      final service = ModerationService(
        bluesky: _FakeBlueskyClient(actor: actor, labeler: const _FakeLabelerService()),
        database: database,
        accountDid: _accountDid,
        userDid: _accountDid,
      );

      await service.ensureInitialized();
      await service.subscribeToLabeler(_customLabelerDid);

      expect(actor.lastPutPreferences, isNotNull);
      expect(
        actor.lastPutPreferences!
            .where((preference) => preference.isLabelersPref)
            .single
            .labelersPref!
            .labelers
            .map((labeler) => labeler.did),
        contains(_customLabelerDid),
      );
      expect(service.currentHeaders['atproto-accept-labelers'], contains(_customLabelerDid));

      service.dispose();
    });

    test('setLabelPreference stores contentLabelPref entries', () async {
      final actor = _FakeActorService(preferences: const []);
      final service = ModerationService(
        bluesky: _FakeBlueskyClient(actor: actor, labeler: const _FakeLabelerService()),
        database: database,
        accountDid: _accountDid,
        userDid: _accountDid,
      );

      await service.ensureInitialized();
      await service.setLabelPreference(
        label: 'porn',
        visibility: KnownContentLabelPrefVisibility.hide,
        labelerDid: _customLabelerDid,
      );

      final contentPref = actor.lastPutPreferences!
          .where((preference) => preference.isContentLabelPref)
          .single
          .contentLabelPref!;

      expect(contentPref.label, 'porn');
      expect(contentPref.labelerDid, _customLabelerDid);
      expect(contentPref.visibility.toJson(), 'hide');

      service.dispose();
    });

    test('dispose is idempotent', () {
      final service = ModerationService(bluesky: _FakeBlueskyClient());

      expect(() => service.dispose(), returnsNormally);
      expect(() => service.dispose(), returnsNormally);
    });

    test('caches moderation preferences in the settings table', () async {
      final service = ModerationService(
        bluesky: _FakeBlueskyClient(
          actor: _FakeActorService(
            preferences: [
              const UPreferences.labelersPref(
                data: LabelersPref(labelers: [LabelerPrefItem(did: _customLabelerDid)]),
              ),
            ],
          ),
          labeler: const _FakeLabelerService(),
        ),
        database: database,
        accountDid: _accountDid,
      );

      await service.ensureInitialized();

      final cachedPayload = await database.getSetting('moderation_preferences::$_accountDid');
      expect(cachedPayload, isNotNull);

      final decoded = jsonDecode(cachedPayload!) as List<dynamic>;
      expect(decoded, isNotEmpty);

      service.dispose();
    });
  });
}

class _FakeBlueskyClient {
  _FakeBlueskyClient({_FakeActorService? actor, _FakeLabelerService? labeler})
    : actor = actor ?? _FakeActorService(),
      labeler = labeler ?? const _FakeLabelerService();

  final _FakeActorService actor;
  final _FakeLabelerService labeler;
}

class _FakeActorService {
  _FakeActorService({this.preferences = const [], this.error});

  final List<UPreferences> preferences;
  final Object? error;
  List<UPreferences>? lastPutPreferences;

  Future<_FakePreferencesResponse> getPreferences() async {
    if (error != null) {
      throw error!;
    }
    return _FakePreferencesResponse(_FakePreferencesData(preferences));
  }

  Future<void> putPreferences({required List<UPreferences> preferences}) async {
    lastPutPreferences = preferences;
  }
}

class _FakeLabelerService {
  const _FakeLabelerService({this.error});

  final Object? error;

  Future<_FakeGetServicesResponse> getServices({
    required List<String> dids,
    bool? detailed,
    Map<String, String>? $headers,
  }) async {
    if (error != null) {
      throw error!;
    }
    return const _FakeGetServicesResponse(_FakeGetServicesData([]));
  }
}

class _FakePreferencesResponse {
  const _FakePreferencesResponse(this.data);

  final _FakePreferencesData data;
}

class _FakePreferencesData {
  const _FakePreferencesData(this.preferences);

  final List<UPreferences> preferences;
}

class _FakeGetServicesResponse {
  const _FakeGetServicesResponse(this.data);

  final _FakeGetServicesData data;
}

class _FakeGetServicesData {
  const _FakeGetServicesData(this.views);

  final List<ULabelerGetServicesViews> views;
}
