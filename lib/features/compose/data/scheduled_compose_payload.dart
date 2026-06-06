import 'dart:convert';

class ScheduledComposePayload {
  const ScheduledComposePayload({
    required this.originalText,
    required this.parts,
    this.version = 1,
    this.kind = kindThread,
  });

  static const kindThread = 'thread';

  final int version;
  final String kind;
  final String originalText;
  final List<ScheduledComposePart> parts;

  String encode() => jsonEncode({
    'version': version,
    'kind': kind,
    'originalText': originalText,
    'parts': parts.map((part) => part.toJson()).toList(growable: false),
  });

  static ScheduledComposePayload? tryDecode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      final version = json['version'];
      final kind = json['kind'];
      final originalText = json['originalText'];
      final partsJson = json['parts'];
      if (version != 1 || kind != kindThread || originalText is! String || partsJson is! List) {
        return null;
      }

      final parts = <ScheduledComposePart>[];
      for (final partJson in partsJson) {
        if (partJson is! Map<String, dynamic>) return null;
        final part = ScheduledComposePart.tryDecode(partJson);
        if (part == null) return null;
        parts.add(part);
      }
      if (parts.isEmpty) return null;
      parts.sort((a, b) => a.index.compareTo(b.index));
      for (var i = 0; i < parts.length; i++) {
        if (parts[i].index != i) return null;
      }

      return ScheduledComposePayload(originalText: originalText, parts: parts);
    } catch (_) {
      return null;
    }
  }
}

class ScheduledComposePart {
  const ScheduledComposePart({required this.index, required this.text});

  final int index;
  final String text;

  Map<String, Object?> toJson() => {'index': index, 'text': text};

  static ScheduledComposePart? tryDecode(Map<String, dynamic> json) {
    final index = json['index'];
    final text = json['text'];
    if (index is! int || text is! String || text.trim().isEmpty) return null;
    return ScheduledComposePart(index: index, text: text);
  }
}
