import 'package:atproto/com_atproto_admin_defs.dart';
import 'package:atproto/com_atproto_moderation_createreport.dart';
import 'package:atproto/com_atproto_moderation_defs.dart';
import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/bluesky.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';

class ProfileActionRepository {
  ProfileActionRepository({
    required Bluesky bluesky,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
  }) : _bluesky = bluesky,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       );

  final Bluesky _bluesky;
  final AppViewRequestContext _appViewContext;

  Future<String> followActor({required String did}) async {
    final response = await _bluesky.graph.follow.create(
      subject: did,
      createdAt: DateTime.now(),
      $headers: _appViewContext.appBskyHeaders(),
    );

    return response.data.uri.toString();
  }

  Future<void> unfollowActor({required String followUri}) async {
    final rkey = _extractRkey(followUri);
    await _bluesky.graph.follow.delete(rkey: rkey, $headers: _appViewContext.appBskyHeaders());
  }

  Future<void> muteActor({required String did}) async {
    await _bluesky.graph.muteActor(actor: did, $headers: _appViewContext.appBskyHeaders());
  }

  Future<void> unmuteActor({required String did}) async {
    await _bluesky.graph.unmuteActor(actor: did, $headers: _appViewContext.appBskyHeaders());
  }

  Future<String> blockActor({required String did}) async {
    final response = await _bluesky.graph.block.create(
      subject: did,
      createdAt: DateTime.now(),
      $headers: _appViewContext.appBskyHeaders(),
    );

    return response.data.uri.toString();
  }

  Future<void> unblockActor({required String blockUri}) async {
    final rkey = _extractRkey(blockUri);
    await _bluesky.graph.block.delete(rkey: rkey, $headers: _appViewContext.appBskyHeaders());
  }

  Future<String> reportPost({
    required AtUri postUri,
    required String cid,
    required ReasonType reasonType,
    String? reason,
  }) async {
    final response = await _bluesky.atproto.moderation.createReport(
      reasonType: reasonType,
      subject: UModerationCreateReportSubject.repoStrongRef(
        data: RepoStrongRef(cid: cid, uri: postUri),
      ),
      reason: reason,
    );

    return response.data.id.toString();
  }

  Future<String> reportActor({required String did, required ReasonType reasonType, String? reason}) async {
    final response = await _bluesky.atproto.moderation.createReport(
      reasonType: reasonType,
      subject: UModerationCreateReportSubject.repoRef(data: RepoRef(did: did)),
      reason: reason,
    );

    return response.data.id.toString();
  }

  String _extractRkey(String uri) {
    final atUri = AtUri.parse(uri);
    return atUri.rkey;
  }
}
