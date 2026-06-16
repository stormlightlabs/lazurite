import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart' as app_actor;
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/l10n/app_localizations_en.dart';
import 'package:lazurite/features/messages/bloc/group_create_cubit.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

import '../../../helpers/fixtures/messages.dart';

class MockConvoRepository extends Mock implements ConvoRepository {}

void main() {
  const currentUserDid = 'did:plc:viewer';
  late MockConvoRepository repository;

  setUp(() {
    repository = MockConvoRepository();
  });

  app_actor.ProfileViewBasic profile({
    String did = testMemberDid,
    String handle = 'member.bsky.social',
    String? displayName = 'Member',
  }) {
    return app_actor.ProfileViewBasic(did: did, handle: handle, displayName: displayName);
  }

  ConvoView groupConvo({String id = testConvoId, String name = testGroupName}) {
    return ConvoView.fromJson(testGroupConvoJson(id: id, name: name));
  }

  GroupCreateCubit buildCubit() =>
      GroupCreateCubit(convoRepository: repository, currentUserDid: currentUserDid, l10n: AppLocalizationsEn());

  group('GroupCreateCubit', () {
    blocTest<GroupCreateCubit, GroupCreateState>(
      'keeps create disabled until name and at least one member are valid',
      build: buildCubit,
      act: (cubit) {
        cubit.nameChanged('Release Planning');
        cubit.memberAdded(profile());
      },
      expect: () => [
        predicate<GroupCreateState>((state) => state.trimmedName == 'Release Planning' && !state.canCreate),
        predicate<GroupCreateState>((state) => state.canCreate && state.members.single.did == testMemberDid),
      ],
    );

    blocTest<GroupCreateCubit, GroupCreateState>(
      'rejects overlong group names by grapheme count',
      build: buildCubit,
      act: (cubit) {
        cubit.nameChanged(List.filled(51, '🟦').join());
        cubit.memberAdded(profile());
        cubit.createSubmitted();
      },
      expect: () => [
        predicate<GroupCreateState>((state) => state.nameGraphemeCount == 51 && !state.canCreate),
        predicate<GroupCreateState>((state) => state.members.length == 1 && !state.canCreate),
        predicate<GroupCreateState>(
          (state) =>
              state.status == GroupCreateStatus.failure &&
              state.errorMessage == 'Group names can be up to 50 characters.',
        ),
      ],
      verify: (_) => verifyNever(
        () => repository.createGroup(
          name: any(named: 'name'),
          memberDids: any(named: 'memberDids'),
        ),
      ),
    );

    blocTest<GroupCreateCubit, GroupCreateState>(
      'does not add duplicate members or the current user',
      build: buildCubit,
      act: (cubit) {
        cubit.memberAdded(profile());
        cubit.memberAdded(profile());
        cubit.memberAdded(profile(did: currentUserDid, handle: 'viewer.bsky.social'));
      },
      expect: () => [
        predicate<GroupCreateState>((state) => state.members.length == 1 && state.errorMessage == null),
        predicate<GroupCreateState>(
          (state) => state.members.length == 1 && state.errorMessage == 'You are already included as the group owner.',
        ),
      ],
    );

    blocTest<GroupCreateCubit, GroupCreateState>(
      'submits valid groups through the repository',
      build: buildCubit,
      setUp: () {
        when(
          () => repository.createGroup(name: 'Release Planning', memberDids: [testMemberDid]),
        ).thenAnswer((_) async => groupConvo());
      },
      act: (cubit) async {
        cubit.nameChanged(' Release Planning ');
        cubit.memberAdded(profile());
        await cubit.createSubmitted();
      },
      expect: () => [
        predicate<GroupCreateState>((state) => state.trimmedName == 'Release Planning'),
        predicate<GroupCreateState>((state) => state.canCreate),
        predicate<GroupCreateState>((state) => state.status == GroupCreateStatus.submitting),
        predicate<GroupCreateState>(
          (state) => state.status == GroupCreateStatus.success && state.createdConvo?.id == testConvoId,
        ),
      ],
      verify: (_) {
        verify(() => repository.createGroup(name: 'Release Planning', memberDids: [testMemberDid])).called(1);
      },
    );

    blocTest<GroupCreateCubit, GroupCreateState>(
      'maps protocol errors to actionable messages',
      build: buildCubit,
      setUp: () {
        when(
          () => repository.createGroup(name: 'Release Planning', memberDids: [testMemberDid]),
        ).thenThrow(_xrpcError('UserForbidsGroups'));
      },
      act: (cubit) async {
        cubit.nameChanged('Release Planning');
        cubit.memberAdded(profile());
        await cubit.createSubmitted();
      },
      skip: 2,
      expect: () => [
        predicate<GroupCreateState>((state) => state.status == GroupCreateStatus.submitting),
        predicate<GroupCreateState>(
          (state) =>
              state.status == GroupCreateStatus.failure &&
              state.errorMessage == 'A selected member does not allow group chat invites.',
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
