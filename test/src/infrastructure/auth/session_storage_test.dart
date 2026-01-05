import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SessionStorage sessionStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    sessionStorage = SessionStorage(storage: mockStorage);
  });

  const keySession = 'lazurite_session';
  final testSession = Session(
    did: 'did:plc:123',
    handle: 'test.bsky.social',
    accessJwt: 'access_jwt',
    refreshJwt: 'refresh_jwt',
    pdsUrl: 'https://bsky.social',
    scope: 'atproto transition:generic',
    expiresAt: DateTime.parse('2030-01-01T00:00:00.000Z'),
    dpopKey: const {'kty': 'EC', 'crv': 'P-256', 'x': 'x', 'y': 'y'},
  );

  group('SessionStorage', () {
    test('saveSession writes session to storage', () async {
      when(
        () => mockStorage.write(
          key: keySession,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await sessionStorage.saveSession(testSession);

      verify(
        () => mockStorage.write(
          key: keySession,
          value: any(named: 'value', that: contains('test.bsky.social')),
        ),
      ).called(1);
    });

    test('getSession returns null when storage is empty', () async {
      when(() => mockStorage.read(key: keySession)).thenAnswer((_) async => null);

      final result = await sessionStorage.getSession();

      expect(result, isNull);
    });

    test('getSession returns parsed session when storage has valid data', () async {
      when(() => mockStorage.read(key: keySession)).thenAnswer(
        (_) async =>
            '{"did":"did:plc:123","handle":"test.bsky.social","accessJwt":"access_jwt","refreshJwt":"refresh_jwt","pdsUrl":"https://bsky.social","scope":"atproto transition:generic","expiresAt":"2030-01-01T00:00:00.000Z","dpopKey":{"kty":"EC","crv":"P-256","x":"x","y":"y"}}',
      );

      final result = await sessionStorage.getSession();

      expect(result, isNotNull);
      expect(result!.did, 'did:plc:123');
      expect(result.handle, 'test.bsky.social');
    });

    test('getSession clears session and returns null when data is invalid', () async {
      when(() => mockStorage.read(key: keySession)).thenAnswer((_) async => 'invalid_json');
      when(() => mockStorage.delete(key: keySession)).thenAnswer((_) async {});

      final result = await sessionStorage.getSession();

      expect(result, isNull);
      verify(() => mockStorage.delete(key: keySession)).called(1);
    });

    test('clearSession removes session from storage', () async {
      when(() => mockStorage.delete(key: keySession)).thenAnswer((_) async {});

      await sessionStorage.clearSession();

      verify(() => mockStorage.delete(key: keySession)).called(1);
    });
  });
}
