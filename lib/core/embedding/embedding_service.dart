import 'dart:async';
import 'dart:isolate';
import 'dart:math' show sqrt;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lazurite/core/embedding/word_piece_tokenizer.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

final class _SetupData {
  const _SetupData({required this.sendPort, required this.rootIsolateToken});
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;
}

/// A request sent to the isolate: (text, replyPort) or null to dispose.
typedef _EmbedRequest = (String text, SendPort replyPort);

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

Future<void> _isolateEntry(_SetupData setup) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(setup.rootIsolateToken);

  final receivePort = ReceivePort();

  setup.sendPort.send(receivePort.sendPort);

  Interpreter? interpreter;
  WordPieceTokenizer? tokenizer;

  try {
    interpreter = await Interpreter.fromAsset('all-MiniLM-L6-v2-quant.tflite');
    final vocabText = await rootBundle.loadString('assets/vocab.txt');
    tokenizer = WordPieceTokenizer.fromString(vocabText);
    setup.sendPort.send(true);
  } catch (_) {
    setup.sendPort.send(false);
    receivePort.close();
    return;
  }

  await for (final message in receivePort) {
    if (message == null) break;
    final (text, replyPort) = message as _EmbedRequest;
    try {
      final result = _runInference(interpreter, tokenizer, text);
      replyPort.send(result);
    } catch (_) {
      replyPort.send(null);
    }
  }

  interpreter.close();
  receivePort.close();
}

Float32List _runInference(Interpreter interpreter, WordPieceTokenizer tokenizer, String text) {
  final tokenIds = tokenizer.tokenize(text);
  const seqLen = WordPieceTokenizer.maxTokens;

  final inputIds = [tokenIds];
  final attentionMask = [tokenIds.map((id) => id != 0 ? 1 : 0).toList()];
  final tokenTypeIds = [List<int>.filled(seqLen, 0)];

  final outputBuffer = [List<double>.filled(384, 0.0)];
  interpreter.runForMultipleInputs([inputIds, attentionMask, tokenTypeIds], {0: outputBuffer});

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
  Isolate? _isolate;
  SendPort? _isolateSendPort;
  ReceivePort? _setupPort;

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

    final setupPort = ReceivePort();
    _setupPort = setupPort;
    final messages = StreamIterator<dynamic>(setupPort);

    try {
      _isolate = await Isolate.spawn(
        _isolateEntry,
        _SetupData(sendPort: setupPort.sendPort, rootIsolateToken: RootIsolateToken.instance!),
        debugName: 'EmbeddingIsolate',
      );

      await messages.moveNext();
      _isolateSendPort = messages.current as SendPort;

      await messages.moveNext();
      _isAvailable = messages.current as bool;
    } finally {
      await messages.cancel();
      setupPort.close();
      _setupPort = null;
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

    final responsePort = ReceivePort();
    _isolateSendPort!.send((text, responsePort.sendPort));
    final result = await responsePort.first;
    responsePort.close();

    if (result == null) throw StateError('Embedding inference failed for text: "$text"');
    return result as Float32List;
  }

  /// Shut down the background isolate and mark the service as unavailable.
  ///
  /// Safe to call before [initialize] or after [dispose].
  void dispose() {
    _isolateSendPort?.send(null);
    _isolate?.kill(priority: Isolate.immediate);
    _setupPort?.close();
    _isAvailable = false;
    _isolate = null;
    _isolateSendPort = null;
    _setupPort = null;
  }
}
