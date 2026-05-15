import 'dart:convert';

import 'package:bluesky_poptart/app/bsky/richtext/facet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/feed/presentation/widgets/facet_text.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _FakeUrlLauncher extends Fake with MockPlatformInterfaceMixin implements UrlLauncherPlatform {
  final List<String> launchedUrls = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return true;
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;

  @override
  Future<bool> canLaunch(String url) async => true;
}

void main() {
  late _FakeUrlLauncher fakeUrlLauncher;

  setUp(() {
    fakeUrlLauncher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = fakeUrlLauncher;
  });

  testWidgets('hashtag text routes to in-app hashtag screen', (tester) async {
    String? pushed;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: FacetText(text: '#atproto')),
        ),
        GoRoute(
          path: '/hashtag',
          builder: (context, state) {
            pushed = state.uri.toString();
            return const Scaffold(body: Text('hashtag'));
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('#atproto', findRichText: true));
    await tester.pumpAndSettle();

    expect(pushed, isNotNull);
    expect(Uri.parse(pushed!).path, '/hashtag');
    expect(Uri.parse(pushed!).queryParameters['tag'], 'atproto');
  });

  testWidgets('bsky profile URL routes in-app to profile', (tester) async {
    String? pushed;
    const text = 'https://bsky.app/profile/alice.bsky.social';

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: FacetText(text: text)),
        ),
        GoRoute(
          path: '/profile/:actor',
          builder: (context, state) {
            pushed = state.uri.toString();
            return const Scaffold(body: Text('profile'));
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text(text, findRichText: true));
    await tester.pumpAndSettle();

    expect(pushed, isNotNull);
    expect(Uri.parse(pushed!).path, '/profile/alice.bsky.social');
  });

  testWidgets('at:// post URI routes in-app to post thread', (tester) async {
    String? pushed;
    const text = 'at://did:plc:alice/app.bsky.feed.post/abc123';
    final bytes = utf8.encode(text);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: FacetText(
              text: text,
              facets: [
                RichtextFacet(
                  index: RichtextFacetByteSlice(byteStart: 0, byteEnd: bytes.length),
                  features: const [URichtextFacetFeatures.richtextFacetLink(data: RichtextFacetLink(uri: text))],
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/post',
          builder: (context, state) {
            pushed = state.uri.toString();
            return const Scaffold(body: Text('post'));
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text(text, findRichText: true));
    await tester.pumpAndSettle();

    expect(pushed, isNotNull);
    expect(Uri.parse(pushed!).path, '/post');
    expect(
      Uri.decodeQueryComponent(Uri.parse(pushed!).queryParameters['uri']!),
      'at://did:plc:alice/app.bsky.feed.post/abc123',
    );
  });

  testWidgets('unsupported link launches external browser', (tester) async {
    const text = 'https://example.com/hello';
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: FacetText(text: text)),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text(text, findRichText: true));
    await tester.pumpAndSettle();

    expect(fakeUrlLauncher.launchedUrls, contains(text));
  });
}
