import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'draft_recovery_controller.g.dart';

@riverpod
class DraftRecoveryController extends _$DraftRecoveryController {
  @override
  Future<List<Draft>> build() async {
    return _fetchCrashedDrafts();
  }

  Future<List<Draft>> _fetchCrashedDrafts() async {
    final repository = ref.read(draftRepositoryProvider);
    return repository.getCrashedDrafts();
  }

  Future<void> retry(Draft draft) async {
    final repository = ref.read(draftRepositoryProvider);
    try {
      await repository.publishDraft(draft.id);
      state = AsyncValue.data(state.value?.where((d) => d.id != draft.id).toList() ?? []);
    } catch (e) {
      state = AsyncValue.data(state.value?.where((d) => d.id != draft.id).toList() ?? []);
    }
  }

  Future<void> delete(Draft draft) async {
    final repository = ref.read(draftRepositoryProvider);
    await repository.deleteDraft(draft.id);
    state = AsyncValue.data(state.value?.where((d) => d.id != draft.id).toList() ?? []);
  }

  Future<void> dismiss(Draft draft) async {
    final repository = ref.read(draftRepositoryProvider);
    await repository.markAsFailed(draft.id, 'Dismissed by user during recovery');
    state = AsyncValue.data(state.value?.where((d) => d.id != draft.id).toList() ?? []);
  }
}
