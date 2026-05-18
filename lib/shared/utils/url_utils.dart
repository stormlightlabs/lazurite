import 'package:url_launcher/url_launcher.dart';

Future<bool> openExternalUrl(String value, {bool addHttpsSchemeWhenMissing = false}) async {
  final uri = externalUriFor(value, addHttpsSchemeWhenMissing: addHttpsSchemeWhenMissing);
  if (uri == null) {
    return false;
  }
  return openExternalUri(uri);
}

Future<bool> openExternalUri(Uri value) => launchUrl(value, mode: LaunchMode.externalApplication);

Uri? externalUriFor(String value, {bool addHttpsSchemeWhenMissing = false}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.hasScheme) {
    return uri;
  }

  if (!addHttpsSchemeWhenMissing) {
    return null;
  }

  return Uri.tryParse('https://$trimmed');
}
