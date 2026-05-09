import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/notification/list_notifications.dart' as bsky;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/local_notification_adapter.dart';
import 'package:lazurite/features/notifications/domain/notification_domain_service.dart';
import 'package:lazurite/features/notifications/domain/notification_local_models.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockLocalNotificationAdapter extends Mock implements LocalNotificationAdapter {}

class FakeLocalNotificationRequest extends Fake implements LocalNotificationRequest {}

void main() {
  late MockNotificationRepository repository;
  late MockLocalNotificationAdapter localNotificationAdapter;

  final canonicalNotification = bsky.Notification(
    uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/notif'),
    cid: 'cid-123',
    author: const ProfileView(did: 'did:plc:author', handle: 'author.bsky.social'),
    reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.like),
    reasonSubject: AtUri.parse('at://did:plc:author/app.bsky.feed.post/record-rkey'),
    record: const {},
    isRead: false,
    indexedAt: DateTime.utc(2026, 5, 1, 10),
  );

  setUpAll(() {
    registerFallbackValue(FakeLocalNotificationRequest());
  });

  setUp(() {
    repository = MockNotificationRepository();
    localNotificationAdapter = MockLocalNotificationAdapter();
    when(() => localNotificationAdapter.show(any())).thenAnswer((_) async {});
  });

  Map<String, String> validPayload() => {
    'senderDid': 'did:plc:author',
    'targetDid': 'did:plc:test',
    'recordUri': 'at://did:plc:author/app.bsky.feed.post/record-rkey',
    'reason': 'like',
  };

  group('NotificationDomainService push payload processing', () {
    test('drops invalid payloads and increments drop counters', () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);

      final service = NotificationDomainService(
        notificationRepository: repository,
        database: database,
        accountDid: 'did:plc:test',
        localNotificationAdapter: localNotificationAdapter,
      );

      final result = await service.onPushPayload({'recordUri': 'bad'});

      expect(result, NotificationPushProcessingOutcome.droppedInvalidPayload);
      expect(await database.getSetting('notification_push_dropped_count'), '1');
      expect(await database.getSetting('notification_push_dropped_reason_invalid_payload'), '1');
      verifyNever(() => repository.findNotificationByRecordUri(recordUri: any(named: 'recordUri')));
    });

    test('drops payloads that target another account did', () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);

      final service = NotificationDomainService(
        notificationRepository: repository,
        database: database,
        accountDid: 'did:plc:test',
        localNotificationAdapter: localNotificationAdapter,
      );

      final payload = validPayload()..['targetDid'] = 'did:plc:someone-else';
      final result = await service.onPushPayload(payload);

      expect(result, NotificationPushProcessingOutcome.droppedTargetMismatch);
      verifyNever(() => repository.findNotificationByRecordUri(recordUri: any(named: 'recordUri')));
    });

    test('drops payload when canonical notification cannot be resolved', () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);

      when(
        () => repository.findNotificationByRecordUri(
          recordUri: any(named: 'recordUri'),
          senderDid: any(named: 'senderDid'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => null);

      final service = NotificationDomainService(
        notificationRepository: repository,
        database: database,
        accountDid: 'did:plc:test',
        localNotificationAdapter: localNotificationAdapter,
      );

      final result = await service.onPushPayload(validPayload());

      expect(result, NotificationPushProcessingOutcome.droppedNotFound);
      verify(
        () => repository.findNotificationByRecordUri(
          recordUri: any(named: 'recordUri'),
          senderDid: any(named: 'senderDid'),
          reason: any(named: 'reason'),
          maxPages: any(named: 'maxPages'),
          limit: any(named: 'limit'),
        ),
      ).called(1);
      verifyNever(() => localNotificationAdapter.show(any()));
    });

    test('dedupes repeated payloads and only shows once', () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);

      when(
        () => repository.findNotificationByRecordUri(
          recordUri: any(named: 'recordUri'),
          senderDid: any(named: 'senderDid'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => canonicalNotification);

      final service = NotificationDomainService(
        notificationRepository: repository,
        database: database,
        accountDid: 'did:plc:test',
        localNotificationAdapter: localNotificationAdapter,
      );

      final first = await service.onPushPayload(validPayload());
      final second = await service.onPushPayload(validPayload());

      expect(first, NotificationPushProcessingOutcome.processed);
      expect(second, NotificationPushProcessingOutcome.droppedDuplicate);
      verify(() => localNotificationAdapter.show(any())).called(1);
      expect(await database.countNotificationDeliveries('did:plc:test'), 1);
    });

    test('drops and accounts timed out processing', () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);

      when(
        () => repository.findNotificationByRecordUri(
          recordUri: any(named: 'recordUri'),
          senderDid: any(named: 'senderDid'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return canonicalNotification;
      });

      final service = NotificationDomainService(
        notificationRepository: repository,
        database: database,
        accountDid: 'did:plc:test',
        localNotificationAdapter: localNotificationAdapter,
      );

      final result = await service.onPushPayload(validPayload(), timeout: const Duration(milliseconds: 1));

      expect(result, NotificationPushProcessingOutcome.droppedTimeout);
      expect(await database.getSetting('notification_push_dropped_reason_timeout'), '1');
    });
  });
}
