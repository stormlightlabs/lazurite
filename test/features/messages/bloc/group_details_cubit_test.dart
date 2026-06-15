import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/chat/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/messages/bloc/group_details_cubit.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

import '../../../helpers/fixtures/messages.dart';

class MockConvoRepository extends Mock implements ConvoRepository {}

void main() {
  const currentUserDid = testViewerDid;
  late MockConvoRepository repository;

  setUp(() {
    repository = MockConvoRepository();
  });

  ConvoView groupConvo({String name = testGroupName, int memberCount = 3}) {
    return ConvoView.fromJson(testGroupConvoJson(name: name, memberCount: memberCount));
  }

  ProfileViewBasic member({
    String did = testMemberDid,
    String handle = 'member.bsky.social',
    String role = 'standard',
  }) {
    return ProfileViewBasic.fromJson(
      testChatProfileJson(
        did: did,
        handle: handle,
        extra: {
          'kind': {r'$type': 'chat.bsky.actor.defs#groupConvoMember', 'role': role},
        },
      ),
    );
  }

  GroupDetailsCubit buildCubit() =>
      GroupDetailsCubit(convoRepository: repository, convoId: testConvoId, currentUserDid: currentUserDid);

  group('GroupDetailsCubit', () {
    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'loads group details and first member page',
      build: buildCubit,
      setUp: () {
        when(() => repository.getConvo(testConvoId)).thenAnswer((_) async => groupConvo());
        when(
          () => repository.getConvoMembers(
            testConvoId,
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => ConvoMembersResult(
            members: [member(did: currentUserDid, role: 'owner')],
            cursor: 'next',
          ),
        );
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        predicate<GroupDetailsState>((state) => state.status == GroupDetailsStatus.loading),
        predicate<GroupDetailsState>(
          (state) =>
              state.status == GroupDetailsStatus.loaded &&
              state.convo?.id == testConvoId &&
              state.members.length == 1 &&
              state.hasMore,
        ),
      ],
    );

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'paginates member list',
      build: buildCubit,
      seed: () => GroupDetailsState(
        status: GroupDetailsStatus.loaded,
        convo: groupConvo(),
        members: [member(did: currentUserDid, role: 'owner')],
        cursor: 'next',
        hasMore: true,
      ),
      setUp: () {
        when(
          () => repository.getConvoMembers(
            testConvoId,
            cursor: 'next',
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => ConvoMembersResult(members: [member()], cursor: null));
      },
      act: (cubit) => cubit.loadMoreMembers(),
      expect: () => [
        predicate<GroupDetailsState>((state) => state.isLoadingMore),
        predicate<GroupDetailsState>((state) => state.members.length == 2 && !state.hasMore && !state.isLoadingMore),
      ],
    );

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'leaves group',
      build: buildCubit,
      setUp: () {
        when(() => repository.leaveConvo(testConvoId)).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.leaveGroup(),
      expect: () => [
        predicate<GroupDetailsState>((state) => state.isMutating),
        predicate<GroupDetailsState>((state) => state.leaveSucceeded && !state.isMutating),
      ],
    );

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'renames group and refreshes members',
      build: buildCubit,
      setUp: () {
        when(
          () => repository.editGroupName(testConvoId, 'Renamed'),
        ).thenAnswer((_) async => groupConvo(name: 'Renamed'));
        when(
          () => repository.getConvoMembers(
            testConvoId,
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => ConvoMembersResult(
            members: [member(did: currentUserDid, role: 'owner')],
          ),
        );
      },
      act: (cubit) => cubit.renameGroup(' Renamed '),
      expect: () => [
        predicate<GroupDetailsState>((state) => state.isMutating),
        predicate<GroupDetailsState>(
          (state) => state.convo?.kind?.groupConvo?.name == 'Renamed' && state.members.length == 1 && !state.isMutating,
        ),
      ],
    );

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'adds member and refreshes members',
      build: buildCubit,
      setUp: () {
        when(
          () => repository.addGroupMembers(testConvoId, [testMemberDid]),
        ).thenAnswer((_) async => groupConvo(memberCount: 4));
        when(
          () => repository.getConvoMembers(
            testConvoId,
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => ConvoMembersResult(
            members: [
              member(did: currentUserDid, role: 'owner'),
              member(),
            ],
          ),
        );
      },
      act: (cubit) => cubit.addMember(testMemberDid),
      expect: () => [
        predicate<GroupDetailsState>((state) => state.isMutating),
        predicate<GroupDetailsState>((state) => state.members.length == 2 && !state.isMutating),
      ],
    );

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'removes member and refreshes members',
      build: buildCubit,
      setUp: () {
        when(
          () => repository.removeGroupMembers(testConvoId, [testMemberDid]),
        ).thenAnswer((_) async => groupConvo(memberCount: 2));
        when(
          () => repository.getConvoMembers(
            testConvoId,
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => ConvoMembersResult(
            members: [member(did: currentUserDid, role: 'owner')],
          ),
        );
      },
      act: (cubit) => cubit.removeMember(testMemberDid),
      expect: () => [
        predicate<GroupDetailsState>((state) => state.isMutating),
        predicate<GroupDetailsState>((state) => state.members.single.did == currentUserDid && !state.isMutating),
      ],
    );

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'surfaces insufficient role without stale mutation state',
      build: buildCubit,
      setUp: () {
        when(() => repository.editGroupName(testConvoId, 'Renamed')).thenThrow(_xrpcError('InsufficientRole'));
      },
      act: (cubit) => cubit.renameGroup('Renamed'),
      expect: () => [
        predicate<GroupDetailsState>((state) => state.isMutating),
        predicate<GroupDetailsState>(
          (state) => !state.isMutating && state.errorMessage == 'You do not have permission to change this group.',
        ),
      ],
    );
  });
}

atcore.XRPCException _xrpcError(String code) {
  return atcore.InvalidRequestException(
    atcore.XRPCResponse<atcore.XRPCError>(
      headers: const {},
      status: atcore.HttpStatus.badRequest,
      request: atcore.XRPCRequest(method: atcore.HttpMethod.post, url: Uri.https('api.bsky.chat')),
      rateLimit: atcore.RateLimit.unlimited(),
      data: atcore.XRPCError(error: code),
    ),
  );
}
