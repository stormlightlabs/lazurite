import 'dart:async';

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/labeler/defs.dart';
import 'package:bluesky_poptart/app/bsky/labeler/get_services.dart';
import 'package:bluesky_poptart/app/bsky/notification/list_notifications.dart' as notifications;
import 'package:bluesky_poptart/app/bsky/actor/get_preferences/output.dart';
import 'package:lazurite/core/cache/poptart_cache_codecs.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:poptart_bluesky_moderation/poptart_bluesky_moderation.dart' as moderation;
import 'package:poptart_lex/com/atproto/label/defs.dart' show LabelValueDefinition, LabelValueDefinitionStrings;

const _officialBlueskyLabelerDid = 'did:plc:ar7c4by46qjdydhdevvrndac';
const _maxCustomLabelers = 20;

class ModerationService {
  ModerationService({
    required Bluesky bluesky,
    AppDatabase? database,
    String? accountDid,
    String? userDid,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
    Future<AuthTokens?> Function()? onUnauthorized,
    Bluesky? Function(AuthTokens tokens)? blueskyClientFactory,
  }) : _database = database,
       _accountDid = accountDid,
       _userDid = userDid,
       _publicReadOnly = false,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ) {
    _authRecovery = UnauthorizedRecoveryRunner<Bluesky>(
      initialClient: bluesky,
      onUnauthorized: onUnauthorized,
      clientFactory: blueskyClientFactory ?? createBlueskyClient,
      expectedDid: accountDid ?? userDid,
    );
    _headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.labeler.getServices',
      _buildLabelerHeaders(const []),
    );
  }

  ModerationService.public({
    required Bluesky bluesky,
    AppDatabase? database,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
  }) : _database = database,
       _accountDid = null,
       _userDid = null,
       _publicReadOnly = true,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ) {
    _authRecovery = UnauthorizedRecoveryRunner<Bluesky>(
      initialClient: bluesky,
      onUnauthorized: null,
      clientFactory: createBlueskyClient,
    );
    _headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.labeler.getServices',
      _buildLabelerHeaders(const []),
    );
  }

  late final UnauthorizedRecoveryRunner<Bluesky> _authRecovery;
  final AppDatabase? _database;
  final String? _accountDid;
  final String? _userDid;
  final bool _publicReadOnly;
  final AppViewRequestContext _appViewContext;

  moderation.ModerationOpts? _opts;
  List<UPreferences> _preferences = const [];
  late Map<String, String> _headers;
  Future<void>? _initializationFuture;
  bool _disposed = false;
  final _optsController = StreamController<moderation.ModerationOpts>.broadcast();
  final Map<String, LabelerPolicies> _labelerPoliciesByDid = {};

  Stream<moderation.ModerationOpts> get optsStream => _optsController.stream;
  moderation.ModerationOpts? get currentOpts => _opts;
  moderation.ModerationPrefs? get currentPrefs => _opts?.prefs;
  List<UPreferences> get currentPreferences => List.unmodifiable(_preferences);
  Map<String, String> get currentHeaders => Map.unmodifiable(_headers);

  Future<void> initialize() => ensureInitialized();

  Future<void> ensureInitialized() async {
    if (_disposed) return;
    if (_opts != null) return;

    final inFlight = _initializationFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final future = _rebuildOpts();
    _initializationFuture = future;
    try {
      await future;
    } finally {
      if (identical(_initializationFuture, future)) {
        _initializationFuture = null;
      }
    }
  }

  Future<void> updatePreferences({List<UPreferences>? preferences}) async {
    if (_disposed) return;
    await _rebuildOpts(preferences: preferences, forceRefresh: true);
  }

  Future<Map<String, String>> headersForRequest() async {
    await ensureInitialized();
    return currentHeaders;
  }

  Future<List<ULabelerGetServicesViews>> getSubscribedLabelers() async {
    final labelerDids = await _getSubscribedLabelerDids();
    if (labelerDids.isEmpty) {
      return const [];
    }
    final headers = await headersForRequest();

    final response = await _authRecovery.run(
      (client) => client.labeler.getServices(dids: labelerDids, detailed: true, $headers: headers),
    );

    await _cacheLabelerPolicies(response.data.views);
    return response.data.views;
  }

  Future<LabelerViewDetailed?> getLabelerDetails(String did) async {
    final headers = await headersForRequest();
    final response = await _authRecovery.run(
      (client) => client.labeler.getServices(dids: [did], detailed: true, $headers: headers),
    );

    await _cacheLabelerPolicies(response.data.views);

    for (final view in response.data.views) {
      if (view.isLabelerViewDetailed) {
        return view.labelerViewDetailed!;
      }
    }

    return null;
  }

  Future<void> subscribeToLabeler(String did) async {
    if (did == _officialBlueskyLabelerDid) {
      return;
    }

    final preferences = await _loadPreferences();
    final currentLabelers = _subscribedLabelerDidsFromPreferences(preferences);
    if (currentLabelers.contains(did)) {
      return;
    }
    if (currentLabelers.length >= _maxCustomLabelers) {
      throw StateError('A maximum of $_maxCustomLabelers labelers can be subscribed.');
    }

    final updated = _replaceLabelersPref(preferences, [
      ...currentLabelers.map((labelerDid) => LabelerPrefItem(did: labelerDid)),
      LabelerPrefItem(did: did),
    ]);

    await _putAndRefresh(updated);
  }

  Future<void> unsubscribeFromLabeler(String did) async {
    if (did == _officialBlueskyLabelerDid) {
      return;
    }

    final preferences = await _loadPreferences();
    final currentLabelers = _subscribedLabelerDidsFromPreferences(preferences);
    final updatedItems = currentLabelers
        .where((labelerDid) => labelerDid != did)
        .map((labelerDid) => LabelerPrefItem(did: labelerDid))
        .toList();

    final updated = _replaceLabelersPref(preferences, updatedItems);
    await _putAndRefresh(updated);
  }

  Future<void> setAdultContentEnabled(bool enabled) async {
    final preferences = await _loadPreferences();
    final updated = _replaceAdultContentPref(preferences, enabled);
    await _putAndRefresh(updated);
  }

  Future<void> setLabelPreference({
    required String label,
    required KnownContentLabelPrefVisibility visibility,
    String? labelerDid,
  }) async {
    final preferences = await _loadPreferences();
    final updated = _replaceContentLabelPref(
      preferences,
      label: label,
      labelerDid: labelerDid,
      visibility: ContentLabelPrefVisibility.knownValue(data: visibility),
    );

    await _putAndRefresh(updated);
  }

  moderation.ModerationDecision moderateFeedViewPost(FeedViewPost post) => moderatePost(post.post);

  moderation.ModerationDecision moderatePost(PostView post) {
    final opts = _opts;
    if (opts == null) {
      return moderation.ModerationDecision.init();
    }

    return moderation.moderatePost(moderation.ModerationSubjectPost.postView(data: post), opts);
  }

  moderation.ModerationDecision moderateProfile(ProfileView profile) {
    final opts = _opts;
    if (opts == null) {
      return moderation.ModerationDecision.init();
    }

    return moderation.moderateProfile(moderation.ModerationSubjectProfile.profileView(data: profile), opts);
  }

  moderation.ModerationDecision moderateProfileBasic(ProfileViewBasic profile) {
    final opts = _opts;
    if (opts == null) {
      return moderation.ModerationDecision.init();
    }

    return moderation.moderateProfile(moderation.ModerationSubjectProfile.profileViewBasic(data: profile), opts);
  }

  moderation.ModerationDecision moderateProfileDetailed(ProfileViewDetailed profile) {
    final opts = _opts;
    if (opts == null) {
      return moderation.ModerationDecision.init();
    }

    return moderation.moderateProfile(moderation.ModerationSubjectProfile.profileViewDetailed(data: profile), opts);
  }

  moderation.ModerationDecision moderateNotification(notifications.Notification notification) {
    final opts = _opts;
    if (opts == null) {
      return moderation.ModerationDecision.init();
    }

    return moderation.moderateNotification(
      moderation.ModerationSubjectNotification.notification(data: notification),
      opts,
    );
  }

  moderation.ModerationUI postUi(PostView post, moderation.ModerationBehaviorContext context) =>
      moderatePost(post).getUI(context);

  moderation.ModerationUI profileUi(ProfileView profile, moderation.ModerationBehaviorContext context) =>
      moderateProfile(profile).getUI(context);

  moderation.ModerationUI profileBasicUi(ProfileViewBasic profile, moderation.ModerationBehaviorContext context) =>
      moderateProfileBasic(profile).getUI(context);

  moderation.ModerationUI profileDetailedUi(
    ProfileViewDetailed profile,
    moderation.ModerationBehaviorContext context,
  ) => moderateProfileDetailed(profile).getUI(context);

  moderation.ModerationUI notificationUi(
    notifications.Notification notification,
    moderation.ModerationBehaviorContext context,
  ) => moderateNotification(notification).getUI(context);

  String? resolveLabelDisplayName({
    required String identifier,
    String? labelerDid,
    Iterable<String> preferredLanguages = const [],
  }) {
    if (identifier.isEmpty) {
      return null;
    }

    final requestedDid = (labelerDid == null || labelerDid.isEmpty) ? null : labelerDid;
    final candidateDids = <String>{_officialBlueskyLabelerDid};
    if (requestedDid != null) {
      candidateDids.add(requestedDid);
    }

    for (final did in candidateDids) {
      final definition = _labelValueDefinitionForIdentifier(_labelerPoliciesByDid[did], identifier);
      if (definition == null) {
        continue;
      }

      final localized = _localizedLabelName(definition.locales, preferredLanguages);
      if (localized != null && localized.isNotEmpty) {
        return localized;
      }
    }

    if (requestedDid != null) {
      return null;
    }

    for (final policies in _labelerPoliciesByDid.values) {
      final definition = _labelValueDefinitionForIdentifier(policies, identifier);
      if (definition == null) {
        continue;
      }
      final localized = _localizedLabelName(definition.locales, preferredLanguages);
      if (localized != null && localized.isNotEmpty) {
        return localized;
      }
    }

    return null;
  }

  bool shouldFilterFeedViewPostInList(FeedViewPost post) => shouldFilterPostInList(post.post);

  bool shouldFilterPostInList(PostView post) => postUi(post, moderation.ModerationBehaviorContext.contentList).filter;

  bool shouldFilterPostInView(PostView post) => postUi(post, moderation.ModerationBehaviorContext.contentView).filter;

  bool shouldFilterProfileInList(ProfileView profile) =>
      profileUi(profile, moderation.ModerationBehaviorContext.profileList).filter;

  bool shouldFilterProfileBasicInList(ProfileViewBasic profile) =>
      profileBasicUi(profile, moderation.ModerationBehaviorContext.profileList).filter;

  bool shouldFilterProfileDetailedInView(ProfileViewDetailed profile) =>
      profileDetailedUi(profile, moderation.ModerationBehaviorContext.profileView).filter;

  bool shouldFilterNotificationInList(notifications.Notification notification) {
    final decision = moderateNotification(notification);
    return decision.getUI(moderation.ModerationBehaviorContext.contentList).filter ||
        decision.getUI(moderation.ModerationBehaviorContext.profileList).filter;
  }

  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;
    _optsController.close();
  }

  Future<void> _rebuildOpts({List<UPreferences>? preferences, bool forceRefresh = false}) async {
    try {
      final resolvedPreferences = await _loadPreferences(providedPreferences: preferences, forceRefresh: forceRefresh);

      final moderationPrefs = _toModerationPrefs(resolvedPreferences);
      final labelDefs = await _loadLabelDefinitions(moderationPrefs);
      final opts = moderation.ModerationOpts(userDid: _resolvedUserDid, prefs: moderationPrefs, labelDefs: labelDefs);

      _preferences = resolvedPreferences;
      _headers = _buildHeadersForPrefs(moderationPrefs);
      _opts = opts;

      if (!_disposed) {
        _optsController.add(opts);
      }
    } catch (error, stackTrace) {
      log.w('Failed to build moderation opts: $error');
      log.d('$stackTrace');
    }
  }

  Future<List<UPreferences>> _loadPreferences({
    List<UPreferences>? providedPreferences,
    bool forceRefresh = false,
  }) async {
    if (providedPreferences != null) {
      await _cachePreferences(providedPreferences);
      return providedPreferences;
    }

    if (!forceRefresh && _preferences.isNotEmpty) {
      return _preferences;
    }

    if (_publicReadOnly) {
      return const [];
    }

    final headers = _appViewContext.appBskyHeadersWithoutProxy();
    try {
      final prefsResponse = await _authRecovery.run((client) => client.actor.getPreferences($headers: headers));
      final preferences = prefsResponse.data.preferences;
      await _cachePreferences(preferences);
      return preferences;
    } catch (error) {
      final cached = await _loadCachedPreferences();
      if (cached != null) {
        log.w('Using cached moderation preferences after request failure: $error');
        return cached;
      }

      rethrow;
    }
  }

  Future<void> _putAndRefresh(List<UPreferences> preferences) async {
    final moderationPrefs = _toModerationPrefs(preferences);
    final headers = _appViewContext.appBskyHeadersWithoutProxy(
      _buildLabelerHeaders(moderationPrefs.labelers.map((labeler) => labeler.did)),
    );
    await _authRecovery.run((client) => client.actor.putPreferences(preferences: preferences, $headers: headers));
    await updatePreferences(preferences: preferences);
  }

  Future<Map<String, List<moderation.InterpretedLabelValueDefinition>>> _loadLabelDefinitions(
    moderation.ModerationPrefs prefs,
  ) async {
    final labelerDids = {
      _officialBlueskyLabelerDid,
      ...prefs.labelers.map((labeler) => labeler.did),
    }.where((did) => did.startsWith('did:')).toList();

    try {
      final response = await _authRecovery.run(
        (client) =>
            client.labeler.getServices(dids: labelerDids, detailed: true, $headers: _buildHeadersForPrefs(prefs)),
      );

      await _cacheLabelerPolicies(response.data.views);
      return _mapLabelDefinitions(response.data.views);
    } catch (error) {
      final cached = await _loadCachedLabelDefinitions(labelerDids);
      if (cached.isNotEmpty) {
        log.w('Using cached label definitions after request failure: $error');
        return cached;
      }

      log.w('Proceeding without cached label definitions after request failure: $error');
      return const {};
    }
  }

  Future<void> _cacheLabelerPolicies(List<ULabelerGetServicesViews> views) async {
    if (_database == null) {
      for (final view in views) {
        if (!view.isLabelerViewDetailed) {
          continue;
        }
        final detailed = view.labelerViewDetailed!;
        _labelerPoliciesByDid[detailed.creator.did] = detailed.policies;
      }
      return;
    }

    for (final view in views) {
      if (!view.isLabelerViewDetailed) {
        continue;
      }

      final detailed = view.labelerViewDetailed!;
      _labelerPoliciesByDid[detailed.creator.did] = detailed.policies;
      await _database.upsertLabelerCache(
        detailed.creator.did,
        PoptartCacheCodecs.labelerPolicies.encode(detailed.policies),
      );
    }
  }

  Future<Map<String, List<moderation.InterpretedLabelValueDefinition>>> _loadCachedLabelDefinitions(
    List<String> labelerDids,
  ) async {
    if (_database == null) {
      return const {};
    }

    final definitions = <String, List<moderation.InterpretedLabelValueDefinition>>{};
    for (final did in labelerDids) {
      final cached = await _database.getLabelerCache(did);
      if (cached == null) {
        continue;
      }

      final policies = PoptartCacheCodecs.labelerPolicies.decode(cached.policiesJson);
      _labelerPoliciesByDid[did] = policies;
      definitions[did] = _interpretedLabelDefinitionsFromPolicies(policies, labelerDid: did);
    }

    return definitions;
  }

  Future<void> _cachePreferences(List<UPreferences> preferences) async {
    final database = _database;
    final prefsKey = _preferencesCacheKey;
    if (database == null || prefsKey == null) {
      return;
    }

    await database.setSetting(prefsKey, PoptartCacheCodecs.encodeModerationPreferences(preferences));
  }

  Future<List<UPreferences>?> _loadCachedPreferences() async {
    final database = _database;
    final prefsKey = _preferencesCacheKey;
    if (database == null || prefsKey == null) {
      return null;
    }

    final payload = await database.getSetting(prefsKey);
    if (payload == null || payload.isEmpty) {
      return null;
    }

    return PoptartCacheCodecs.decodeModerationPreferences(payload);
  }

  Future<List<String>> _getSubscribedLabelerDids() async {
    final preferences = await _loadPreferences();
    return _subscribedLabelerDidsFromPreferences(preferences);
  }

  List<String> _subscribedLabelerDidsFromPreferences(List<UPreferences> preferences) {
    for (final preference in preferences) {
      if (preference.isLabelersPref) {
        return preference.labelersPref!.labelers
            .map((item) => item.did)
            .where((did) => did.startsWith('did:'))
            .toList();
      }
    }

    return const [];
  }

  List<UPreferences> _replaceLabelersPref(List<UPreferences> preferences, List<LabelerPrefItem> labelers) {
    final updated = List<UPreferences>.from(preferences);
    updated.removeWhere((preference) => preference.isLabelersPref);
    updated.add(UPreferences.labelersPref(data: LabelersPref(labelers: labelers)));
    return updated;
  }

  List<UPreferences> _replaceAdultContentPref(List<UPreferences> preferences, bool enabled) {
    final updated = List<UPreferences>.from(preferences);
    updated.removeWhere((preference) => preference.isAdultContentPref);
    updated.add(UPreferences.adultContentPref(data: AdultContentPref(enabled: enabled)));
    return updated;
  }

  List<UPreferences> _replaceContentLabelPref(
    List<UPreferences> preferences, {
    required String label,
    required ContentLabelPrefVisibility visibility,
    String? labelerDid,
  }) {
    final updated = List<UPreferences>.from(preferences);
    updated.removeWhere(
      (preference) =>
          preference.isContentLabelPref &&
          preference.contentLabelPref!.label == label &&
          preference.contentLabelPref!.labelerDid == labelerDid,
    );
    updated.add(
      UPreferences.contentLabelPref(
        data: ContentLabelPref(label: label, labelerDid: labelerDid, visibility: visibility),
      ),
    );
    return updated;
  }

  moderation.ModerationPrefs _toModerationPrefs(List<UPreferences> preferences) {
    return ActorGetPreferencesOutput(
      preferences: preferences,
    ).getModerationPrefs(appLabelers: const [_officialBlueskyLabelerDid]);
  }

  Map<String, List<moderation.InterpretedLabelValueDefinition>> _mapLabelDefinitions(
    List<ULabelerGetServicesViews> views,
  ) {
    final definitions = <String, List<moderation.InterpretedLabelValueDefinition>>{};

    for (final view in views) {
      if (!view.isLabelerViewDetailed) {
        continue;
      }

      final detailed = view.labelerViewDetailed!;
      definitions[detailed.creator.did] = _interpretedLabelDefinitionsFromPolicies(
        detailed.policies,
        labelerDid: detailed.creator.did,
      );
    }

    return definitions;
  }

  List<moderation.InterpretedLabelValueDefinition> _interpretedLabelDefinitionsFromPolicies(
    LabelerPolicies policies, {
    required String labelerDid,
  }) {
    return policies.labelValueDefinitions
            ?.map(
              (definition) => moderation.getInterpretedLabelValueDefinition(
                identifier: definition.identifier,
                defaultSetting:
                    moderation.LabelPreference.valueOf(definition.defaultSetting?.toJson()) ??
                    moderation.LabelPreference.warn,
                severity: definition.severity.toJson(),
                blurs: definition.blurs.toJson(),
                adultOnly: definition.adultOnly ?? true,
                definedBy: labelerDid,
              ),
            )
            .toList() ??
        const [];
  }

  Map<String, String> _buildHeadersForPrefs(moderation.ModerationPrefs prefs) {
    return _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.labeler.getServices',
      _buildLabelerHeaders(prefs.labelers.map((labeler) => labeler.did)),
    );
  }

  String? get _preferencesCacheKey {
    final accountDid = _accountDid;
    if (accountDid == null || accountDid.isEmpty) {
      return null;
    }

    return 'moderation_preferences::$accountDid';
  }

  String? get _resolvedUserDid {
    final explicitUserDid = _userDid;
    if (explicitUserDid != null && explicitUserDid.isNotEmpty) {
      return explicitUserDid;
    }

    final client = _authRecovery.client;
    return client.oAuthSession?.sub ?? client.session?.did;
  }

  LabelValueDefinition? _labelValueDefinitionForIdentifier(LabelerPolicies? policies, String identifier) {
    if (policies == null) {
      return null;
    }
    for (final definition in policies.labelValueDefinitions ?? const <LabelValueDefinition>[]) {
      if (definition.identifier == identifier) {
        return definition;
      }
    }
    return null;
  }

  String? _localizedLabelName(List<LabelValueDefinitionStrings> locales, Iterable<String> preferredLanguages) {
    if (locales.isEmpty) {
      return null;
    }

    final normalizedLanguages = preferredLanguages
        .map((language) => language.trim().toLowerCase())
        .where((language) => language.isNotEmpty)
        .toList(growable: false);

    for (final language in normalizedLanguages) {
      for (final entry in locales) {
        if (entry.lang.toLowerCase() == language) {
          return entry.name;
        }
      }

      final baseLanguage = language.split(RegExp(r'[-_]')).first;
      for (final entry in locales) {
        final lang = entry.lang.toLowerCase();
        if (lang == baseLanguage || lang.startsWith('$baseLanguage-')) {
          return entry.name;
        }
      }
    }

    for (final entry in locales) {
      if (entry.name.isNotEmpty) {
        return entry.name;
      }
    }

    return null;
  }
}

Map<String, String> _buildLabelerHeaders(Iterable<String> subscribedLabelers) {
  final dids = <String>{
    _officialBlueskyLabelerDid,
    ...subscribedLabelers
        .where((did) => did.startsWith('did:') && did != _officialBlueskyLabelerDid)
        .take(_maxCustomLabelers),
  };

  return {'atproto-accept-labelers': dids.map((did) => '$did;redact').join(', ')};
}
