import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:bluesky/app_bsky_richtext_facet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/search/data/hashtag_utils.dart';

PostView _post(String uri, Map<String, dynamic> record) {
  return PostView(
    uri: AtUri.parse(uri),
    cid: 'cid-${uri.hashCode}',
    author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social'),
    record: record,
    indexedAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  group('normalizeHashtag', () {
    test('trims whitespace and leading #', () {
      expect(normalizeHashtag('  #atproto  '), 'atproto');
      expect(normalizeHashtag('###openweb'), 'openweb');
      expect(normalizeHashtag(''), '');
      expect(normalizeHashtag('#'), '');
    });
  });

  group('extractRelatedHashtags', () {
    test('extracts tags from facets and text while excluding current tag', () {
      final facetRecord = FeedPostRecord(
        text: 'launch #atproto #openweb',
        createdAt: DateTime.utc(2026, 1, 1),
        facets: [
          const RichtextFacet(
            index: RichtextFacetByteSlice(byteStart: 7, byteEnd: 15),
            features: [URichtextFacetFeatures.richtextFacetTag(data: RichtextFacetTag(tag: 'atproto'))],
          ),
          const RichtextFacet(
            index: RichtextFacetByteSlice(byteStart: 16, byteEnd: 24),
            features: [URichtextFacetFeatures.richtextFacetTag(data: RichtextFacetTag(tag: 'openweb'))],
          ),
        ],
      );

      final textRecord = FeedPostRecord(text: 'another #openweb #decentralized', createdAt: DateTime.utc(2026, 1, 1));

      final tags = extractRelatedHashtags([
        _post('at://did:plc:author/app.bsky.feed.post/1', facetRecord.toJson()),
        _post('at://did:plc:author/app.bsky.feed.post/2', textRecord.toJson()),
      ], currentTag: 'atproto');

      expect(tags.first, 'openweb');
      expect(tags, contains('decentralized'));
      expect(tags, isNot(contains('atproto')));
    });
  });
}
