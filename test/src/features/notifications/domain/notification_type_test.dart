import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/notifications/domain/notification_type.dart';

void main() {
  group('NotificationType', () {
    group('fromString', () {
      test('parses like', () {
        expect(NotificationType.fromString('like'), NotificationType.like);
      });

      test('parses repost', () {
        expect(NotificationType.fromString('repost'), NotificationType.repost);
      });

      test('parses follow', () {
        expect(NotificationType.fromString('follow'), NotificationType.follow);
      });

      test('parses mention', () {
        expect(NotificationType.fromString('mention'), NotificationType.mention);
      });

      test('parses reply', () {
        expect(NotificationType.fromString('reply'), NotificationType.reply);
      });

      test('parses quote', () {
        expect(NotificationType.fromString('quote'), NotificationType.quote);
      });

      test('parses starterpack-joined with kebab-case', () {
        expect(
          NotificationType.fromString('starterpack-joined'),
          NotificationType.starterpackJoined,
        );
      });

      test('parses starterpackJoined with camelCase', () {
        expect(
          NotificationType.fromString('starterpackJoined'),
          NotificationType.starterpackJoined,
        );
      });

      test('returns null for unknown type', () {
        expect(NotificationType.fromString('unknown'), isNull);
      });

      test('is case insensitive', () {
        expect(NotificationType.fromString('LIKE'), NotificationType.like);
        expect(NotificationType.fromString('Follow'), NotificationType.follow);
      });
    });

    group('displayText', () {
      test('like returns correct text', () {
        expect(NotificationType.like.displayText, 'liked your post');
      });

      test('repost returns correct text', () {
        expect(NotificationType.repost.displayText, 'reposted your post');
      });

      test('follow returns correct text', () {
        expect(NotificationType.follow.displayText, 'followed you');
      });

      test('mention returns correct text', () {
        expect(NotificationType.mention.displayText, 'mentioned you');
      });

      test('reply returns correct text', () {
        expect(NotificationType.reply.displayText, 'replied to your post');
      });

      test('quote returns correct text', () {
        expect(NotificationType.quote.displayText, 'quoted your post');
      });

      test('starterpackJoined returns correct text', () {
        expect(NotificationType.starterpackJoined.displayText, 'joined via your starter pack');
      });
    });
  });
}
