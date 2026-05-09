import 'package:poptart_lex/com/atproto/identity/resolve_handle.dart';
import 'package:poptart_lex/com/atproto/repo/describe_repo.dart';
import 'package:poptart_lex/com/atproto/repo/get_record.dart';
import 'package:poptart_lex/com/atproto/repo/list_records.dart';
import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/devtools/cubit/dev_tools_cubit.dart';

class FakeDevToolsRepository implements DevToolsRepository {
  FakeDevToolsRepository({
    this.resolveHandleHandler,
    this.describeRepoHandler,
    this.searchActorsTypeaheadHandler,
    this.listRecordsHandler,
    this.getRecordHandler,
  });

  Future<IdentityResolveHandleOutput> Function({required String handle})? resolveHandleHandler;
  Future<RepoDescribeRepoOutput> Function({required String repo, String? serviceHost})? describeRepoHandler;
  Future<List<ProfileViewBasic>> Function({required String query, int limit})? searchActorsTypeaheadHandler;
  Future<RepoListRecordsOutput> Function({
    required String repo,
    required String collection,
    int? limit,
    String? cursor,
    bool? reverse,
    String? serviceHost,
  })?
  listRecordsHandler;
  Future<RepoGetRecordOutput> Function({
    required String repo,
    required String collection,
    required String rkey,
    String? serviceHost,
  })?
  getRecordHandler;

  @override
  Future<RepoDescribeRepoOutput> describeRepo({required String repo, String? serviceHost}) {
    return describeRepoHandler!.call(repo: repo, serviceHost: serviceHost);
  }

  @override
  Future<List<ProfileViewBasic>> searchActorsTypeahead({required String query, int limit = 8}) async {
    final handler = searchActorsTypeaheadHandler;
    if (handler == null) {
      return const [];
    }
    return handler(query: query, limit: limit);
  }

  @override
  Future<RepoGetRecordOutput> getRecord({
    required String repo,
    required String collection,
    required String rkey,
    String? serviceHost,
  }) {
    return getRecordHandler!.call(repo: repo, collection: collection, rkey: rkey, serviceHost: serviceHost);
  }

  @override
  Future<RepoListRecordsOutput> listRecords({
    required String repo,
    required String collection,
    int? limit,
    String? cursor,
    bool? reverse,
    String? serviceHost,
  }) {
    return listRecordsHandler!.call(
      repo: repo,
      collection: collection,
      limit: limit,
      cursor: cursor,
      reverse: reverse,
      serviceHost: serviceHost,
    );
  }

  @override
  Future<IdentityResolveHandleOutput> resolveHandle({required String handle}) {
    return resolveHandleHandler!.call(handle: handle);
  }
}

