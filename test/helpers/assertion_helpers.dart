import 'package:flutter_test/flutter_test.dart';

void expectAccountRow({required String handle, String? displayName}) {
  if (displayName != null) {
    expect(find.text(displayName), findsOneWidget);
  }
  expect(find.text('@$handle'), findsOneWidget);
}

void expectErrorState(String title, {String? message, Finder? retryFinder}) {
  expect(find.text(title), findsOneWidget);
  if (message != null) {
    expect(find.text(message), findsOneWidget);
  }
  expect(retryFinder ?? find.text('Retry'), findsOneWidget);
}

Future<void> tapRetry(WidgetTester tester, {Finder? retryFinder}) async {
  await tester.tap(retryFinder ?? find.text('Retry'));
  await tester.pumpAndSettle();
}

void expectOfflineState(String title, {String? message}) {
  expect(find.text(title), findsOneWidget);
  if (message != null) {
    expect(find.text(message), findsOneWidget);
  }
}

void expectListDetailHeader({required String description, required String creatorHandle}) {
  expect(find.text(description), findsOneWidget);
  expect(find.text('by @$creatorHandle'), findsOneWidget);
}

Future<void> tapMembersTab(WidgetTester tester) async {
  await tester.tap(find.text('MEMBERS'));
  await tester.pumpAndSettle();
}

void expectListMember({required String handle, String? displayName}) =>
    expectAccountRow(handle: handle, displayName: displayName);

void expectFeedEmbed({required String name, String? description, String? likeCount}) {
  expect(find.text('FEED'), findsOneWidget);
  expect(find.text(name), findsOneWidget);
  if (description != null) expect(find.text(description), findsOneWidget);
  if (likeCount != null) expect(find.text(likeCount), findsOneWidget);
}

void expectListEmbed({required String name, String? description}) {
  expect(find.text('LIST'), findsOneWidget);
  expect(find.text(name), findsOneWidget);
  if (description != null) expect(find.text(description), findsOneWidget);
}
