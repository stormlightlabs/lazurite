// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_recovery_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DraftRecoveryController)
final draftRecoveryControllerProvider = DraftRecoveryControllerProvider._();

final class DraftRecoveryControllerProvider
    extends $AsyncNotifierProvider<DraftRecoveryController, List<Draft>> {
  DraftRecoveryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftRecoveryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftRecoveryControllerHash();

  @$internal
  @override
  DraftRecoveryController create() => DraftRecoveryController();
}

String _$draftRecoveryControllerHash() => r'8d9f9bd6b47473b64c118f0fa9a4b9fc5236e5cb';

abstract class _$DraftRecoveryController extends $AsyncNotifier<List<Draft>> {
  FutureOr<List<Draft>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Draft>>, List<Draft>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Draft>>, List<Draft>>,
              AsyncValue<List<Draft>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
