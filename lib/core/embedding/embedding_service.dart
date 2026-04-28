import 'dart:async';
import 'dart:math' show sqrt;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lazurite/core/embedding/word_piece_tokenizer.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// L2-normalize [vector], returning a new [Float32List].
///
/// If the norm is near zero the original vector is returned unchanged.
@visibleForTesting
Float32List l2Normalize(Float32List vector) {
  var norm = 0.0;
  for (var i = 0; i < vector.length; i++) {
    norm += vector[i] * vector[i];
  }
  norm = sqrt(norm);
  if (norm < 1e-10) return vector;
  final out = Float32List(vector.length);
  for (var i = 0; i < vector.length; i++) {
    out[i] = vector[i] / norm;
  }
  return out;
}

Future<Float32List> _runInference(
  IsolateInterpreter isolateInterpreter,
  WordPieceTokenizer tokenizer,
  String text,
) async {
  final tokenIds = tokenizer.tokenize(text);
  const seqLen = WordPieceTokenizer.maxTokens;

  final inputIds = [tokenIds];
  final attentionMask = [tokenIds.map((id) => id != 0 ? 1 : 0).toList()];
  final tokenTypeIds = [List<int>.filled(seqLen, 0)];

  final outputBuffer = [List<double>.filled(384, 0.0)];
  await isolateInterpreter.runForMultipleInputs([inputIds, attentionMask, tokenTypeIds], {0: outputBuffer});

  return l2Normalize(Float32List.fromList(outputBuffer[0]));
}

/// On-device text embedding service backed by a long-lived background [Isolate].
///
/// Start with [initialize], shut down with [dispose]. Check [isAvailable]
/// before calling [embed]; the flag is false when the model fails to load or
/// when the service has not yet been initialised.
class EmbeddingService {
  /// Creates a real embedding service backed by TFLite + Isolate.
  EmbeddingService() : _mockEmbedFn = null;

  /// Creates a test double that bypasses the Isolate and TFLite entirely.
  ///
  /// [embedFn] is called synchronously (from the caller's perspective) on every
  /// [embed] invocation. [initialize] immediately sets [isAvailable] to true.
  @visibleForTesting
  EmbeddingService.forTesting(Future<Float32List> Function(String text) embedFn) : _mockEmbedFn = embedFn;

  final Future<Float32List> Function(String text)? _mockEmbedFn;

  bool _isAvailable = false;
  Future<void>? _initialization;
  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  WordPieceTokenizer? _tokenizer;

  /// Whether the service is ready to produce embeddings.
  ///
  /// False until [initialize] completes successfully, and false again after
  /// [dispose] is called or if the model failed to load.
  bool get isAvailable => _isAvailable;

  /// Initialise the service.
  ///
  /// For the real implementation this spawns a background [Isolate], loads the
  /// TFLite model, and builds the [WordPieceTokenizer]. For the test double it
  /// is a no-op that marks the service as available.
  ///
  /// Safe to call multiple times; subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_isAvailable) return;
    if (_mockEmbedFn != null) {
      _isAvailable = true;
      return;
    }
    if (_initialization != null) {
      await _initialization;
      return;
    }

    Future<void> doInitialize() async {
      Interpreter? interpreter;
      IsolateInterpreter? isolateInterpreter;
      try {
        interpreter = await Interpreter.fromAsset('all-MiniLM-L6-v2-quant.tflite');
        isolateInterpreter = await IsolateInterpreter.create(
          address: interpreter.address,
          debugName: 'EmbeddingInferenceIsolate',
        );
        final vocabText = await rootBundle.loadString('assets/vocab.txt');
        final tokenizer = WordPieceTokenizer.fromString(vocabText);
        _interpreter = interpreter;
        _isolateInterpreter = isolateInterpreter;
        _tokenizer = tokenizer;
        _isAvailable = true;
      } catch (_) {
        if (isolateInterpreter != null) {
          await isolateInterpreter.close();
        }
        interpreter?.close();
        _interpreter = null;
        _isolateInterpreter = null;
        _tokenizer = null;
        _isAvailable = false;
      }
    }

    _initialization = doInitialize();
    try {
      await _initialization;
    } finally {
      _initialization = null;
    }
  }

  /// Embed [text] and return an L2-normalised [Float32List] of length 384.
  ///
  /// Throws [StateError] if the service is not available.
  Future<Float32List> embed(String text) async {
    if (!_isAvailable) {
      throw StateError('EmbeddingService is not available. Call initialize() first.');
    }

    if (_mockEmbedFn != null) {
      return _mockEmbedFn(text);
    }

    final isolateInterpreter = _isolateInterpreter;
    final tokenizer = _tokenizer;
    if (isolateInterpreter == null || tokenizer == null) {
      throw StateError('EmbeddingService is not fully initialized.');
    }
    return _runInference(isolateInterpreter, tokenizer, text);
  }

  /// Shut down the background isolate and mark the service as unavailable.
  ///
  /// Safe to call before [initialize] or after [dispose].
  void dispose() {
    final isolateInterpreter = _isolateInterpreter;
    if (isolateInterpreter != null) {
      unawaited(isolateInterpreter.close());
    }
    _interpreter?.close();
    _isAvailable = false;
    _interpreter = null;
    _isolateInterpreter = null;
    _tokenizer = null;
    _initialization = null;
  }
}
