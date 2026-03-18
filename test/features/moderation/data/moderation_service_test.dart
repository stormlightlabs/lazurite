import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

/// Tests for ModerationService.
///
/// Note: Since Bluesky, ActorService, and LabelerService are sealed/base
/// classes, we cannot mock them with mocktail. Instead, we test the
/// ModerationService's behavior through its public API, focusing on:
/// - Default behavior before initialization (null opts)
/// - State management (currentOpts, optsStream)
/// - Moderation methods returning correct types
void main() {
  late ModerationService moderationService;

  setUp(() {
    moderationService = ModerationService(bluesky: Bluesky.anonymous());
  });

  tearDown(() {
    moderationService.dispose();
  });

  group('ModerationService', () {
    group('initial state', () {
      test('currentOpts is null before initialize', () {
        expect(moderationService.currentOpts, isNull);
      });

      test('optsStream is a broadcast stream', () {
        expect(moderationService.optsStream.isBroadcast, isTrue);
      });
    });

    group('moderatePost', () {
      test('returns ModerationDecision when opts are null', () {
        final result = moderationService.moderatePost(_makeSamplePostView());
        expect(result, isA<bsky_moderation.ModerationDecision>());
      });
    });

    group('moderateProfile', () {
      test('returns ModerationDecision with ProfileView when opts are null', () {
        final result = moderationService.moderateProfile(
          const ProfileView(did: 'did:plc:user', handle: 'user.bsky.social'),
        );
        expect(result, isA<bsky_moderation.ModerationDecision>());
      });
    });

    group('moderateProfileBasic', () {
      test('returns ModerationDecision with ProfileViewBasic when opts are null', () {
        final result = moderationService.moderateProfileBasic(
          const ProfileViewBasic(did: 'did:plc:user', handle: 'user.bsky.social'),
        );
        expect(result, isA<bsky_moderation.ModerationDecision>());
      });
    });

    group('moderateProfileDetailed', () {
      test('returns ModerationDecision with ProfileViewDetailed when opts are null', () {
        const profile = ProfileViewDetailed(did: 'did:plc:user', handle: 'user.bsky.social');
        final result = moderationService.moderateProfileDetailed(profile);
        expect(result, isA<bsky_moderation.ModerationDecision>());
      });
    });

    group('dispose', () {
      test('can be called without error', () {
        expect(() => moderationService.dispose(), returnsNormally);
      });

      test('closes the opts stream', () async {
        moderationService.dispose();
        final isDone = await moderationService.optsStream.isEmpty;
        expect(isDone, isTrue);
      });
    });

    group('ModerationOpts', () {
      test('can be constructed with prefs and empty labelDefs', () {
        const prefs = bsky_moderation.ModerationPrefs(
          adultContentEnabled: false,
          labels: {},
          labelers: [],
          mutedWords: [],
          hiddenPosts: [],
        );
        const opts = bsky_moderation.ModerationOpts(prefs: prefs);
        expect(opts.prefs.adultContentEnabled, isFalse);
        expect(opts.labelDefs, isEmpty);
      });
    });
  });
}

PostView _makeSamplePostView() {
  return PostView(
    uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/abc'),
    cid: 'cid-123',
    author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social'),
    record: const {r'$type': 'app.bsky.feed.post', 'text': 'Hello world'},
    indexedAt: DateTime.utc(2026, 3, 15),
  );
}
