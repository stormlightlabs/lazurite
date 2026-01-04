/// In-memory store for DPoP nonces provided by servers.
///
/// Servers may require nonces in DPoP proofs for replay protection.
/// The server sends a nonce in the `DPoP-Nonce` response header,
/// and the client must include it in subsequent proofs to that server.
class DPoPNonceStore {
  final Map<String, _Nonce> _nonces = {};

  /// Stores a nonce for the given server URL.
  ///
  /// The server URL should be normalized (e.g., the PDS base URL).
  void store(String serverUrl, String nonce) {
    _nonces[serverUrl] = _Nonce(value: nonce, timestamp: DateTime.now());
  }

  /// Retrieves the stored nonce for the given server URL.
  ///
  /// Returns null if no nonce is stored or if the nonce has expired.
  String? get(String serverUrl) {
    final nonce = _nonces[serverUrl];
    if (nonce == null) return null;

    if (DateTime.now().difference(nonce.timestamp).inMinutes > 5) {
      _nonces.remove(serverUrl);
      return null;
    }

    return nonce.value;
  }

  /// Clears the nonce for a specific server URL.
  ///
  /// This should be called if the server rejects a proof with the stored nonce.
  void clear(String serverUrl) {
    _nonces.remove(serverUrl);
  }

  /// Clears all stored nonces.
  void clearAll() {
    _nonces.clear();
  }

  /// Extracts a nonce from response headers.
  ///
  /// Returns the nonce value if present, null otherwise.
  static String? extractFromHeaders(Map<String, dynamic>? headers) {
    if (headers == null) return null;

    final nonceKey = headers.keys.firstWhere(
      (key) => key.toLowerCase() == 'dpop-nonce',
      orElse: () => '',
    );

    if (nonceKey.isEmpty) return null;

    final value = headers[nonceKey];
    if (value is String) return value;
    if (value is List && value.isNotEmpty) return value.first.toString();

    return null;
  }
}

class _Nonce {
  _Nonce({required this.value, required this.timestamp});

  final String value;
  final DateTime timestamp;
}
