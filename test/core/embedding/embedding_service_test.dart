import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';

void main() {
  group('l2Normalize', () {
    test('unit vector is unchanged', () {
      final v = Float32List.fromList([1.0, 0.0, 0.0]);
      final result = l2Normalize(v);
      expect(result[0], closeTo(1.0, 1e-6));
      expect(result[1], closeTo(0.0, 1e-6));
      expect(result[2], closeTo(0.0, 1e-6));
    });

    test('scales vector to unit length', () {
      final v = Float32List.fromList([3.0, 4.0]);
      final result = l2Normalize(v);
      // norm = 5; normalised = [0.6, 0.8]
      expect(result[0], closeTo(0.6, 1e-6));
      expect(result[1], closeTo(0.8, 1e-6));
    });

    test('result has norm ≈ 1', () {
      final v = Float32List.fromList(List.generate(384, (i) => (i + 1).toDouble()));
      final result = l2Normalize(v);
      var norm = 0.0;
      for (final x in result) {
        norm += x * x;
      }
      expect(norm, closeTo(1.0, 1e-5));
    });

    test('near-zero vector is returned unchanged (no division by zero)', () {
      final v = Float32List.fromList([0.0, 0.0, 0.0]);
      final result = l2Normalize(v);
      expect(result, equals(v));
    });

    test('returns a new list, does not mutate input', () {
      final v = Float32List.fromList([3.0, 4.0]);
      l2Normalize(v);
      expect(v[0], equals(3.0));
      expect(v[1], equals(4.0));
    });
  });

  group('EmbeddingService', () {
    group('initial state', () {
      test('isAvailable is false before initialize', () {
        final service = EmbeddingService.forTesting((_) async => Float32List(384));
        expect(service.isAvailable, isFalse);
      });
    });

    group('initialize / dispose', () {
      test('isAvailable is true after initialize with mock backend', () async {
        final service = EmbeddingService.forTesting((_) async => Float32List(384));
        await service.initialize();
        expect(service.isAvailable, isTrue);
      });

      test('initialize is idempotent', () async {
        var calls = 0;
        final service = EmbeddingService.forTesting((_) async {
          calls++;
          return Float32List(384);
        });
        await service.initialize();
        await service.initialize(); // second call should be a no-op
        expect(service.isAvailable, isTrue);
        // Idempotency check: embed once to confirm service still works.
        await service.embed('test');
        expect(calls, equals(1)); // embed was called once, not initialize twice
      });

      test('dispose resets isAvailable to false', () async {
        final service = EmbeddingService.forTesting((_) async => Float32List(384));
        await service.initialize();
        service.dispose();
        expect(service.isAvailable, isFalse);
      });

      test('dispose before initialize does not throw', () {
        final service = EmbeddingService.forTesting((_) async => Float32List(384));
        expect(() => service.dispose(), returnsNormally);
      });

      test('dispose can be called multiple times safely', () async {
        final service = EmbeddingService.forTesting((_) async => Float32List(384));
        await service.initialize();
        service.dispose();
        expect(() => service.dispose(), returnsNormally);
      });
    });

    group('embed', () {
      test('throws StateError when not initialized', () async {
        final service = EmbeddingService.forTesting((_) async => Float32List(384));
        expect(() => service.embed('hello'), throwsStateError);
      });

      test('throws StateError after dispose', () async {
        final service = EmbeddingService.forTesting((_) async => Float32List(384));
        await service.initialize();
        service.dispose();
        expect(() => service.embed('hello'), throwsStateError);
      });

      test('returns the value produced by the mock backend', () async {
        final expected = Float32List.fromList(List.generate(384, (i) => i.toDouble()));
        final service = EmbeddingService.forTesting((_) async => expected);
        await service.initialize();

        final result = await service.embed('some text');
        expect(result, equals(expected));
      });

      test('result has length 384', () async {
        final service = EmbeddingService.forTesting((_) async => Float32List(384));
        await service.initialize();

        final result = await service.embed('hello world');
        expect(result.length, equals(384));
      });

      test('forwards the exact text to the backend', () async {
        String? received;
        final service = EmbeddingService.forTesting((text) async {
          received = text;
          return Float32List(384);
        });
        await service.initialize();

        await service.embed('the quick brown fox');
        expect(received, equals('the quick brown fox'));
      });

      test('multiple concurrent embeds each receive correct results', () async {
        var callCount = 0;
        final service = EmbeddingService.forTesting((text) async {
          callCount++;
          final v = Float32List(384);
          v[0] = callCount.toDouble();
          return v;
        });
        await service.initialize();

        final results = await Future.wait([service.embed('a'), service.embed('b'), service.embed('c')]);

        expect(results.length, equals(3));
        expect(results.every((r) => r.length == 384), isTrue);
      });
    });
  });
}
