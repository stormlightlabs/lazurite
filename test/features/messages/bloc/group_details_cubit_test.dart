import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/chat/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:bluesky_poptart/chat/bsky/group/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/l10n/app_localizations_en.dart';
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

  GroupDetailsCubit buildCubit() => GroupDetailsCubit(
    convoRepository: repository,
    convoId: testConvoId,
    currentUserDid: currentUserDid,
    l10n: AppLocalizationsEn(),
  );

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
        when(
          () => repository.listJoinRequests(
            testConvoId,
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => JoinRequestsResult(requests: [JoinRequestView.fromJson(testJoinRequestJson())]));
        when(() => repository.updateJoinRequestsRead(testConvoId)).thenAnswer((_) async {});
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
        predicate<GroupDetailsState>((state) => state.isLoadingJoinRequests),
        predicate<GroupDetailsState>((state) => state.joinRequests.length == 1 && !state.isLoadingJoinRequests),
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

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'creates join link and refreshes conversation',
      build: buildCubit,
      setUp: () {
        when(
          () => repository.createJoinLink(
            convoId: testConvoId,
            joinRule: const JoinRule.knownValue(data: KnownJoinRule.anyone),
            requireApproval: false,
          ),
        ).thenAnswer((_) async => JoinLinkView.fromJson(testJoinLinkJson(code: 'new-code', requireApproval: false)));
        when(() => repository.getConvo(testConvoId)).thenAnswer((_) async => groupConvo());
      },
      act: (cubit) =>
          cubit.createJoinLink(joinRule: const JoinRule.knownValue(data: KnownJoinRule.anyone), requireApproval: false),
      expect: () => [
        predicate<GroupDetailsState>((state) => state.isMutating),
        predicate<GroupDetailsState>(
          (state) => state.group?.joinLink?.code == 'new-code' && state.group?.joinLink?.requireApproval == false,
        ),
      ],
    );

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'edits join link and refreshes conversation',
      build: buildCubit,
      setUp: () {
        when(
          () => repository.editJoinLink(
            convoId: testConvoId,
            joinRule: const JoinRule.knownValue(data: KnownJoinRule.anyone),
            requireApproval: false,
          ),
        ).thenAnswer((_) async => JoinLinkView.fromJson(testJoinLinkJson(joinRule: 'anyone', requireApproval: false)));
        when(() => repository.getConvo(testConvoId)).thenAnswer((_) async => groupConvo());
      },
      act: (cubit) =>
          cubit.editJoinLink(joinRule: const JoinRule.knownValue(data: KnownJoinRule.anyone), requireApproval: false),
      expect: () => [
        predicate<GroupDetailsState>((state) => state.isMutating),
        predicate<GroupDetailsState>(
          (state) =>
              state.group?.joinLink?.joinRule.knownValue == KnownJoinRule.anyone &&
              state.group?.joinLink?.requireApproval == false,
        ),
      ],
    );

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'enables and disables join link',
      build: buildCubit,
      setUp: () {
        when(
          () => repository.enableJoinLink(testConvoId),
        ).thenAnswer((_) async => JoinLinkView.fromJson(testJoinLinkJson()));
        when(
          () => repository.disableJoinLink(testConvoId),
        ).thenAnswer((_) async => JoinLinkView.fromJson({...testJoinLinkJson(), 'enabledStatus': 'disabled'}));
        when(() => repository.getConvo(testConvoId)).thenAnswer((_) async => groupConvo());
      },
      act: (cubit) async {
        await cubit.enableJoinLink();
        await cubit.disableJoinLink();
      },
      expect: () => [
        predicate<GroupDetailsState>((state) => state.isMutating),
        predicate<GroupDetailsState>(
          (state) => state.group?.joinLink?.enabledStatus.knownValue == KnownLinkEnabledStatus.enabled,
        ),
        predicate<GroupDetailsState>((state) => state.isMutating),
        predicate<GroupDetailsState>(
          (state) => state.group?.joinLink?.enabledStatus.knownValue == KnownLinkEnabledStatus.disabled,
        ),
      ],
    );

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'loads and paginates join requests',
      build: buildCubit,
      seed: () => GroupDetailsState(status: GroupDetailsStatus.loaded, convo: groupConvo()),
      setUp: () {
        when(
          () => repository.listJoinRequests(
            testConvoId,
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((invocation) async {
          final cursor = invocation.namedArguments[#cursor] as String?;
          return JoinRequestsResult(
            requests: [
              JoinRequestView.fromJson(testJoinRequestJson(requestedByDid: cursor == null ? 'did:one' : 'did:two')),
            ],
            cursor: cursor == null ? 'next' : null,
          );
        });
        when(() => repository.updateJoinRequestsRead(testConvoId)).thenAnswer((_) async {});
      },
      act: (cubit) async {
        await cubit.loadJoinRequests();
        await cubit.loadMoreJoinRequests();
      },
      expect: () => [
        predicate<GroupDetailsState>((state) => state.isLoadingJoinRequests),
        predicate<GroupDetailsState>((state) => state.joinRequests.length == 1 && state.hasMoreJoinRequests),
        predicate<GroupDetailsState>((state) => state.isLoadingJoinRequests),
        predicate<GroupDetailsState>((state) => state.joinRequests.length == 2 && !state.hasMoreJoinRequests),
      ],
    );

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'approves join request and refreshes requests',
      build: buildCubit,
      setUp: () {
        when(
          () => repository.approveJoinRequest(testConvoId, testMemberDid),
        ).thenAnswer((_) async => groupConvo(memberCount: 4));
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
        when(
          () => repository.listJoinRequests(
            testConvoId,
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => JoinRequestsResult(requests: []));
        when(() => repository.updateJoinRequestsRead(testConvoId)).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.approveJoinRequest(testMemberDid),
      expect: () => [
        predicate<GroupDetailsState>((state) => state.isMutating),
        predicate<GroupDetailsState>((state) => state.group?.memberCount == 4 && !state.isMutating),
        predicate<GroupDetailsState>((state) => state.isLoadingJoinRequests),
        predicate<GroupDetailsState>((state) => state.joinRequests.isEmpty && !state.isLoadingJoinRequests),
      ],
    );

    blocTest<GroupDetailsCubit, GroupDetailsState>(
      'rejects join request and refreshes requests',
      build: buildCubit,
      setUp: () {
        when(() => repository.rejectJoinRequest(testConvoId, testMemberDid)).thenAnswer((_) async {});
        when(
          () => repository.listJoinRequests(
            testConvoId,
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => JoinRequestsResult(requests: []));
        when(() => repository.updateJoinRequestsRead(testConvoId)).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.rejectJoinRequest(testMemberDid),
      expect: () => [
        predicate<GroupDetailsState>((state) => state.isMutating),
        predicate<GroupDetailsState>((state) => state.isLoadingJoinRequests && state.isMutating),
        predicate<GroupDetailsState>((state) => state.joinRequests.isEmpty && !state.isLoadingJoinRequests),
        predicate<GroupDetailsState>((state) => !state.isMutating),
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
