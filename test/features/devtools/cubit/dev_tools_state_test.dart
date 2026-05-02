import 'package:atproto/com_atproto_repo_listrecords.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/devtools/cubit/dev_tools_cubit.dart';

void main() {
  group('CollectionSummary', () {
    test('countLabel shows placeholder until count is known', () {
      expect(const CollectionSummary('app.bsky.feed.post').countLabel, '...');
      expect(const CollectionSummary('app.bsky.feed.post', recordCount: 12).countLabel, '12');
    });
  });

  group('RecordInfo', () {
    test('creates with required parameters', () {
      const record = RecordInfo(
        uri: 'at://did:plc:test/app.bsky.feed.post/abc123',
        cid: 'bafyrei123',
        value: {'text': 'Hello'},
      );

      expect(record.uri, 'at://did:plc:test/app.bsky.feed.post/abc123');
      expect(record.cid, 'bafyrei123');
      expect(record.value, {'text': 'Hello'});
    });

    test('rkey extracts last path segment', () {
      const record = RecordInfo(uri: 'at://did:plc:test/app.bsky.feed.post/abc123', value: {});
      expect(record.rkey, 'abc123');
    });

    test('rkey returns empty string for invalid URI', () {
      const record = RecordInfo(uri: 'invalid', value: {});
      expect(record.rkey, '');
    });

    test('atUriToLink constructs aturi.to URL', () {
      const record = RecordInfo(
        uri: 'at://did:plc:ewvi7nxzyoun6zhxrhs64oiz/app.bsky.feed.post/3m6mwoadjbp2d',
        value: {},
      );

      expect(record.atUriToLink, 'https://aturi.to/did:plc:ewvi7nxzyoun6zhxrhs64oiz/app.bsky.feed.post/3m6mwoadjbp2d');
    });
  });

  group('DevToolsState', () {
    test('initial state has default values', () {
      const state = DevToolsState();

      expect(state.status, DevToolsStatus.initial);
      expect(state.did, isNull);
      expect(state.handle, isNull);
      expect(state.repoHandle, isNull);
      expect(state.typeaheadActors, isEmpty);
      expect(state.isTypeaheadLoading, isFalse);
      expect(state.collections, isEmpty);
      expect(state.isCollectionCountsLoading, isFalse);
      expect(state.selectedCollection, isNull);
      expect(state.records, isNull);
      expect(state.recordsCursor, isNull);
      expect(state.selectedRecord, isNull);
      expect(state.isCollectionLoading, isFalse);
      expect(state.isRecordLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('isLoading returns true for loading statuses', () {
      expect(const DevToolsState(status: DevToolsStatus.loading).isLoading, isTrue);
      expect(const DevToolsState(status: DevToolsStatus.loadingMore).isLoading, isTrue);
      expect(const DevToolsState(status: DevToolsStatus.initial).isLoading, isFalse);
      expect(const DevToolsState(status: DevToolsStatus.repoLoaded).isLoading, isFalse);
    });

    test('isNavigating returns true for collection or record transitions', () {
      expect(const DevToolsState(isCollectionLoading: true).isNavigating, isTrue);
      expect(const DevToolsState(isRecordLoading: true).isNavigating, isTrue);
      expect(const DevToolsState().isNavigating, isFalse);
    });

    test('hasMoreRecords returns true when cursor exists', () {
      expect(const DevToolsState(recordsCursor: 'cursor123').hasMoreRecords, isTrue);
      expect(const DevToolsState(recordsCursor: '').hasMoreRecords, isFalse);
      expect(const DevToolsState().hasMoreRecords, isFalse);
    });

    test('totalRecords returns loaded records length', () {
      final records = [
        const RepoListRecordsRecord(
          uri: AtUri('at://did:plc:test/app.bsky.feed.post/1'),
          cid: 'cid1',
          value: {'text': 'test'},
        ),
        const RepoListRecordsRecord(
          uri: AtUri('at://did:plc:test/app.bsky.feed.post/2'),
          cid: 'cid2',
          value: {'text': 'test2'},
        ),
      ];

      expect(DevToolsState(records: records).totalRecords, 2);
      expect(const DevToolsState().totalRecords, 0);
    });

    test('totalRepoRecords returns null until all counts are known', () {
      const state = DevToolsState(
        collections: [CollectionSummary('app.bsky.feed.post', recordCount: 2), CollectionSummary('app.bsky.feed.like')],
      );

      expect(state.totalRepoRecords, isNull);
      expect(
        const DevToolsState(
          collections: [
            CollectionSummary('app.bsky.feed.post', recordCount: 2),
            CollectionSummary('app.bsky.feed.like', recordCount: 3),
          ],
        ).totalRepoRecords,
        5,
      );
    });

    test('copyWith preserves unspecified values', () {
      const state = DevToolsState(
        status: DevToolsStatus.repoLoaded,
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        repoHandle: 'test.bsky.social',
        collections: [CollectionSummary('app.bsky.feed.post')],
      );

      final copied = state.copyWith(selectedCollection: 'app.bsky.feed.post');

      expect(copied.status, DevToolsStatus.repoLoaded);
      expect(copied.did, 'did:plc:test');
      expect(copied.selectedCollection, 'app.bsky.feed.post');
    });

    test('copyWith can clear nullable fields', () {
      final records = [
        const RepoListRecordsRecord(
          uri: AtUri('at://did:plc:test/app.bsky.feed.post/1'),
          cid: 'cid1',
          value: {'text': 'test'},
        ),
      ];

      final state = DevToolsState(
        status: DevToolsStatus.recordLoaded,
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        repoHandle: 'test.bsky.social',
        typeaheadActors: [const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social')],
        isTypeaheadLoading: true,
        collections: const [CollectionSummary('app.bsky.feed.post', recordCount: 1)],
        isCollectionCountsLoading: true,
        selectedCollection: 'app.bsky.feed.post',
        records: records,
        recordsCursor: 'cursor',
        selectedRecord: const RecordInfo(uri: 'at://did:plc:test/app.bsky.feed.post/1', value: {'text': 'full'}),
        isCollectionLoading: true,
        isRecordLoading: true,
        errorMessage: 'error',
      );

      final updated = state.copyWith(
        did: null,
        handle: null,
        repoHandle: null,
        typeaheadActors: const [],
        isTypeaheadLoading: false,
        isCollectionCountsLoading: false,
        selectedCollection: null,
        records: null,
        recordsCursor: null,
        selectedRecord: null,
        isCollectionLoading: false,
        isRecordLoading: false,
        errorMessage: null,
      );

      expect(updated.did, isNull);
      expect(updated.handle, isNull);
      expect(updated.repoHandle, isNull);
      expect(updated.typeaheadActors, isEmpty);
      expect(updated.isTypeaheadLoading, isFalse);
      expect(updated.isCollectionCountsLoading, isFalse);
      expect(updated.selectedCollection, isNull);
      expect(updated.records, isNull);
      expect(updated.recordsCursor, isNull);
      expect(updated.selectedRecord, isNull);
      expect(updated.isCollectionLoading, isFalse);
      expect(updated.isRecordLoading, isFalse);
      expect(updated.errorMessage, isNull);
    });

    test('props includes all fields for equality', () {
      const state = DevToolsState(
        status: DevToolsStatus.repoLoaded,
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        repoHandle: 'test.bsky.social',
        typeaheadActors: [ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social')],
        isTypeaheadLoading: true,
        collections: [CollectionSummary('app.bsky.feed.post', recordCount: 1)],
        isCollectionCountsLoading: true,
        selectedCollection: 'app.bsky.feed.post',
        recordsCursor: 'cursor',
        selectedRecord: RecordInfo(uri: 'at://test', value: {}),
        isCollectionLoading: true,
        isRecordLoading: true,
        errorMessage: 'error',
      );

      expect(state.props.length, 16);
      expect(state.props, contains(DevToolsStatus.repoLoaded));
      expect(state.props, contains(true));
      expect(state.props, contains('did:plc:test'));
    });
  });
}
