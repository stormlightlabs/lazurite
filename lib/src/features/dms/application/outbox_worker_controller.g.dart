// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_worker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller that manages automatic background processing of the DM outbox.
///
/// Triggers [OutboxRepository.processOutbox] when:
/// - Periodically every 10 seconds
/// - App resumes from background
/// - User authenticates

@ProviderFor(outboxWorkerController)
final outboxWorkerControllerProvider = OutboxWorkerControllerProvider._();

/// Controller that manages automatic background processing of the DM outbox.
///
/// Triggers [OutboxRepository.processOutbox] when:
/// - Periodically every 10 seconds
/// - App resumes from background
/// - User authenticates

final class OutboxWorkerControllerProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Controller that manages automatic background processing of the DM outbox.
  ///
  /// Triggers [OutboxRepository.processOutbox] when:
  /// - Periodically every 10 seconds
  /// - App resumes from background
  /// - User authenticates
  OutboxWorkerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxWorkerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxWorkerControllerHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return outboxWorkerController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }
}

String _$outboxWorkerControllerHash() => r'617a170abd76382a9e2d3aa944ef18a458a4bf0d';
