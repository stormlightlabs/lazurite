import 'dart:async';
import 'dart:math' show sqrt;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lazurite/core/logging/app_logger.dart';
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
  Interpreter interpreter,
  IsolateInterpreter isolateInterpreter,
  WordPieceTokenizer tokenizer,
  String text,
) async {
  final tokenIds = tokenizer.tokenize(text);
  const seqLen = WordPieceTokenizer.maxTokens;

  final inputIds = [tokenIds];
  final attentionMask = [tokenIds.map((id) => id != 0 ? 1 : 0).toList(growable: false)];
  final tokenTypeIds = [List<int>.filled(seqLen, 0)];

  final inputTensors = interpreter.getInputTensors();
  final inputs = _buildModelInputs(
    inputTensors,
    inputIds: inputIds,
    attentionMask: attentionMask,
    tokenTypeIds: tokenTypeIds,
  );

  final outputTensors = interpreter.getOutputTensors();
  if (outputTensors.isEmpty) {
    throw StateError('Embedding model has no output tensors.');
  }
  final outputs = <int, Object>{
    for (var i = 0; i < outputTensors.length; i++) i: _allocateTensorBuffer(outputTensors[i].shape),
  };
  await isolateInterpreter.runForMultipleInputs(inputs, outputs);

  final embedding = _extractEmbeddingFromModelOutput(outputs[0], attentionMask.first);
  return l2Normalize(embedding);
}

List<Object> _buildModelInputs(
  List<Tensor> inputTensors, {
  required List<List<int>> inputIds,
  required List<List<int>> attentionMask,
  required List<List<int>> tokenTypeIds,
}) {
  if (inputTensors.isEmpty) {
    return const [];
  }

  final inputs = List<Object>.filled(inputTensors.length, inputIds, growable: false);
  var assignedInputIds = false;
  var assignedAttentionMask = false;
  var assignedTokenTypes = false;

  for (var i = 0; i < inputTensors.length; i++) {
    final name = inputTensors[i].name.toLowerCase();
    if ((name.contains('input') && name.contains('id') && !name.contains('token_type')) ||
        (name.contains('token') && name.contains('ids') && !name.contains('type'))) {
      inputs[i] = inputIds;
      assignedInputIds = true;
      continue;
    }
    if (name.contains('attention') || name.contains('mask')) {
      inputs[i] = attentionMask;
      assignedAttentionMask = true;
      continue;
    }
    if (name.contains('token_type') || name.contains('segment')) {
      inputs[i] = tokenTypeIds;
      assignedTokenTypes = true;
      continue;
    }
  }

  // Fallback mapping when tensor names are opaque or stripped.
  if (!assignedInputIds && inputTensors.isNotEmpty) {
    inputs[0] = inputIds;
  }
  if (!assignedAttentionMask && inputTensors.length >= 2) {
    inputs[1] = attentionMask;
  }
  if (!assignedTokenTypes && inputTensors.length >= 3) {
    inputs[2] = tokenTypeIds;
  }
  return inputs;
}

Object _allocateTensorBuffer(List<int> shape) {
  final normalizedShape = shape.map((dimension) => dimension > 0 ? dimension : 1).toList(growable: false);
  if (normalizedShape.isEmpty) {
    return 0.0;
  }
  return _allocateTensorBufferRecursive(normalizedShape, 0);
}

Object _allocateTensorBufferRecursive(List<int> shape, int depth) {
  final size = shape[depth];
  if (depth == shape.length - 1) {
    return List<double>.filled(size, 0.0, growable: false);
  }
  return List.generate(size, (_) => _allocateTensorBufferRecursive(shape, depth + 1), growable: false);
}

