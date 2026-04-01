import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

ProfileViewDetailed _profile({String did = 'did:plc:alice', String handle = 'alice.bsky.social'}) {
  return ProfileViewDetailed(did: did, handle: handle, indexedAt: DateTime.utc(2026));
}

void main() {
  late MockProfileRepository repository;

  setUp(() {
    repository = MockProfileRepository();
  });

  blocTest<ProfileBloc, ProfileState>(
    'refresh uses handle when available',
    build: () => ProfileBloc(profileRepository: repository),
    seed: () => ProfileState.loaded(profile: _profile()),
    setUp: () {
      when(() => repository.getProfile('alice.bsky.social')).thenAnswer((_) async => _profile());
    },
    act: (bloc) => bloc.add(const ProfileRefreshRequested()),
    expect: () => [
      predicate<ProfileState>((state) => state.isRefreshing),
      predicate<ProfileState>((state) => state.status == ProfileStatus.loaded && !state.isRefreshing),
    ],
    verify: (_) {
      verify(() => repository.getProfile('alice.bsky.social')).called(1);
      verifyNever(() => repository.getProfile('did:plc:alice'));
    },
  );
}
