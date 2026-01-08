import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_status_provider.g.dart';

@riverpod
Stream<bool> hasPendingSync(Ref ref) {
  final dao = ref.watch(appDatabaseProvider).preferenceSyncQueueDao;
  final authState = ref.watch(authProvider);
  final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

  if (ownerDid == null) return Stream.value(false);

  return dao.watchPendingItems(ownerDid).map((items) => items.isNotEmpty);
}
