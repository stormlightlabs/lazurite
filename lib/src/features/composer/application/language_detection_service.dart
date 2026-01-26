import 'package:language_detector/language_detector.dart';

/// Service for detecting languages from text content.
///
/// Provides automatic language detection with manual override support.
/// Uses Google Translate's language detection and falls back
/// to 'en' for ambiguous or very short text.
class LanguageDetectionService {
  LanguageDetectionService();

  static const int _minimumTextLength = 10;
  static const String _defaultLanguage = 'en';

  /// Detect primary language from text.
  ///
  /// Returns null if text is too short or detection fails.
  /// Returns ISO 639-1 language code (e.g., 'en', 'es', 'ja').
  Future<String?> detectLanguage(String text) async {
    if (text.trim().length < _minimumTextLength) {
      return null;
    }

    /// In order:
    /// 1. Emoticons
    /// 2. Misc Symbols and Pictographs
    /// 3. Transport and Map
    /// 4. Flags (iOS)
    /// 5. Misc symbols
    /// 6. Dingbats
    final hasNonEmoji = text
        .replaceAll(
          RegExp(
            '[\u{1F600}-\u{1F64F}]'
            '|[\u{1F300}-\u{1F5FF}]'
            '|[\u{1F680}-\u{1F6FF}]'
            '|[\u{1F1E0}-\u{1F1FF}]'
            '|[\u{2600}-\u{26FF}]'
            '|[\u{2700}-\u{27BF}]',
            unicode: true,
          ),
          '',
        )
        .trim()
        .isNotEmpty;

    if (!hasNonEmoji) {
      return null;
    }

    try {
      final detected = await LanguageDetector.getLanguageCode(content: text);

      if (detected.isEmpty || detected == 'auto') {
        return _defaultLanguage;
      }

      return detected;
    } catch (_) {
      return null;
    }
  }

  /// Validate a language code against ISO 639-1/639-2 standards.
  static bool isValidLanguageCode(String code) {
    if (code.length != 2 && code.length != 3) {
      return false;
    }

    return RegExp(r'^[a-z]{2,3}$').hasMatch(code);
  }
}
