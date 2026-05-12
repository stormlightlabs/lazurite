part of '../poptart_client_adapter.dart';

class BlueskyNotificationService {
  BlueskyNotificationService._(this._client);

  final PoptartClient _client;

  Future<XRPCResponse<NotificationListNotificationsOutput>> listNotifications({
    List<String>? reasons,
    int limit = 50,
    bool? priority,
    String? cursor,
    DateTime? seenAt,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyNotificationListNotifications,
      headers: $headers,
      service: $service,
      parameters: NotificationListNotificationsInput(
        reasons: reasons,
        limit: limit,
        priority: priority,
        cursor: cursor,
        seenAt: seenAt,
      ),
    );
  }

  Future<XRPCResponse<NotificationGetUnreadCountOutput>> getUnreadCount({
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(appBskyNotificationGetUnreadCount, headers: $headers, service: $service);
  }

  Future<XRPCResponse<EmptyData>> updateSeen({
    required DateTime seenAt,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyNotificationUpdateSeen,
      headers: $headers,
      service: $service,
      input: NotificationUpdateSeenInput(seenAt: seenAt),
    );
  }

  Future<XRPCResponse<EmptyData>> registerPush({
    required String serviceDid,
    required String token,
    required NotificationRegisterPushPlatform platform,
    required String appId,
    bool? ageRestricted,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyNotificationRegisterPush,
      headers: $headers,
      service: $service,
      input: NotificationRegisterPushInput(
        serviceDid: serviceDid,
        token: token,
        platform: platform,
        appId: appId,
        ageRestricted: ageRestricted,
      ),
    );
  }

  Future<XRPCResponse<EmptyData>> unregisterPush({
    required String serviceDid,
    required String token,
    required NotificationUnregisterPushPlatform platform,
    required String appId,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyNotificationUnregisterPush,
      headers: $headers,
      service: $service,
      input: NotificationUnregisterPushInput(serviceDid: serviceDid, token: token, platform: platform, appId: appId),
    );
  }
}
