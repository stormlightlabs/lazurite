import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/domain/profile.dart';
import 'package:lazurite/src/features/thread/domain/thread.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockProfileRepository mockRepository;
  late ProviderContainer container;

  const testDid = 'did:plc:test';
  const myDid = 'did:plc:me';

  const testProfile = ProfileData(
    did: testDid,
    handle: 'test.bsky.social',
    displayName: 'Test User',
  );

  setUp(() {
    mockRepository = MockProfileRepository();

    final mockSession = MockSession();
    when(() => mockSession.did).thenReturn(myDid);

    final mockAuth = MockAuthStateAuthenticated();
    when(() => mockAuth.session).thenReturn(mockSession);

    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(mockRepository),
        authProvider.overrideWithValue(mockAuth),
      ],
    );

    when(() => mockRepository.getProfile(testDid, any())).thenAnswer((_) async => testProfile);
  });

  tearDown(() {
    container.dispose();
  });

  group('ProfileNotifier', () {
    test('toggleMute calls repository and updates state optimistically', () async {
      when(() => mockRepository.muteActor(myDid, testDid)).thenAnswer((_) async {});

      final notifier = container.read(profileProvider(testDid).notifier);
      await container.read(profileProvider(testDid).future);

      await notifier.toggleMute();

      verify(() => mockRepository.muteActor(myDid, testDid)).called(1);

      final state = container.read(profileProvider(testDid));
      expect(state.value?.viewerMuted, isTrue);
    });

    test('toggleMute un-mutes if already muted', () async {
      final mutedProfile = testProfile.copyWith(viewer: const ActorViewer(muted: true));
      when(() => mockRepository.getProfile(testDid, any())).thenAnswer((_) async => mutedProfile);
      when(() => mockRepository.unmuteActor(myDid, testDid)).thenAnswer((_) async {});

      final notifier = container.read(profileProvider(testDid).notifier);
      await container.read(profileProvider(testDid).future);

      await notifier.toggleMute();

      verify(() => mockRepository.unmuteActor(myDid, testDid)).called(1);
      final state = container.read(profileProvider(testDid));
      expect(state.value?.viewerMuted, isFalse);
    });

    test('toggleBlock calls repository and updates state', () async {
      const blockUri = 'at://...';
      when(() => mockRepository.blockActor(myDid, testDid)).thenAnswer((_) async => blockUri);

      final notifier = container.read(profileProvider(testDid).notifier);
      await container.read(profileProvider(testDid).future);

      await notifier.toggleBlock();

      verify(() => mockRepository.blockActor(myDid, testDid)).called(1);
      final state = container.read(profileProvider(testDid));
      expect(state.value?.viewerBlockingUri, equals(blockUri));
    });

    test('toggleBlock un-blocks if already blocked', () async {
      const blockUri = 'at://...';
      final blockedProfile = testProfile.copyWith(viewer: const ActorViewer(blocking: blockUri));

      when(
        () => mockRepository.getProfile(testDid, any()),
      ).thenAnswer((_) async => blockedProfile);
      when(
        () => mockRepository.unblockActor(myDid, blockUri, subjectDid: any(named: 'subjectDid')),
      ).thenAnswer((_) async {});

      final notifier = container.read(profileProvider(testDid).notifier);
      await container.read(profileProvider(testDid).future);

      await notifier.toggleBlock();

      verify(() => mockRepository.unblockActor(myDid, blockUri, subjectDid: testDid)).called(1);
      final state = container.read(profileProvider(testDid));
      expect(state.value?.viewerBlockingUri, isNull);
    });
  });
}
