import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_router.dart';

class AppViewWebLinks {
  const AppViewWebLinks._();

  static String postFromAtUri(String atUri, {String? appViewProvider}) {
    final router = AppViewRouter(provider: AppViewProviders.descriptorForSetting(appViewProvider));
    try {
      final match = RegExp(r'^at://([^/?#]+)/([^/?#]+)(?:/([^/?#]+))?').firstMatch(atUri.trim());
      if (match == null) {
        return atUri;
      }

      final did = (match.group(1) ?? '').trim();
      final collection = (match.group(2) ?? '').trim();
      final rkey = (match.group(3) ?? '').trim();
      if (did.isEmpty || collection.isEmpty || rkey.isEmpty) {
        return atUri;
      }

      if (collection != 'app.bsky.feed.post') {
        return atUri;
      }

      final relativePath = '/profile/$did/post/$rkey';
      return router.resolveWebLink(relativePath).toString();
    } catch (_) {
      log.d('failed to convert atUri to appView web URL');
      return atUri;
    }
  }

  static String profile(String actor, {String? appViewProvider}) {
    final router = AppViewRouter(provider: AppViewProviders.descriptorForSetting(appViewProvider));
    final normalizedActor = actor.trim();
    if (normalizedActor.isEmpty) {
      return router.provider.webBaseUrl.toString();
    }

    final relativePath = '/profile/$normalizedActor';
    return router.resolveWebLink(relativePath).toString();
  }
}
