import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/utils/url_utils.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _FakeUrlLauncher extends Fake with MockPlatformInterfaceMixin implements UrlLauncherPlatform {
  _FakeUrlLauncher({this.launchResult = true});

  final bool launchResult;
  final launchedUrls = <String>[];
  final launchOptions = <LaunchOptions>[];
  final canLaunchCalls = <String>[];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    launchOptions.add(options);
    return launchResult;
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;

  @override
  Future<bool> canLaunch(String url) async {
    canLaunchCalls.add(url);
    return false;
  }
}

void main() {
  group('externalUriFor', () {
    test('returns null for blank values', () {
      expect(externalUriFor('   '), isNull);
    });

    test('trims values and preserves existing schemes', () {
      expect(externalUriFor(' https://example.com/path ')?.toString(), 'https://example.com/path');
      expect(externalUriFor('mailto:info@stormlightlabs.org')?.toString(), 'mailto:info@stormlightlabs.org');
      expect(externalUriFor('tel:+15551234567')?.toString(), 'tel:+15551234567');
    });

    test('adds https only when requested and no scheme is present', () {
      expect(externalUriFor('example.com/path'), isNull);
      expect(
        externalUriFor('example.com/path', addHttpsSchemeWhenMissing: true)?.toString(),
        'https://example.com/path',
      );
    });

    test('does not force https onto unparsable scheme values', () {
      expect(externalUriFor('at://did:plc:test/app.bsky.feed.post/abc', addHttpsSchemeWhenMissing: true), isNull);
    });
  });

  group('openExternalUrl', () {
    test('launches with external application mode without preflight canLaunch check', () async {
      final fakeLauncher = _FakeUrlLauncher();
      UrlLauncherPlatform.instance = fakeLauncher;

      final launched = await openExternalUrl('https://example.com/article');

      expect(launched, isTrue);
      expect(fakeLauncher.launchedUrls, ['https://example.com/article']);
      expect(fakeLauncher.launchOptions.single.mode, PreferredLaunchMode.externalApplication);
      expect(fakeLauncher.canLaunchCalls, isEmpty);
    });

    test('returns false and does not launch blank values', () async {
      final fakeLauncher = _FakeUrlLauncher();
      UrlLauncherPlatform.instance = fakeLauncher;

      final launched = await openExternalUrl('   ');

      expect(launched, isFalse);
      expect(fakeLauncher.launchedUrls, isEmpty);
    });

    test('returns platform launch result', () async {
      final fakeLauncher = _FakeUrlLauncher(launchResult: false);
      UrlLauncherPlatform.instance = fakeLauncher;

      final launched = await openExternalUrl('https://example.com/article');

      expect(launched, isFalse);
      expect(fakeLauncher.launchedUrls, ['https://example.com/article']);
    });
  });
}