void main() {
  group('DevToolsCubit', () {
    test('initial state is DevToolsState with initial status', () {
      final cubit = DevToolsCubit(repository: FakeDevToolsRepository());
      expect(cubit.state, const DevToolsState());
    });

    blocTest<DevToolsCubit, DevToolsState>(
      'clearInput resets to the initial state',
      build: () => DevToolsCubit(repository: FakeDevToolsRepository()),
      seed: () => const DevToolsState(status: DevToolsStatus.repoLoaded, did: 'did:plc:test'),
      act: (cubit) => cubit.clearInput(),
      expect: () => [const DevToolsState()],
    );

    blocTest<DevToolsCubit, DevToolsState>(
      'queryTypeahead loads suggestions for @handle input',
      build: () {
        final repository = FakeDevToolsRepository(
          searchActorsTypeaheadHandler: ({required String query, int limit = 8}) async {
            expect(query, 'alice');
            expect(limit, 8);
            return const [ProfileViewBasic(did: 'did:plc:alice', handle: 'alice.bsky.social')];
          },
        );
        return DevToolsCubit(repository: repository);
      },
      act: (cubit) => cubit.queryTypeahead('@alice'),
      expect: () => [
        isA<DevToolsState>()
            .having((state) => state.isTypeaheadLoading, 'isTypeaheadLoading', isTrue)
            .having((state) => state.typeaheadActors, 'typeaheadActors', isEmpty),
        isA<DevToolsState>()
            .having((state) => state.isTypeaheadLoading, 'isTypeaheadLoading', isFalse)
            .having((state) => state.typeaheadActors.length, 'typeaheadActors.length', 1)
            .having((state) => state.typeaheadActors.first.handle, 'first actor handle', 'alice.bsky.social'),
      ],
    );

    blocTest<DevToolsCubit, DevToolsState>(
      'queryTypeahead clears suggestions when input is not an @handle',
      build: () => DevToolsCubit(repository: FakeDevToolsRepository()),
      seed: () => const DevToolsState(
        typeaheadActors: [ProfileViewBasic(did: 'did:plc:alice', handle: 'alice.bsky.social')],
        isTypeaheadLoading: true,
      ),
      act: (cubit) => cubit.queryTypeahead('alice'),
      expect: () => [
        isA<DevToolsState>()
            .having((state) => state.isTypeaheadLoading, 'isTypeaheadLoading', isFalse)
            .having((state) => state.typeaheadActors, 'typeaheadActors', isEmpty),
      ],
    );

    blocTest<DevToolsCubit, DevToolsState>(
      'resolve handle loads repo and progressive collection counts',
      build: () {
        var describeRepoCalls = 0;
        final repository = FakeDevToolsRepository(
          resolveHandleHandler: ({required String handle}) async {
            expect(handle, 'alice.bsky.social');
            return const IdentityResolveHandleOutput(did: 'did:plc:alice');
          },
          describeRepoHandler: ({required String repo, String? serviceHost}) async {
            expect(repo, 'did:plc:alice');
            if (describeRepoCalls == 0) {
              expect(serviceHost, isNull);
            } else {
              expect(serviceHost, 'alice.host');
            }
            describeRepoCalls++;
            return const RepoDescribeRepoOutput(
              handle: 'alice.bsky.social',
              did: 'did:plc:alice',
              didDoc: {
                'service': [
                  {'id': '#atproto_pds', 'type': 'AtprotoPersonalDataServer', 'serviceEndpoint': 'https://alice.host'},
                ],
              },
              collections: ['app.bsky.feed.post'],
              handleIsCorrect: true,
            );
          },
          listRecordsHandler:
              ({
                required String repo,
                required String collection,
                int? limit,
                String? cursor,
                bool? reverse,
                String? serviceHost,
              }) async {
                expect(repo, 'did:plc:alice');
                expect(collection, 'app.bsky.feed.post');
                expect(serviceHost, 'alice.host');
                return RepoListRecordsOutput(
                  cursor: cursor == null ? 'next' : null,
                  records: [
                    RepoListRecordsRecord(
                      uri: AtUri('at://did:plc:alice/app.bsky.feed.post/${cursor == null ? '1' : '2'}'),
                      cid: 'cid-${cursor ?? 'first'}',
                      value: {'text': 'post ${cursor ?? 'first'}'},
                    ),
                  ],
                );
              },
        );

        return DevToolsCubit(repository: repository);
      },
      act: (cubit) => cubit.resolve('@alice.bsky.social'),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        const DevToolsState(status: DevToolsStatus.loading),
        isA<DevToolsState>()
            .having((state) => state.status, 'status', DevToolsStatus.repoLoaded)
            .having((state) => state.did, 'did', 'did:plc:alice')
            .having((state) => state.repoHandle, 'repoHandle', 'alice.bsky.social')
            .having((state) => state.collections.first.recordCount, 'initial count', isNull)
            .having((state) => state.isCollectionCountsLoading, 'count loading', isTrue),
        isA<DevToolsState>()
            .having((state) => state.status, 'status', DevToolsStatus.repoLoaded)
            .having((state) => state.collections.first.recordCount, 'resolved count', 2)
            .having((state) => state.totalRepoRecords, 'total repo records', 2)
            .having((state) => state.isCollectionCountsLoading, 'count loading', isFalse),
      ],
    );

    blocTest<DevToolsCubit, DevToolsState>(
      'resolve AT-URI loads collection and full record JSON',
      build: () {
        var describeRepoCalls = 0;
        final repository = FakeDevToolsRepository(
          resolveHandleHandler: ({required String handle}) async =>
              const IdentityResolveHandleOutput(did: 'did:plc:alice'),
          describeRepoHandler: ({required String repo, String? serviceHost}) async {
            expect(repo, 'did:plc:alice');
            if (describeRepoCalls == 0) {
              expect(serviceHost, isNull);
            } else {
              expect(serviceHost, 'alice.host');
            }
            describeRepoCalls++;
            return const RepoDescribeRepoOutput(
              handle: 'alice.bsky.social',
              did: 'did:plc:alice',
              didDoc: {
                'service': [
                  {'id': '#atproto_pds', 'type': 'AtprotoPersonalDataServer', 'serviceEndpoint': 'https://alice.host'},
                ],
              },
              collections: ['app.bsky.feed.post'],
              handleIsCorrect: true,
            );
          },
          listRecordsHandler:
              ({
                required String repo,
                required String collection,
                int? limit,
                String? cursor,
                bool? reverse,
                String? serviceHost,
              }) async {
                expect(serviceHost, 'alice.host');
                if (limit == 100) {
                  return const RepoListRecordsOutput(
                    records: [
                      RepoListRecordsRecord(
                        uri: AtUri('at://did:plc:alice/app.bsky.feed.post/3kz'),
                        cid: 'cid-count',
                        value: {'text': 'count me'},
                      ),
                    ],
                  );
                }

                return const RepoListRecordsOutput(
                  records: [
                    RepoListRecordsRecord(
                      uri: AtUri('at://did:plc:alice/app.bsky.feed.post/3kz'),
                      cid: 'cid-list',
                      value: {'text': 'summary'},
                    ),
                  ],
                );
              },
          getRecordHandler:
              ({required String repo, required String collection, required String rkey, String? serviceHost}) async {
                expect(repo, 'did:plc:alice');
                expect(collection, 'app.bsky.feed.post');
                expect(rkey, '3kz');
                expect(serviceHost, 'alice.host');
                return const RepoGetRecordOutput(
                  uri: AtUri('at://did:plc:alice/app.bsky.feed.post/3kz'),
                  cid: 'cid-full',
                  value: {
                    'text': 'full record',
                    'nested': {'ok': true},
                  },
                );
              },
        );

        return DevToolsCubit(repository: repository);
      },
      act: (cubit) => cubit.resolve('at://alice.bsky.social/app.bsky.feed.post/3kz'),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        const DevToolsState(status: DevToolsStatus.loading),
        isA<DevToolsState>()
            .having((state) => state.status, 'status', DevToolsStatus.recordLoaded)
            .having((state) => state.did, 'did', 'did:plc:alice')
            .having((state) => state.selectedCollection, 'selectedCollection', 'app.bsky.feed.post')
            .having((state) => state.records?.length, 'list records', 1)
            .having((state) => state.selectedRecord?.cid, 'full cid', 'cid-full')
            .having((state) => state.selectedRecord?.value['nested'], 'nested JSON', {'ok': true}),
        isA<DevToolsState>()
            .having((state) => state.collections.first.recordCount, 'collection count', 1)
            .having((state) => state.totalRepoRecords, 'total repo records', 1),
      ],
    );

    blocTest<DevToolsCubit, DevToolsState>(
      'loadRecord replaces list preview with getRecord response',
      build: () {
        final repository = FakeDevToolsRepository(
          getRecordHandler:
              ({required String repo, required String collection, required String rkey, String? serviceHost}) async {
                return const RepoGetRecordOutput(
                  uri: AtUri('at://did:plc:test/app.bsky.feed.post/123'),
                  cid: 'cid123',
                  value: {
                    'text': 'Expanded',
                    'reply': {'root': 'abc'},
                  },
                );
              },
        );

        return DevToolsCubit(repository: repository);
      },
      seed: () => const DevToolsState(
        status: DevToolsStatus.collectionLoaded,
        did: 'did:plc:test',
        collections: [CollectionSummary('app.bsky.feed.post', recordCount: 1)],
        selectedCollection: 'app.bsky.feed.post',
        records: [
          RepoListRecordsRecord(
            uri: AtUri('at://did:plc:test/app.bsky.feed.post/123'),
            cid: 'cid-list',
            value: {'text': 'Summary'},
          ),
        ],
      ),
      act: (cubit) => cubit.loadRecord(
        const RepoListRecordsRecord(
          uri: AtUri('at://did:plc:test/app.bsky.feed.post/123'),
          cid: 'cid-list',
          value: {'text': 'Summary'},
        ),
      ),
      expect: () => [
        isA<DevToolsState>()
            .having((state) => state.status, 'status', DevToolsStatus.collectionLoaded)
            .having((state) => state.isRecordLoading, 'isRecordLoading', isTrue),
        isA<DevToolsState>()
            .having((state) => state.status, 'status', DevToolsStatus.recordLoaded)
            .having((state) => state.isRecordLoading, 'isRecordLoading', isFalse)
            .having((state) => state.selectedRecord?.cid, 'cid', 'cid123')
            .having((state) => state.selectedRecord?.value['reply'], 'expanded value', {'root': 'abc'}),
      ],
    );

    blocTest<DevToolsCubit, DevToolsState>(
      'loadCollection keeps repo view active while records load',
      build: () {
        final repository = FakeDevToolsRepository(
          listRecordsHandler:
              ({
                required String repo,
                required String collection,
                int? limit,
                String? cursor,
                bool? reverse,
                String? serviceHost,
              }) async {
                return const RepoListRecordsOutput(
                  records: [
                    RepoListRecordsRecord(
                      uri: AtUri('at://did:plc:test/app.bsky.feed.post/123'),
                      cid: 'cid123',
                      value: {'text': 'Summary'},
                    ),
                  ],
                );
              },
        );

        return DevToolsCubit(repository: repository);
      },
      seed: () => const DevToolsState(
        status: DevToolsStatus.repoLoaded,
        did: 'did:plc:test',
        repoHandle: 'test.bsky.social',
        collections: [CollectionSummary('app.bsky.feed.post', recordCount: 1)],
      ),
      act: (cubit) => cubit.loadCollection('app.bsky.feed.post'),
      expect: () => [
        isA<DevToolsState>()
            .having((state) => state.status, 'status', DevToolsStatus.repoLoaded)
            .having((state) => state.isCollectionLoading, 'isCollectionLoading', isTrue),
        isA<DevToolsState>()
            .having((state) => state.status, 'status', DevToolsStatus.collectionLoaded)
            .having((state) => state.isCollectionLoading, 'isCollectionLoading', isFalse)
            .having((state) => state.selectedCollection, 'selectedCollection', 'app.bsky.feed.post')
            .having((state) => state.records?.length, 'records', 1),
      ],
    );

    blocTest<DevToolsCubit, DevToolsState>(
      'invalid AT-URI surfaces a clear error',
      build: () => DevToolsCubit(repository: FakeDevToolsRepository()),
      act: (cubit) => cubit.resolve('at://bad uri'),
      expect: () => [
        const DevToolsState(status: DevToolsStatus.loading),
        isA<DevToolsState>()
            .having((state) => state.status, 'status', DevToolsStatus.error)
            .having((state) => state.errorMessage, 'error', 'Invalid AT-URI'),
      ],
    );

    blocTest<DevToolsCubit, DevToolsState>(
      'goBackToCollection clears selectedRecord',
      build: () => DevToolsCubit(repository: FakeDevToolsRepository()),
      seed: () => const DevToolsState(
        status: DevToolsStatus.recordLoaded,
        did: 'did:plc:test',
        collections: [CollectionSummary('app.bsky.feed.post', recordCount: 1)],
        selectedCollection: 'app.bsky.feed.post',
        records: [
          RepoListRecordsRecord(
            uri: AtUri('at://did:plc:test/app.bsky.feed.post/123'),
            cid: 'cid',
            value: {'text': 'Summary'},
          ),
        ],
        selectedRecord: RecordInfo(uri: 'at://did:plc:test/app.bsky.feed.post/123', value: {'text': 'Full'}),
      ),
      act: (cubit) => cubit.goBackToCollection(),
      expect: () => [
        isA<DevToolsState>()
            .having((state) => state.status, 'status', DevToolsStatus.collectionLoaded)
            .having((state) => state.selectedRecord, 'selectedRecord', isNull)
            .having((state) => state.records?.length, 'records length', 1),
      ],
    );

    blocTest<DevToolsCubit, DevToolsState>(
      'goBackToRepo clears collection and record state',
      build: () => DevToolsCubit(repository: FakeDevToolsRepository()),
      seed: () => const DevToolsState(
        status: DevToolsStatus.recordLoaded,
        did: 'did:plc:test',
        collections: [CollectionSummary('app.bsky.feed.post', recordCount: 1)],
        selectedCollection: 'app.bsky.feed.post',
        records: [
          RepoListRecordsRecord(
            uri: AtUri('at://did:plc:test/app.bsky.feed.post/123'),
            cid: 'cid',
            value: {'text': 'Summary'},
          ),
        ],
        selectedRecord: RecordInfo(uri: 'at://did:plc:test/app.bsky.feed.post/123', value: {'text': 'Full'}),
      ),
      act: (cubit) => cubit.goBackToRepo(),
      expect: () => [
        isA<DevToolsState>()
            .having((state) => state.status, 'status', DevToolsStatus.repoLoaded)
            .having((state) => state.selectedCollection, 'selectedCollection', isNull)
            .having((state) => state.records, 'records', isNull)
            .having((state) => state.selectedRecord, 'selectedRecord', isNull),
      ],
    );
  });
}
