import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/bluesky.dart';

class PostActionRepository {
  PostActionRepository({required Bluesky bluesky}) : _bluesky = bluesky;

  final Bluesky _bluesky;

  Future<String> likePost({required AtUri uri, required String cid}) async {
    final response = await _bluesky.feed.like.create(
      subject: RepoStrongRef(cid: cid, uri: uri),
      createdAt: DateTime.now(),
    );

    return response.data.uri.toString();
  }

  Future<void> unlikePost({required String likeUri}) async {
    final rkey = _extractRkey(likeUri);
    await _bluesky.feed.like.delete(rkey: rkey);
  }

  Future<String> repostPost({required AtUri uri, required String cid}) async {
    final response = await _bluesky.feed.repost.create(
      subject: RepoStrongRef(cid: cid, uri: uri),
      createdAt: DateTime.now(),
    );

    return response.data.uri.toString();
  }

  Future<void> unrepostPost({required String repostUri}) async {
    final rkey = _extractRkey(repostUri);
    await _bluesky.feed.repost.delete(rkey: rkey);
  }

  Future<void> deletePost({required String postUri}) async {
    final rkey = _extractRkey(postUri);
    await _bluesky.feed.post.delete(rkey: rkey);
  }

  String _extractRkey(String uri) {
    final atUri = AtUri.parse(uri);
    return atUri.rkey;
  }
}
