import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionStorage extends Mock implements SessionStorage {}

void main() {
  late MockSessionStorage mockSessionStorage;

  setUp(() {
    mockSessionStorage = MockSessionStorage();
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [sessionStorageProvider.overrideWithValue(mockSessionStorage)],
      child: const MaterialApp(home: ProfileScreen()),
    );
  }

  group('ProfileScreen', () {
    testWidgets('renders app bar with profile title', (tester) async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      await tester.pumpWidget(createSubject());
      await tester.pump();

      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('shows sign in message when not authenticated', (tester) async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      await tester.pumpWidget(createSubject());
      await tester.pump();

      expect(find.text('Sign in to view your profile'), findsOneWidget);
    });
  });
}
