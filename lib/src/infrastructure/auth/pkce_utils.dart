import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PkceUtils {
  static const _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
  static final _rnd = Random.secure();

  /// Generates a verifier of length between 43 and 128 chars.
  static String generateVerifier() {
    final length = 43 + _rnd.nextInt(86);
    return List.generate(length, (_) => _chars[_rnd.nextInt(_chars.length)]).join();
  }

  static String generateChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}