Float32List _extractEmbeddingFromModelOutput(Object? output, List<int> attentionMask) {
  if (output is! List || output.isEmpty) {
    throw StateError('Embedding model output is empty or invalid.');
  }

  final first = output.first;
  if (first is List<double>) {
    return Float32List.fromList(first);
  }

  // [batch, seq, hidden] shape: mean-pool token embeddings.
  if (first is List && first.isNotEmpty && first.first is List<double>) {
    final tokenRows = first.cast<List<double>>();
    final hiddenSize = tokenRows.first.length;
    final pooled = List<double>.filled(hiddenSize, 0.0, growable: false);
    var counted = 0;

    for (var i = 0; i < tokenRows.length && i < attentionMask.length; i++) {
      if (attentionMask[i] == 0) {
        continue;
      }
      final row = tokenRows[i];
      if (row.length != hiddenSize) {
        continue;
      }
      counted++;
      for (var j = 0; j < hiddenSize; j++) {
        pooled[j] = pooled[j] + row[j];
      }
    }

    if (counted == 0) {
      return Float32List(hiddenSize);
    }
    for (var i = 0; i < hiddenSize; i++) {
      pooled[i] = pooled[i] / counted;
    }
    return Float32List.fromList(pooled);
  }

  throw StateError('Embedding model output shape is unsupported.');
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

  static const String _modelAssetFile = 'all-MiniLM-L6-v2-quant.tflite';
  static const String _vocabAssetFile = 'vocab.txt';
  static const List<String> _modelAssetCandidates = ['assets/$_modelAssetFile', _modelAssetFile];
  static const List<String> _vocabAssetCandidates = ['assets/$_vocabAssetFile', _vocabAssetFile];

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
        interpreter = await _loadInterpreterFromAssets();
        isolateInterpreter = await IsolateInterpreter.create(
          address: interpreter.address,
          debugName: 'EmbeddingInferenceIsolate',
        );
        final vocabText = await _loadVocabFromAssets();
        final tokenizer = WordPieceTokenizer.fromString(vocabText);
        final inputTensors = interpreter.getInputTensors();
        final outputTensors = interpreter.getOutputTensors();
        log.i(
          'EmbeddingService initialized with ${inputTensors.length} input(s): '
          '${inputTensors.map((tensor) => '${tensor.name}${tensor.shape}').join(', ')} '
          'and ${outputTensors.length} output(s): '
          '${outputTensors.map((tensor) => '${tensor.name}${tensor.shape}').join(', ')}',
        );
        _interpreter = interpreter;
        _isolateInterpreter = isolateInterpreter;
        _tokenizer = tokenizer;
        _isAvailable = true;
      } catch (error, stackTrace) {
        if (isolateInterpreter != null) {
          await isolateInterpreter.close();
        }
        interpreter?.close();
        _interpreter = null;
        _isolateInterpreter = null;
        _tokenizer = null;
        _isAvailable = false;
        log.e('EmbeddingService initialization failed', error: error, stackTrace: stackTrace);
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
    final interpreter = _interpreter;
    final tokenizer = _tokenizer;
    if (isolateInterpreter == null || interpreter == null || tokenizer == null) {
      throw StateError('EmbeddingService is not fully initialized.');
    }
    return _runInference(interpreter, isolateInterpreter, tokenizer, text);
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

  Future<Interpreter> _loadInterpreterFromAssets() async {
    Object? lastError;
    StackTrace? lastStackTrace;
    for (final asset in _modelAssetCandidates) {
      try {
        return await Interpreter.fromAsset(asset);
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
      }
    }

    if (lastError != null && lastStackTrace != null) {
      Error.throwWithStackTrace(lastError, lastStackTrace);
    }
    throw StateError('Unable to load embedding model asset.');
  }

  Future<String> _loadVocabFromAssets() async {
    Object? lastError;
    StackTrace? lastStackTrace;
    for (final asset in _vocabAssetCandidates) {
      try {
        return await rootBundle.loadString(asset);
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
      }
    }

    if (lastError != null && lastStackTrace != null) {
      Error.throwWithStackTrace(lastError, lastStackTrace);
    }
    throw StateError('Unable to load embedding vocabulary asset.');
  }
}
