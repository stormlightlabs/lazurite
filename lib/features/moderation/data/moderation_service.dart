import 'dart:async';

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/labeler/defs.dart';
import 'package:bluesky_poptart/app/bsky/labeler/get_services.dart';
import 'package:bluesky_poptart/app/bsky/notification/list_notifications.dart' as notifications;
import 'package:lazurite/core/cache/poptart_cache_codecs.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/features/moderation/domain/moderation_models.dart' as moderation;
import 'package:poptart_lex/com/atproto/label/defs.dart';

const _officialBlueskyLabelerDid = 'did:plc:ar7c4by46qjdydhdevvrndac';
const _maxCustomLabelers = 20;
const _noUnauthenticatedLabel = '!no-unauthenticated';

class ModerationService {
  ModerationService({
    required Bluesky bluesky,
    AppDatabase? database,
    String? accountDid,
    String? userDid,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
  }) : _bluesky = bluesky,
       _database = database,
       _accountDid = accountDid,
       _userDid = userDid,
       _publicReadOnly = false,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ) {
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
  }) : _bluesky = bluesky,
       _database = database,
       _accountDid = null,
       _userDid = null,
       _publicReadOnly = true,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ) {
    _headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.labeler.getServices',
      _buildLabelerHeaders(const []),
    );
  }

  final Bluesky _bluesky;
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

    final response = await _bluesky.labeler.getServices(
      dids: labelerDids,
      detailed: true,
      $headers: await headersForRequest(),
    );

    await _cacheLabelerPolicies(response.data.views);
    return response.data.views;
  }

  Future<LabelerViewDetailed?> getLabelerDetails(String did) async {
    final response = await _bluesky.labeler.getServices(
      dids: [did],
      detailed: true,
      $headers: await headersForRequest(),
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
      return const moderation.ModerationDecision.empty();
    }

    return moderation.ModerationDecision(
      me: post.author.did == _resolvedUserDid,
      causes: [
        if (_hasAuthenticatedViewer(opts) && opts.prefs.hiddenPosts.contains(post.uri.toString())) _hiddenCause(),
        ..._viewerCauses(post.author.viewer, opts),
        ..._labelCauses(post.labels ?? const [], moderation.LabelTarget.content, opts),
        ..._labelCauses(post.author.labels ?? const [], moderation.LabelTarget.account, opts),
      ],
    );
  }

  moderation.ModerationDecision moderateProfile(ProfileView profile) {
    final opts = _opts;
    if (opts == null) {
      return const moderation.ModerationDecision.empty();
    }

    return _moderateActor(did: profile.did, viewer: profile.viewer, labels: profile.labels ?? const [], opts: opts);
  }

  moderation.ModerationDecision moderateProfileBasic(ProfileViewBasic profile) {
    final opts = _opts;
    if (opts == null) {
      return const moderation.ModerationDecision.empty();
    }

    return _moderateActor(did: profile.did, viewer: profile.viewer, labels: profile.labels ?? const [], opts: opts);
  }

  moderation.ModerationDecision moderateProfileDetailed(ProfileViewDetailed profile) {
    final opts = _opts;
    if (opts == null) {
      return const moderation.ModerationDecision.empty();
    }

    return _moderateActor(did: profile.did, viewer: profile.viewer, labels: profile.labels ?? const [], opts: opts);
  }

  moderation.ModerationDecision moderateNotification(notifications.Notification notification) {
    final opts = _opts;
    if (opts == null) {
      return const moderation.ModerationDecision.empty();
    }

    return moderation.ModerationDecision.merge([
      _moderateActor(
        did: notification.author.did,
        viewer: notification.author.viewer,
        labels: notification.author.labels ?? const [],
        opts: opts,
      ),
      moderation.ModerationDecision(
        me: notification.author.did == _resolvedUserDid,
        causes: _labelCauses(notification.labels ?? const [], moderation.LabelTarget.content, opts),
      ),
    ]);
  }

  moderation.ModerationDecision _moderateActor({
    required String did,
    required dynamic viewer,
    required List<Label> labels,
    required moderation.ModerationOpts opts,
  }) {
    return moderation.ModerationDecision(
      me: did == _resolvedUserDid,
      causes: [
        ..._viewerCauses(viewer, opts),
        ..._labelCauses(labels, moderation.LabelTarget.account, opts),
        ..._labelCauses(labels, moderation.LabelTarget.profile, opts),
      ],
    );
  }

  List<moderation.ModerationCause> _viewerCauses(dynamic viewer, moderation.ModerationOpts opts) {
    if (!_hasAuthenticatedViewer(opts)) {
      return const [];
    }

    if (viewer == null) {
      return const [];
    }

    final causes = <moderation.ModerationCause>[];
    try {
      if (viewer.muted == true) {
        causes.add(_mutedCause());
      }
      if (viewer.blockedBy == true) {
        causes.add(_blockedByCause());
      }
      if (viewer.blocking != null) {
        causes.add(_blockingCause());
      }
    } catch (error, stackTrace) {
      log.d('Unable to read moderation viewer state: $error\n$stackTrace');
    }
    return causes;
  }

  List<moderation.ModerationCause> _labelCauses(
    List<Label> labels,
    moderation.LabelTarget target,
    moderation.ModerationOpts opts,
  ) {
    return labels
        .map((label) => _labelCause(label, target, opts))
        .whereType<moderation.ModerationCause>()
        .toList(growable: false);
  }

  moderation.ModerationCause? _labelCause(Label label, moderation.LabelTarget target, moderation.ModerationOpts opts) {
    if (label.val == _noUnauthenticatedLabel && _hasAuthenticatedViewer(opts)) {
      return null;
    }

    final definition = _definitionForLabel(label, opts);
    if (definition == null) {
      return null;
    }

    final labeler = opts.prefs.labelers.where((item) => item.did == label.src).firstOrNull;
    final isSelf = label.src == _resolvedUserDid;
    if (!isSelf && labeler == null && !moderation.knownLabelDefinitions.containsKey(label.val)) {
      return null;
    }

    final setting = _preferenceForLabel(definition, labeler, opts.prefs);
    if (setting == moderation.LabelPreference.ignore) {
      return null;
    }

    return moderation.ModerationCause.label(
      data: moderation.ModerationCauseLabel(
        source: isSelf || labeler == null
            ? const moderation.ModerationCauseSource.user(data: moderation.ModerationCauseSourceUser())
            : moderation.ModerationCauseSource.labeler(data: moderation.ModerationCauseSourceLabeler(did: labeler.did)),
        label: label,
        labelDef: definition,
        target: target,
        setting: setting,
        behavior: definition.behaviorForTarget(target),
        noOverride: definition.noOverride || (definition.adultOnly && !opts.prefs.adultContentEnabled),
      ),
    );
  }

  bool _hasAuthenticatedViewer(moderation.ModerationOpts opts) => opts.userDid != null && opts.userDid!.isNotEmpty;

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
      final prefsResponse = await _bluesky.actor.getPreferences($headers: headers);
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
    await _bluesky.actor.putPreferences(preferences: preferences, $headers: headers);
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
      final response = await _bluesky.labeler.getServices(
        dids: labelerDids,
        detailed: true,
        $headers: _buildHeadersForPrefs(prefs),
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
    var adultContentEnabled = false;
    final globalLabels = <String, moderation.LabelPreference>{};
    final labelsByLabeler = <String, Map<String, moderation.LabelPreference>>{};
    final labelerDids = <String>{_officialBlueskyLabelerDid};
    final mutedWords = <MutedWord>[];
    final hiddenPosts = <String>[];

    for (final preference in preferences) {
      if (preference.isAdultContentPref) {
        adultContentEnabled = preference.adultContentPref!.enabled;
      } else if (preference.isContentLabelPref) {
        final contentLabel = preference.contentLabelPref!;
        final value = _labelPreferenceFromVisibility(contentLabel.visibility);
        if (value == null) {
          continue;
        }
        final labelerDid = contentLabel.labelerDid;
        if (labelerDid == null || labelerDid.isEmpty) {
          globalLabels[contentLabel.label] = value;
        } else {
          labelsByLabeler.putIfAbsent(labelerDid, () => {})[contentLabel.label] = value;
        }
      } else if (preference.isLabelersPref) {
        labelerDids.addAll(
          preference.labelersPref!.labelers.map((labeler) => labeler.did).where((did) => did.startsWith('did:')),
        );
      } else if (preference.isMutedWordsPref) {
        mutedWords.addAll(preference.mutedWordsPref!.items);
      } else if (preference.isHiddenPostsPref) {
        hiddenPosts.addAll(preference.hiddenPostsPref!.items.map((uri) => uri.toString()));
      }
    }

    return moderation.ModerationPrefs(
      adultContentEnabled: adultContentEnabled,
      labels: globalLabels,
      labelers: labelerDids
          .map((did) => moderation.ModerationPrefsLabeler(did: did, labels: labelsByLabeler[did] ?? const {}))
          .toList(growable: false),
      mutedWords: mutedWords,
      hiddenPosts: hiddenPosts,
    );
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

  moderation.InterpretedLabelValueDefinition? _definitionForLabel(Label label, moderation.ModerationOpts opts) {
    final custom = opts.labelDefs[label.src]?.where((definition) => definition.identifier == label.val).firstOrNull;
    if (custom != null) {
      return custom.withDefinedBy(label.src);
    }
    return moderation.knownLabelDefinitions[label.val]?.withDefinedBy(label.src);
  }

  moderation.LabelPreference _preferenceForLabel(
    moderation.InterpretedLabelValueDefinition definition,
    moderation.ModerationPrefsLabeler? labeler,
    moderation.ModerationPrefs prefs,
  ) {
    if (!definition.configurable) {
      return definition.defaultSetting;
    }
    if (definition.adultOnly && !prefs.adultContentEnabled) {
      return moderation.LabelPreference.hide;
    }
    return labeler?.labels[definition.identifier] ?? prefs.labels[definition.identifier] ?? definition.defaultSetting;
  }

  moderation.LabelPreference? _labelPreferenceFromVisibility(ContentLabelPrefVisibility visibility) {
    return switch (visibility.toJson()) {
      'ignore' || 'show' => moderation.LabelPreference.ignore,
      'warn' => moderation.LabelPreference.warn,
      'hide' => moderation.LabelPreference.hide,
      _ => null,
    };
  }

  moderation.ModerationCause _hiddenCause() {
    return const moderation.ModerationCause.hidden(
      data: moderation.ModerationCauseHidden(
        source: moderation.ModerationCauseSource.user(data: moderation.ModerationCauseSourceUser()),
      ),
    );
  }

  moderation.ModerationCause _mutedCause() {
    return const moderation.ModerationCause.muted(
      data: moderation.ModerationCauseMuted(
        source: moderation.ModerationCauseSource.user(data: moderation.ModerationCauseSourceUser()),
      ),
    );
  }

  moderation.ModerationCause _blockingCause() {
    return const moderation.ModerationCause.blocking(
      data: moderation.ModerationCauseBlocking(
        source: moderation.ModerationCauseSource.user(data: moderation.ModerationCauseSourceUser()),
      ),
    );
  }

  moderation.ModerationCause _blockedByCause() {
    return const moderation.ModerationCause.blockedBy(
      data: moderation.ModerationCauseBlockedBy(
        source: moderation.ModerationCauseSource.user(data: moderation.ModerationCauseSourceUser()),
      ),
    );
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

    return _bluesky.oAuthSession?.sub ?? _bluesky.session?.did;
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
