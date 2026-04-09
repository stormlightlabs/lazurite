import 'package:characters/characters.dart';

/// BERT-style WordPiece tokenizer compatible with all-MiniLM-L6-v2.
///
/// Converts text to token IDs using the standard BERT uncased vocabulary.
/// The returned list always has exactly [maxTokens] elements.
///
/// Token ID conventions (BERT-base-uncased):
///   [PAD]  = 0
///   [UNK]  = 100
///   [CLS]  = 101
///   [SEP]  = 102
class WordPieceTokenizer {
  WordPieceTokenizer._(this._vocab);

  /// Constructs a tokenizer from the raw contents of a vocab file.
  ///
  /// Each line is one token; its line number (0-indexed) is its ID.
  factory WordPieceTokenizer.fromString(String vocabText) {
    final vocab = <String, int>{};
    var index = 0;
    for (final line in vocabText.split('\n')) {
      final token = line.trimRight();
      if (token.isNotEmpty) {
        vocab[token] = index;
      }
      index++;
    }
    return WordPieceTokenizer._(vocab);
  }
  static const int padId = 0;
  static const int unkId = 100;
  static const int clsId = 101;
  static const int sepId = 102;
  static const int maxTokens = 256;

  final Map<String, int> _vocab;

  /// Tokenize [text] into a list of token IDs padded/truncated to [maxTokens].
  ///
  /// Layout: `[CLS] token_ids... [SEP] [PAD]...`
  List<int> tokenize(String text) {
    final cleaned = _cleanText(text.toLowerCase());
    final basicTokens = _basicTokenize(cleaned);

    final ids = <int>[clsId];
    for (final word in basicTokens) {
      final pieces = _wordPiece(word);

      if (ids.length + pieces.length >= maxTokens) {
        ids.addAll(pieces.take(maxTokens - ids.length - 1));
        break;
      }
      ids.addAll(pieces);
    }
    ids.add(sepId);

    while (ids.length < maxTokens) {
      ids.add(padId);
    }

    return ids;
  }

  /// Remove control characters and normalize whitespace.
  String _cleanText(String text) {
    final buf = StringBuffer();
    for (final char in text.characters) {
      final cp = char.codeUnitAt(0);
      if (cp == 0 || cp == 0xFFFD || _isControlChar(cp)) continue;
      buf.write(_isWhitespace(cp) ? ' ' : char);
    }
    return buf.toString();
  }

  /// Split on whitespace and punctuation to produce basic tokens.
  List<String> _basicTokenize(String text) {
    final tokens = <String>[];
    final buf = StringBuffer();
    for (final char in text.characters) {
      final cp = char.codeUnitAt(0);
      if (_isWhitespace(cp)) {
        if (buf.isNotEmpty) {
          tokens.add(buf.toString());
          buf.clear();
        }
      } else if (_isPunctuation(cp)) {
        if (buf.isNotEmpty) {
          tokens.add(buf.toString());
          buf.clear();
        }
        tokens.add(char);
      } else {
        buf.write(char);
      }
    }
    if (buf.isNotEmpty) tokens.add(buf.toString());
    return tokens;
  }

  /// WordPiece sub-word tokenization for a single [word].
  ///
  /// Returns `[unkId]` if no valid segmentation exists.
  List<int> _wordPiece(String word) {
    if (word.isEmpty) return [];
    if (_vocab.containsKey(word)) return [_vocab[word]!];

    final result = <int>[];
    var start = 0;

    while (start < word.length) {
      var end = word.length;
      int? foundId;
      int? foundLen;

      while (start < end) {
        final sub = start == 0 ? word.substring(0, end) : '##${word.substring(start, end)}';
        if (_vocab.containsKey(sub)) {
          foundId = _vocab[sub]!;
          foundLen = end - start;
          break;
        }
        end--;
      }

      if (foundId == null) return [unkId];

      result.add(foundId);
      start += foundLen!;
    }

    return result;
  }

  bool _isWhitespace(int cp) => cp == 0x20 || cp == 0x09 || cp == 0x0A || cp == 0x0D;

  bool _isControlChar(int cp) => (cp < 0x20 && !_isWhitespace(cp)) || (cp >= 0x7F && cp <= 0x9F);

  bool _isPunctuation(int cp) =>
      (cp >= 33 && cp <= 47) ||
      (cp >= 58 && cp <= 64) ||
      (cp >= 91 && cp <= 96) ||
      (cp >= 123 && cp <= 126) ||
      (cp >= 0x2000 && cp <= 0x206F) ||
      (cp >= 0x2E00 && cp <= 0x2E7F) ||
      (cp >= 0x3000 && cp <= 0x303F);
}
