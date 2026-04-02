import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/settings/cubit/video_upload_limits_cubit.dart';
import 'package:lazurite/features/settings/data/video_repository.dart';
import 'package:lazurite/features/settings/presentation/video_upload_limits_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockVideoUploadLimitsCubit extends MockCubit<VideoUploadLimitsState> implements VideoUploadLimitsCubit {}

void main() {
  late MockVideoUploadLimitsCubit cubit;

  setUp(() {
    cubit = MockVideoUploadLimitsCubit();
    when(() => cubit.fetch()).thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<VideoUploadLimitsCubit>.value(value: cubit, child: const VideoUploadLimitsScreen()),
    );
  }

  testWidgets('shows loading indicator when state is loading', (tester) async {
    when(() => cubit.state).thenReturn(const VideoUploadLimitsState.loading());
    whenListen(
      cubit,
      const Stream<VideoUploadLimitsState>.empty(),
      initialState: const VideoUploadLimitsState.loading(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message with warning icon when state has error', (tester) async {
    when(() => cubit.state).thenReturn(const VideoUploadLimitsState.error('Upload service unavailable'));
    whenListen(
      cubit,
      const Stream<VideoUploadLimitsState>.empty(),
      initialState: const VideoUploadLimitsState.error('Upload service unavailable'),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Upload service unavailable'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });

  testWidgets('shows canUpload enabled status when uploads are allowed', (tester) async {
    const limits = VideoUploadLimits(canUpload: true, remainingDailyVideos: 10, remainingDailyBytes: 524288000);
    when(() => cubit.state).thenReturn(const VideoUploadLimitsState.loaded(limits));
    whenListen(
      cubit,
      const Stream<VideoUploadLimitsState>.empty(),
      initialState: const VideoUploadLimitsState.loaded(limits),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Uploads enabled'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('shows canUpload disabled status when uploads are not allowed', (tester) async {
    const limits = VideoUploadLimits(canUpload: false);
    when(() => cubit.state).thenReturn(const VideoUploadLimitsState.loaded(limits));
    whenListen(
      cubit,
      const Stream<VideoUploadLimitsState>.empty(),
      initialState: const VideoUploadLimitsState.loaded(limits),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Uploads disabled'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
  });

  testWidgets('shows remaining daily videos and formatted bytes', (tester) async {
    const limits = VideoUploadLimits(canUpload: true, remainingDailyVideos: 7, remainingDailyBytes: 524288000);
    when(() => cubit.state).thenReturn(const VideoUploadLimitsState.loaded(limits));
    whenListen(
      cubit,
      const Stream<VideoUploadLimitsState>.empty(),
      initialState: const VideoUploadLimitsState.loaded(limits),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Remaining videos today'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Remaining storage today'), findsOneWidget);
    expect(find.text('500.00 MB'), findsOneWidget);
  });

  testWidgets('formats bytes as GB when 1 GB or more', (tester) async {
    const limits = VideoUploadLimits(canUpload: true, remainingDailyBytes: 2147483648);
    when(() => cubit.state).thenReturn(const VideoUploadLimitsState.loaded(limits));
    whenListen(
      cubit,
      const Stream<VideoUploadLimitsState>.empty(),
      initialState: const VideoUploadLimitsState.loaded(limits),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('2.00 GB'), findsOneWidget);
  });

  testWidgets('shows server message when present', (tester) async {
    const limits = VideoUploadLimits(canUpload: true, message: 'Daily limit resets at midnight UTC');
    when(() => cubit.state).thenReturn(const VideoUploadLimitsState.loaded(limits));
    whenListen(
      cubit,
      const Stream<VideoUploadLimitsState>.empty(),
      initialState: const VideoUploadLimitsState.loaded(limits),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Daily limit resets at midnight UTC'), findsOneWidget);
  });

  testWidgets('shows error field with warning styling when limits include an error', (tester) async {
    const limits = VideoUploadLimits(canUpload: false, error: 'Quota exceeded');
    when(() => cubit.state).thenReturn(const VideoUploadLimitsState.loaded(limits));
    whenListen(
      cubit,
      const Stream<VideoUploadLimitsState>.empty(),
      initialState: const VideoUploadLimitsState.loaded(limits),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Quota exceeded'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });

  testWidgets('calls fetch on initState', (tester) async {
    when(() => cubit.state).thenReturn(const VideoUploadLimitsState.initial());
    whenListen(
      cubit,
      const Stream<VideoUploadLimitsState>.empty(),
      initialState: const VideoUploadLimitsState.initial(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    verify(() => cubit.fetch()).called(1);
  });
}
