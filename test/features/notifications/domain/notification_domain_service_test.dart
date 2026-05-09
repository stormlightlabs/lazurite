import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/notification/list_notifications.dart' as bsky;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/notification_domain_service.dart';
import 'package:lazurite/features/notifications/domain/local_notification_adapter.dart';
import 'package:lazurite/features/notifications/domain/notification_local_models.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockLocalNotificationAdapter extends Mock implements LocalNotificationAdapter {}

class FakeLocalNotificationRequest extends Fake implements LocalNotificationRequest {}

void main() {
  late MockNotificationRepository repository;
  late MockLocalNotificationAdapter localNotificationAdapter;

  setUp(() {
    repository = MockNotificationRepository();
    localNotificationAdapter = MockLocalNotificationAdapter();
    when(() => localNotificationAdapter.show(any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(FakeLocalNotificationRequest());
  });

  group('NotificationDomainService', () {
    final sampleNotifications = [
      bsky.Notification(
        uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/abc'),
        cid: 'cid-123',
        author: const ProfileView(did: 'did:plc:author', handle: 'author.bsky.social'),
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.like),
        record: const {},
        isRead: false,
        indexedAt: DateTime.utc(2026, 4, 29, 12),
      ),
      bsky.Notification(
        uri: AtUri.parse('at://did:plc:author2/app.bsky.feed.post/def'),
        cid: 'cid-456',
        author: const ProfileView(did: 'did:plc:author2', handle: 'author2.bsky.social'),
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.follow),
        record: const {},
        isRead: true,
        indexedAt: DateTime.utc(2026, 4, 29, 13),
      ),
    ];

    test('persists deliveries and dedupes by accountDid + notificationUri', () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);

      when(
        () => repository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: sampleNotifications, cursor: null));

      final service = NotificationDomainService(
        notificationRepository: repository,
        database: database,
        accountDid: 'did:plc:test',
      );

      await service.listNotifications();
      await service.listNotifications();

      expect(await database.countNotificationDeliveries('did:plc:test'), 2);

      final first = await database.getNotificationDelivery(
        'did:plc:test',
        'at://did:plc:author/app.bsky.feed.post/abc',
      );
      expect(first, isNotNull);
      expect(first!.source, 'poll');
      expect(first.reason, 'like');
    });

    test('updates reason/indexedAt/source on duplicate observation while preserving dedupe', () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);

      final originalNotification = sampleNotifications.first;
      final updatedNotification = bsky.Notification(
        uri: originalNotification.uri,
        cid: originalNotification.cid,
        author: originalNotification.author,
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.repost),
        record: originalNotification.record,
        isRead: originalNotification.isRead,
        indexedAt: DateTime.utc(2026, 5, 2, 10, 0),
      );

      when(
        () => repository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: [originalNotification], cursor: null));

      final service = NotificationDomainService(
        notificationRepository: repository,
        database: database,
        accountDid: 'did:plc:test',
      );

      await service.listNotifications();

      when(
        () => repository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: [updatedNotification], cursor: null));

      await service.listNotifications();

      final delivery = await database.getNotificationDelivery('did:plc:test', originalNotification.uri.toString());

      expect(await database.countNotificationDeliveries('did:plc:test'), 1);
      expect(delivery, isNotNull);
      expect(delivery!.reason, 'repost');
      expect(delivery.source, 'poll');
      expect(delivery.indexedAt.toUtc(), DateTime.utc(2026, 5, 2, 10, 0));
    });

    test('shows local notifications for newly inserted unseen items only once', () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);
      final unseenNotification = sampleNotifications.first;

      when(
        () => repository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: [unseenNotification], cursor: null));

      final service = NotificationDomainService(
        notificationRepository: repository,
        database: database,
        accountDid: 'did:plc:test',
        localNotificationAdapter: localNotificationAdapter,
      );

      await service.listNotifications();
      await service.listNotifications();

      verify(() => localNotificationAdapter.show(any<LocalNotificationRequest>())).called(1);
    });

    test('suppresses local notification display while alerts route is active', () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);
      final unseenNotification = sampleNotifications.first;

      when(
        () => repository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: [unseenNotification], cursor: null));

      final service = NotificationDomainService(
        notificationRepository: repository,
        database: database,
        accountDid: 'did:plc:test',
        localNotificationAdapter: localNotificationAdapter,
        shouldSuppressLocalNotifications: () => true,
      );

      await service.listNotifications();

      verifyNever(() => localNotificationAdapter.show(any<LocalNotificationRequest>()));
      expect(await database.countNotificationDeliveries('did:plc:test'), 1);
    });

    test('listNotifications still works without persistence dependencies', () async {
      when(
        () => repository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: sampleNotifications, cursor: 'next'));

      final service = NotificationDomainService(notificationRepository: repository);
      final result = await service.listNotifications();

      expect(result.notifications.length, 2);
      expect(result.cursor, 'next');
    });

    test('markSeen delegates to repository', () async {
      when(() => repository.updateSeen()).thenAnswer((_) async {});
      final service = NotificationDomainService(notificationRepository: repository);

      await service.markSeen();

      verify(() => repository.updateSeen()).called(1);
    });
  });
}
