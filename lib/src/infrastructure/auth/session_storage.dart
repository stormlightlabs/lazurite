import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/auth/session_model.dart';

class SessionStorage {
  SessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _keySession = 'lazurite_session';

  Future<void> saveSession(Session session) async {
    final jsonString = jsonEncode(session.toJson());
    await _storage.write(key: _keySession, value: jsonString);
  }

  Future<Session?> getSession() async {
    final jsonString = await _storage.read(key: _keySession);
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Session.fromJson(json);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _keySession);
  }
}
