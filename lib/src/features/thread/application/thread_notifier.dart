import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/thread_repository.dart';
import 'thread_providers.dart';

part 'thread_notifier.g.dart';

@riverpod
class ThreadNotifier extends _$ThreadNotifier {
  @override
  FutureOr<ThreadViewPost> build(String postUri) {
    return _fetchThread(postUri);
  }

  Future<ThreadViewPost> _fetchThread(String postUri) async {
    final repository = ref.read(threadRepositoryProvider);
    return repository.getPostThread(postUri);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchThread(postUri));
  }
}
