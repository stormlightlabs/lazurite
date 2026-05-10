import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:poptart_lex/com/atproto/admin/defs.dart';
import 'package:poptart_lex/com/atproto/moderation/create_report.dart';
import 'package:poptart_lex/com/atproto/moderation/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';

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
      $headers: _appViewContext.appBskyHeadersWithoutProxy(),
    );

    return response.data.uri.toString();
  }

  Future<void> unfollowActor({required String followUri}) async {
    final rkey = _extractRkey(followUri);
    await _bluesky.graph.follow.delete(rkey: rkey, $headers: _appViewContext.appBskyHeadersWithoutProxy());
  }

  Future<void> muteActor({required String did}) async {
    await _bluesky.graph.muteActor(actor: did, $headers: _appViewContext.appBskyHeadersWithoutProxy());
  }

  Future<void> unmuteActor({required String did}) async {
    await _bluesky.graph.unmuteActor(actor: did, $headers: _appViewContext.appBskyHeadersWithoutProxy());
  }

  Future<String> blockActor({required String did}) async {
    final response = await _bluesky.graph.block.create(
      subject: did,
      createdAt: DateTime.now(),
      $headers: _appViewContext.appBskyHeadersWithoutProxy(),
    );

    return response.data.uri.toString();
  }

  Future<void> unblockActor({required String blockUri}) async {
    final rkey = _extractRkey(blockUri);
    await _bluesky.graph.block.delete(rkey: rkey, $headers: _appViewContext.appBskyHeadersWithoutProxy());
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
