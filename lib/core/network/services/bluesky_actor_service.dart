part of '../poptart_client_adapter.dart';

class BlueskyActorService {
  BlueskyActorService._(this._client);

  final PoptartClient _client;

  Future<XRPCResponse<ActorGetPreferencesOutput>> getPreferences({Map<String, String>? $headers, String? $service}) {
    return _client.call(appBskyActorGetPreferences, headers: $headers, service: $service);
  }

  Future<XRPCResponse<EmptyData>> putPreferences({
    required List<UPreferences> preferences,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyActorPutPreferences,
      headers: $headers,
      service: $service,
      input: ActorPutPreferencesInput(preferences: preferences),
    );
  }

  Future<XRPCResponse<ProfileViewDetailed>> getProfile({
    required String actor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyActorGetProfile,
      headers: $headers,
      service: $service,
      parameters: ActorGetProfileInput(actor: actor),
    );
  }

  Future<XRPCResponse<ActorGetProfilesOutput>> getProfiles({
    required List<String> actors,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyActorGetProfiles,
      headers: $headers,
      service: $service,
      parameters: ActorGetProfilesInput(actors: actors),
    );
  }

  Future<XRPCResponse<ActorSearchActorsOutput>> searchActors({
    String? q,
    int limit = 25,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyActorSearchActors,
      headers: $headers,
      service: $service,
      parameters: ActorSearchActorsInput(q: q, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<ActorSearchActorsTypeaheadOutput>> searchActorsTypeahead({
    String? q,
    int limit = 10,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyActorSearchActorsTypeahead,
      headers: $headers,
      service: $service,
      parameters: ActorSearchActorsTypeaheadInput(q: q, limit: limit),
    );
  }
}
