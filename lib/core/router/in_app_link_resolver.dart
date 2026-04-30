class InAppLinkResolver {
  const InAppLinkResolver._();

  static String? resolveRoute(String rawLink) {
    final trimmed = rawLink.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.toLowerCase().startsWith('at://')) {
      return _resolveAtUriRaw(trimmed);
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return null;
    }

    if (_isBskyAppUri(uri)) {
      return _resolveBskyAppUri(uri);
    }

    return null;
  }

  static bool _isBskyAppUri(Uri uri) {
    return (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.toLowerCase() == 'bsky.app';
  }

  static String? _resolveAtUriRaw(String rawAtUri) {
    final match = RegExp(r'^at://([^/?#]+)/([^/?#]+)(?:/([^/?#]+))?').firstMatch(rawAtUri);
    if (match == null) {
      return null;
    }

    final actor = (match.group(1) ?? '').trim();
    final collection = (match.group(2) ?? '').trim();
    final rkey = (match.group(3) ?? '').trim();

    if (actor.isEmpty || collection.isEmpty) {
      return null;
    }

    if (collection == 'app.bsky.feed.post' && rkey.isNotEmpty) {
      final canonical = 'at://$actor/$collection/$rkey';
      return '/post?uri=${Uri.encodeQueryComponent(canonical)}';
    }

    if (collection == 'app.bsky.actor.profile') {
      return '/profile/${Uri.encodeComponent(actor)}';
    }

    return null;
  }

  static String? _resolveBskyAppUri(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length < 2 || segments.first != 'profile') {
      return null;
    }

    final actor = segments[1].trim();
    if (actor.isEmpty) {
      return null;
    }

    if (segments.length >= 4 && segments[2] == 'post') {
      final rkey = segments[3].trim();
      if (rkey.isEmpty) {
        return null;
      }
      final atUri = 'at://$actor/app.bsky.feed.post/$rkey';
      return '/post?uri=${Uri.encodeQueryComponent(atUri)}';
    }

    return '/profile/${Uri.encodeComponent(actor)}';
  }
}
