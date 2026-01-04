import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/profile_header.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ProfileHeader', () {
    final testProfile = ProfileData(
      did: 'did:plc:test123',
      handle: 'testuser.bsky.social',
      displayName: 'Test User',
      description: 'This is a test bio for the profile header.',
      avatar: null,
      banner: null,
      followersCount: 1500,
      followsCount: 250,
      postsCount: 100,
    );

    testWidgets('renders display name and handle', (tester) async {
      await tester.pumpApp(Material(child: ProfileHeader(profile: testProfile)));

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('@testuser.bsky.social'), findsOneWidget);
    });

    testWidgets('renders bio/description', (tester) async {
      await tester.pumpApp(Material(child: ProfileHeader(profile: testProfile)));

      expect(find.text('This is a test bio for the profile header.'), findsOneWidget);
    });

    testWidgets('renders follower count', (tester) async {
      await tester.pumpApp(Material(child: ProfileHeader(profile: testProfile)));

      expect(find.text('1.5K'), findsOneWidget);
      expect(find.text('Followers'), findsOneWidget);
    });

    testWidgets('renders following count', (tester) async {
      await tester.pumpApp(Material(child: ProfileHeader(profile: testProfile)));

      expect(find.text('250'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('renders posts count', (tester) async {
      await tester.pumpApp(Material(child: ProfileHeader(profile: testProfile)));

      expect(find.text('100'), findsOneWidget);
      expect(find.text('Posts'), findsOneWidget);
    });

    testWidgets('hides bio when null', (tester) async {
      final noBioProfile = ProfileData(
        did: 'did:plc:nobio',
        handle: 'nobio.bsky.social',
        description: null,
      );

      await tester.pumpApp(Material(child: ProfileHeader(profile: noBioProfile)));

      expect(find.text('nobio.bsky.social'), findsWidgets);
    });

    testWidgets('uses handle when display name is null', (tester) async {
      final noDisplayNameProfile = ProfileData(
        did: 'did:plc:noname',
        handle: 'noname.bsky.social',
      );

      await tester.pumpApp(Material(child: ProfileHeader(profile: noDisplayNameProfile)));

      expect(find.text('noname.bsky.social'), findsWidgets);
    });

    testWidgets('follow button is rendered when provided', (tester) async {
      await tester.pumpApp(
        Material(
          child: ProfileHeader(
            profile: testProfile,
            followButton: const ElevatedButton(onPressed: null, child: Text('Follow')),
          ),
        ),
      );

      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('invokes onFollowersPressed callback', (tester) async {
      var pressed = false;

      await tester.pumpApp(
        Material(
          child: ProfileHeader(profile: testProfile, onFollowersPressed: () => pressed = true),
        ),
      );

      await tester.tap(find.text('Followers'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('invokes onFollowingPressed callback', (tester) async {
      var pressed = false;

      await tester.pumpApp(
        Material(
          child: ProfileHeader(profile: testProfile, onFollowingPressed: () => pressed = true),
        ),
      );

      await tester.tap(find.text('Following'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('formats follower counts correctly', (tester) async {
      final millionFollowers = ProfileData(
        did: 'did:plc:popular',
        handle: 'popular.bsky.social',
        followersCount: 2500000,
        followsCount: 100,
      );

      await tester.pumpApp(Material(child: ProfileHeader(profile: millionFollowers)));

      expect(find.text('2.5M'), findsOneWidget);
    });

    testWidgets('renders avatar placeholder when no image', (tester) async {
      await tester.pumpApp(Material(child: ProfileHeader(profile: testProfile)));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
