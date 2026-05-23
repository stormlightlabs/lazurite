import 'dart:convert';

import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/actor/get_preferences.dart';
import 'package:bluesky_poptart/app/bsky/actor/put_preferences.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart' hide ViewerState;
import 'package:bluesky_poptart/app/bsky/labeler/defs.dart';
import 'package:bluesky_poptart/app/bsky/labeler/get_services.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:poptart_bluesky_moderation/poptart_bluesky_moderation.dart' as moderation;

import '../../../helpers/test_bluesky_client.dart';

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
        bluesky: _testBlueskyClient(
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
        bluesky: _testBlueskyClient(
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

    test('ignores unauthenticated-only labels when the viewer is authenticated', () async {
      final service = ModerationService(
        bluesky: _testBlueskyClient(),
        database: database,
        accountDid: _accountDid,
        userDid: _accountDid,
      );

      await service.ensureInitialized();

      final profileUi = service.profileDetailedUi(
        _authGatedProfile(),
        moderation.ModerationBehaviorContext.profileView,
      );
      final avatarUi = service.profileDetailedUi(_authGatedProfile(), moderation.ModerationBehaviorContext.avatar);

      expect(profileUi.blur, isFalse);
      expect(profileUi.noOverride, isFalse);
      expect(avatarUi.blur, isFalse);

      service.dispose();
    });

    test('applies unauthenticated-only labels when no viewer is authenticated', () async {
      final service = ModerationService(
        bluesky: _testBlueskyClient(anonymous: true),
        database: database,
        accountDid: 'anonymous',
      );

      await service.updatePreferences(preferences: const []);

      final profileUi = service.profileDetailedUi(
        _authGatedProfile(),
        moderation.ModerationBehaviorContext.profileView,
      );
      final avatarUi = service.profileDetailedUi(_authGatedProfile(), moderation.ModerationBehaviorContext.avatar);

      expect(profileUi.blur, isTrue);
      expect(profileUi.noOverride, isTrue);
      expect(avatarUi.blur, isTrue);
      expect(avatarUi.noOverride, isTrue);

      service.dispose();
    });

    test('public mode skips account preferences and account viewer moderation', () async {
      final actor = _FakeActorService(
        preferences: [
          const UPreferences.labelersPref(
            data: LabelersPref(labelers: [LabelerPrefItem(did: _customLabelerDid)]),
          ),
        ],
      );
      final service = ModerationService.public(
        bluesky: _testBlueskyClient(actor: actor, labeler: const _FakeLabelerService(), anonymous: true),
        database: database,
        appViewProvider: 'blacksky',
      );

      await service.ensureInitialized();

      const blockedByProfile = ProfileViewDetailed(
        did: 'did:plc:viewer-state',
        handle: 'viewer-state.bsky.social',
        viewer: ViewerState(blockedBy: true, muted: true),
      );
      final profileUi = service.profileDetailedUi(blockedByProfile, moderation.ModerationBehaviorContext.profileView);

      expect(actor.getPreferencesCallCount, 0);
      expect(service.currentOpts?.userDid, isNull);
      expect(service.currentPreferences, isEmpty);
      expect(service.currentHeaders['atproto-accept-labelers'], isNot(contains(_customLabelerDid)));
      expect(profileUi.filter, isFalse);
      expect(profileUi.blur, isFalse);

      service.dispose();
    });

    test('falls back to cached preferences after a request failure', () async {
      final seededService = ModerationService(
        bluesky: _testBlueskyClient(
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
        bluesky: _testBlueskyClient(
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
        bluesky: _testBlueskyClient(actor: actor, labeler: const _FakeLabelerService()),
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

    test('does not force AppView proxy headers for preference reads and writes', () async {
      final actor = _FakeActorService(preferences: const []);
      final service = ModerationService(
        bluesky: _testBlueskyClient(actor: actor, labeler: const _FakeLabelerService()),
        database: database,
        accountDid: _accountDid,
        userDid: _accountDid,
        appViewProvider: 'blacksky',
      );

      await service.ensureInitialized();
      expect(actor.lastGetPreferencesHeaders?['atproto-proxy'], isNull);

      await service.subscribeToLabeler(_customLabelerDid);
      expect(actor.lastPutPreferencesHeaders?['atproto-proxy'], isNull);
      expect(actor.lastPutPreferencesHeaders?['atproto-accept-labelers'], contains(_customLabelerDid));

      service.dispose();
    });

    test('does not perform proxy-retry cycle for preferences', () async {
      final actor = _FakeActorService(
        preferences: const [],
        errorOnProxyGetPreferences: _proxyNotSupported(
          method: HttpMethod.get,
          xrpcMethod: 'app.bsky.actor.getPreferences',
        ),
        errorOnProxyPutPreferences: _proxyNotSupported(
          method: HttpMethod.post,
          xrpcMethod: 'app.bsky.actor.putPreferences',
        ),
      );
      final service = ModerationService(
        bluesky: _testBlueskyClient(actor: actor, labeler: const _FakeLabelerService()),
        database: database,
        accountDid: _accountDid,
        userDid: _accountDid,
        appViewProvider: 'blacksky',
      );

      await service.ensureInitialized();
      expect(actor.getPreferencesCallCount, 1);
      expect(actor.lastGetPreferencesHeaders?['atproto-proxy'], isNull);

      await service.subscribeToLabeler(_customLabelerDid);
      expect(actor.putPreferencesCallCount, 1);
      expect(actor.lastPutPreferencesHeaders?['atproto-proxy'], isNull);

      service.dispose();
    });

    test('setLabelPreference stores contentLabelPref entries', () async {
      final actor = _FakeActorService(preferences: const []);
      final service = ModerationService(
        bluesky: _testBlueskyClient(actor: actor, labeler: const _FakeLabelerService()),
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
      final service = ModerationService(bluesky: _testBlueskyClient());

      expect(() => service.dispose(), returnsNormally);
      expect(() => service.dispose(), returnsNormally);
    });

    test('caches moderation preferences in the settings table', () async {
      final service = ModerationService(
        bluesky: _testBlueskyClient(
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

    test('resolves localized custom label names from labeler policies', () async {
      final service = ModerationService(
        bluesky: _testBlueskyClient(
          actor: _FakeActorService(
            preferences: [
              const UPreferences.labelersPref(
                data: LabelersPref(labelers: [LabelerPrefItem(did: _customLabelerDid)]),
              ),
            ],
          ),
          labeler: _FakeLabelerService(
            views: [
              ULabelerGetServicesViews.labelerViewDetailed(
                data: _buildLabeler(
                  did: _customLabelerDid,
                  handle: 'labels.example',
                  displayName: 'Custom Labels',
                  description: 'Community labels.',
                  definitionIdentifier: 'aaa',
                  definitionName: '🅰️',
                ),
              ),
            ],
          ),
        ),
        database: database,
        accountDid: _accountDid,
        userDid: _accountDid,
      );

      await service.ensureInitialized();

      expect(
        service.resolveLabelDisplayName(
          identifier: 'aaa',
          labelerDid: _customLabelerDid,
          preferredLanguages: const ['en-US', 'en'],
        ),
        '🅰️',
      );

      service.dispose();
    });
  });
}

Bluesky _testBlueskyClient({_FakeActorService? actor, _FakeLabelerService? labeler, bool anonymous = false}) {
  final transport = _FakeModerationTransport(
    actor: actor ?? _FakeActorService(),
    labeler: labeler ?? const _FakeLabelerService(),
  );
  if (anonymous) {
    return Bluesky.anonymous(getClient: transport.get, postClient: transport.post);
  }
  return testBluesky(getClient: transport.get, postClient: transport.post);
}

ProfileViewDetailed _authGatedProfile() {
  return ProfileViewDetailed(
    did: _accountDid,
    handle: 'test.bsky.social',
    indexedAt: DateTime.utc(2026, 5, 16),
    labels: [
      Label(
        src: 'did:plc:ar7c4by46qjdydhdevvrndac',
        uri: 'at://$_accountDid/app.bsky.actor.profile/self',
        val: '!no-unauthenticated',
        cts: DateTime.utc(2026, 5, 16),
      ),
    ],
  );
}

class _FakeModerationTransport {
  _FakeModerationTransport({_FakeActorService? actor, _FakeLabelerService? labeler})
    : actor = actor ?? _FakeActorService(),
      labeler = labeler ?? const _FakeLabelerService();

  final _FakeActorService actor;
  final _FakeLabelerService labeler;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    switch (url.pathSegments.last) {
      case 'app.bsky.actor.getPreferences':
        final response = await actor.getPreferences($headers: headers);
        return jsonResponse(url, 'GET', ActorGetPreferencesOutput(preferences: response.data.preferences).toJson());
      case 'app.bsky.labeler.getServices':
        final response = await labeler.getServices(
          dids: url.queryParametersAll['dids'] ?? const [],
          detailed: url.queryParameters['detailed'] == 'true',
          $headers: headers,
        );
        return jsonResponse(url, 'GET', LabelerGetServicesOutput(views: response.data.views).toJson());
      default:
        return unexpectedGetClient(url, headers: headers);
    }
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    if (url.pathSegments.last != 'app.bsky.actor.putPreferences') {
      return unexpectedPostClient(url, headers: headers, body: body, encoding: encoding);
    }

    final input = ActorPutPreferencesInput.fromJson((jsonDecode(body as String) as Map).cast<String, Object?>());
    await actor.putPreferences(preferences: input.preferences, $headers: headers);
    return jsonResponse(url, 'POST', const {});
  }
}

class _FakeActorService {
  _FakeActorService({
    this.preferences = const [],
    this.error,
    this.errorOnProxyGetPreferences,
    this.errorOnProxyPutPreferences,
  });

  final List<UPreferences> preferences;
  final Object? error;
  final Object? errorOnProxyGetPreferences;
  final Object? errorOnProxyPutPreferences;
  List<UPreferences>? lastPutPreferences;
  Map<String, String>? lastGetPreferencesHeaders;
  Map<String, String>? lastPutPreferencesHeaders;
  int getPreferencesCallCount = 0;
  int putPreferencesCallCount = 0;

  Future<_FakePreferencesResponse> getPreferences({Map<String, String>? $headers}) async {
    getPreferencesCallCount++;
    if (error != null) {
      throw error!;
    }
    if (_hasAppViewProxyHeader($headers) && errorOnProxyGetPreferences != null) {
      throw errorOnProxyGetPreferences!;
    }
    lastGetPreferencesHeaders = $headers;
    return _FakePreferencesResponse(_FakePreferencesData(preferences));
  }

  Future<void> putPreferences({required List<UPreferences> preferences, Map<String, String>? $headers}) async {
    putPreferencesCallCount++;
    if (_hasAppViewProxyHeader($headers) && errorOnProxyPutPreferences != null) {
      throw errorOnProxyPutPreferences!;
    }
    lastPutPreferences = preferences;
    lastPutPreferencesHeaders = $headers;
  }

  bool _hasAppViewProxyHeader(Map<String, String>? headers) {
    if (headers == null) {
      return false;
    }
    return headers.keys.any((key) => key.toLowerCase() == 'atproto-proxy');
  }
}

class _FakeLabelerService {
  const _FakeLabelerService({this.error, this.views = const []});

  final Object? error;
  final List<ULabelerGetServicesViews> views;

  Future<_FakeGetServicesResponse> getServices({
    required List<String> dids,
    bool? detailed,
    Map<String, String>? $headers,
  }) async {
    if (error != null) {
      throw error!;
    }
    return _FakeGetServicesResponse(_FakeGetServicesData(views));
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

InvalidRequestException _proxyNotSupported({required HttpMethod method, required String xrpcMethod}) {
  return InvalidRequestException(
    XRPCResponse<XRPCError>(
      headers: const {},
      status: HttpStatus.notFound,
      request: XRPCRequest(method: method, url: Uri.parse('https://example.test/xrpc/$xrpcMethod')),
      rateLimit: RateLimit.unlimited(),
      data: const XRPCError(error: 'XRPCNotSupported', message: 'XRPC Not Supported'),
    ),
  );
}

LabelerViewDetailed _buildLabeler({
  required String did,
  required String handle,
  required String displayName,
  required String description,
  required String definitionIdentifier,
  required String definitionName,
}) {
  return LabelerViewDetailed(
    uri: AtUri.parse('at://$did/app.bsky.labeler.service/self'),
    cid: 'cid-$did',
    creator: ProfileView(
      did: did,
      handle: handle,
      displayName: displayName,
      description: description,
      avatar: 'https://example.com/$handle.png',
    ),
    policies: LabelerPolicies(
      labelValues: [LabelValue.unknown(data: definitionIdentifier)],
      labelValueDefinitions: [
        LabelValueDefinition(
          identifier: definitionIdentifier,
          severity: const LabelValueDefinitionSeverity.knownValue(data: KnownLabelValueDefinitionSeverity.alert),
          blurs: const LabelValueDefinitionBlurs.knownValue(data: KnownLabelValueDefinitionBlurs.content),
          defaultSetting: const LabelValueDefinitionDefaultSetting.knownValue(
            data: KnownLabelValueDefinitionDefaultSetting.warn,
          ),
          adultOnly: false,
          locales: [LabelValueDefinitionStrings(lang: 'en', name: definitionName, description: 'Example description')],
        ),
      ],
    ),
    indexedAt: DateTime.utc(2026, 4, 30),
  );
}
