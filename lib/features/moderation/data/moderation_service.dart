import 'dart:async';

import 'package:bluesky/bluesky.dart';
import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_notification_listnotifications.dart' as notifications;
import 'package:lazurite/core/logging/app_logger.dart';

class ModerationService {
  ModerationService({required Bluesky bluesky}) : _bluesky = bluesky;

  final Bluesky _bluesky;
  bsky_moderation.ModerationOpts? _opts;
  final _optsController = StreamController<bsky_moderation.ModerationOpts>.broadcast();

  Stream<bsky_moderation.ModerationOpts> get optsStream => _optsController.stream;
  bsky_moderation.ModerationOpts? get currentOpts => _opts;

  Future<void> initialize() async {
    await _rebuildOpts();
  }

  Future<void> updatePreferences() async {
    await _rebuildOpts();
  }

  Future<void> _rebuildOpts() async {
    try {
      final prefsResponse = await _bluesky.actor.getPreferences();
      final prefs = prefsResponse.data.getModerationPrefs();

      final labelDefs = await _bluesky.labeler.getLabelDefinitions(prefs);

      final opts = bsky_moderation.ModerationOpts(prefs: prefs, labelDefs: labelDefs);

      _opts = opts;
      _optsController.add(opts);
    } catch (error) {
      log.w('Failed to build moderation opts: $error');
    }
  }

  bsky_moderation.ModerationDecision moderatePost(PostView post) {
    if (_opts == null) {
      return bsky_moderation.ModerationDecision.merge([]);
    }
    return bsky_moderation.moderatePost(bsky_moderation.ModerationSubjectPost.postView(data: post), _opts!);
  }

  bsky_moderation.ModerationDecision moderateProfile(ProfileView profile) {
    if (_opts == null) {
      return bsky_moderation.ModerationDecision.merge([]);
    }
    return bsky_moderation.moderateProfile(bsky_moderation.ModerationSubjectProfile.profileView(data: profile), _opts!);
  }

  bsky_moderation.ModerationDecision moderateProfileBasic(ProfileViewBasic profile) {
    if (_opts == null) {
      return bsky_moderation.ModerationDecision.merge([]);
    }
    return bsky_moderation.moderateProfile(
      bsky_moderation.ModerationSubjectProfile.profileViewBasic(data: profile),
      _opts!,
    );
  }

  bsky_moderation.ModerationDecision moderateProfileDetailed(ProfileViewDetailed profile) {
    if (_opts == null) {
      return bsky_moderation.ModerationDecision.merge([]);
    }
    return bsky_moderation.moderateProfile(
      bsky_moderation.ModerationSubjectProfile.profileViewDetailed(data: profile),
      _opts!,
    );
  }

  bsky_moderation.ModerationDecision moderateNotification(notifications.Notification notification) {
    if (_opts == null) {
      return bsky_moderation.ModerationDecision.merge([]);
    }
    return bsky_moderation.moderateNotification(
      bsky_moderation.ModerationSubjectNotification.notification(data: notification),
      _opts!,
    );
  }

  void dispose() {
    _optsController.close();
  }
}
