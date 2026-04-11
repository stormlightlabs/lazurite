import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/embedding/word_piece_tokenizer.dart';

/// Minimal synthetic vocabulary for fast, isolated tests.
/// Each line is one token; line number (0-indexed) is its ID.
///
/// Mapping:                    ID
///   [PAD]      (padId)       = 0
///   ##a                      = 1
///   ##b                      = 2
///   ##c                      = 3
///   ##bc                     = 4
///   ##un                     = 5
///   ab                       = 6
///   abc                      = 7
///   hello                    = 8
///   world                    = 9
///   [UNK]      (unkId = 100) → not in the 10-token vocab, so words with no
///                              sub-token match will return [UNK]=100 from
///                              the full-vocab constant, but for a synthetic
///                              vocab the 100 will be the literal constant.
///
/// We embed [PAD] × 90 filler entries between index 10 and 99 so that
/// unkId=100, clsId=101, sepId=102 fall at the expected positions.
String _buildVocab() {
  final lines = <String>[];
  lines.add('[PAD]');
  lines.add('##a');
  lines.add('##b');
  lines.add('##c');
  lines.add('##bc');
  lines.add('##un');
  lines.add('ab');
  lines.add('abc');
  lines.add('hello');
  lines.add('world');
  for (var i = 10; i < 100; i++) {
    lines.add('[unused_${i}_]');
  }

  lines.add('[UNK]');
  lines.add('[CLS]');
  lines.add('[SEP]');
  return lines.join('\n');
}

final _vocab = _buildVocab();

void main() {
  late WordPieceTokenizer tokenizer;

  setUp(() {
    tokenizer = WordPieceTokenizer.fromString(_vocab);
  });

  group('WordPieceTokenizer', () {
    group('structure', () {
      test('always returns exactly maxTokens (256) elements', () {
        final result = tokenizer.tokenize('hello');
        expect(result.length, equals(WordPieceTokenizer.maxTokens));
      });

      test('first token is always CLS (101)', () {
        expect(tokenizer.tokenize('hello').first, equals(WordPieceTokenizer.clsId));
        expect(tokenizer.tokenize('').first, equals(WordPieceTokenizer.clsId));
      });

      test('empty string → [CLS, SEP, PAD, PAD, ...]', () {
        final result = tokenizer.tokenize('');
        expect(result[0], equals(WordPieceTokenizer.clsId));
        expect(result[1], equals(WordPieceTokenizer.sepId));
        expect(result.sublist(2), everyElement(equals(WordPieceTokenizer.padId)));
      });

      test('padding fills remaining indices after [SEP] with PAD (0)', () {
        final result = tokenizer.tokenize('hello');
        expect(result.sublist(3), everyElement(equals(WordPieceTokenizer.padId)));
      });
    });

    group('whole-word tokens', () {
      test('known word → its vocab ID', () {
        final result = tokenizer.tokenize('hello');
        expect(result[1], equals(8));
        expect(result[2], equals(WordPieceTokenizer.sepId));
      });

      test('two known words → two IDs between CLS and SEP', () {
        final result = tokenizer.tokenize('hello world');
        expect(result[0], equals(WordPieceTokenizer.clsId));
        expect(result[1], equals(8));
        expect(result[2], equals(9));
        expect(result[3], equals(WordPieceTokenizer.sepId));
      });
    });

    group('wordpiece sub-word splitting', () {
      test('word not in vocab but has valid subword decomposition', () {
        final result = tokenizer.tokenize('abc');
        expect(result[1], equals(7));
      });

      test('sub-word fallback: ab + ##c → [6, 3]', () {
        final result = tokenizer.tokenize('abbc');
        expect(result[1], equals(6));
        expect(result[2], equals(4));
        expect(result[3], equals(WordPieceTokenizer.sepId));
      });

      test('word with no valid sub-token decomposition → UNK', () {
        final result = tokenizer.tokenize('xyz');
        expect(result[1], equals(WordPieceTokenizer.unkId));
        expect(result[2], equals(WordPieceTokenizer.sepId));
      });
    });

    group('truncation', () {
      test('very long text is truncated to maxTokens with SEP preserved', () {
        final longText = ('hello ' * 300).trim();
        final result = tokenizer.tokenize(longText);
        expect(result.length, equals(WordPieceTokenizer.maxTokens));

        final lastNonPad = result.lastIndexWhere((id) => id != WordPieceTokenizer.padId);
        expect(result[lastNonPad], equals(WordPieceTokenizer.sepId));
      });

      test('text of exactly maxTokens - 2 content tokens fits without truncation', () {
        final words = List.filled(254, 'hello');
        final result = tokenizer.tokenize(words.join(' '));
        expect(result[0], equals(WordPieceTokenizer.clsId));
        expect(result[255], equals(WordPieceTokenizer.sepId));
        expect(result.contains(WordPieceTokenizer.padId), isFalse);
      });
    });

    group('case', () {
      test('input is case-folded to lowercase before tokenisation', () {
        final lower = tokenizer.tokenize('hello');
        final upper = tokenizer.tokenize('HELLO');
        expect(lower, equals(upper));
      });
    });

    group('punctuation', () {
      test('punctuation is split as individual tokens', () {
        final result = tokenizer.tokenize('hello,world');
        expect(result[0], equals(WordPieceTokenizer.clsId));
        expect(result[1], equals(8));
        expect(result[2], equals(WordPieceTokenizer.unkId));
        expect(result[3], equals(9));
        expect(result[4], equals(WordPieceTokenizer.sepId));
      });
    });

    group('fromString factory', () {
      test('handles Windows-style CRLF line endings', () {
        final crlfVocab = _buildVocab().replaceAll('\n', '\r\n');
        final crlfTokenizer = WordPieceTokenizer.fromString(crlfVocab);
        final result = crlfTokenizer.tokenize('hello');
        expect(result[1], equals(8));
      });

      test('skips blank trailing line if present', () {
        final withTrailing = '${_buildVocab()}\n';
        final t = WordPieceTokenizer.fromString(withTrailing);
        final result = t.tokenize('hello');
        expect(result[1], equals(8));
      });
    });
  });
}
