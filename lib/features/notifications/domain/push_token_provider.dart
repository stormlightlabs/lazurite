abstract class PushTokenProvider {
  Future<void> initialize();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  Future<void> dispose();
}
