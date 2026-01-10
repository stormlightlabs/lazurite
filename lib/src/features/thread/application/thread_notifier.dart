import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/thread/domain/thread.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : 'anonymous';
    return repository.getPostThread(postUri, ownerDid);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchThread(postUri));
  }
}
