// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing composer screen state.
///
/// Handles draft creation, autosave, media management, and publishing.

@ProviderFor(ComposerNotifier)
final composerProvider = ComposerNotifierFamily._();

/// Notifier for managing composer screen state.
///
/// Handles draft creation, autosave, media management, and publishing.
final class ComposerNotifierProvider
    extends $AsyncNotifierProvider<ComposerNotifier, ComposerState> {
  /// Notifier for managing composer screen state.
  ///
  /// Handles draft creation, autosave, media management, and publishing.
  ComposerNotifierProvider._({
    required ComposerNotifierFamily super.from,
    required ComposerArgs? super.argument,
  }) : super(
         retry: null,
         name: r'composerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$composerNotifierHash();

  @override
  String toString() {
    return r'composerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ComposerNotifier create() => ComposerNotifier();

  @override
  bool operator ==(Object other) {
    return other is ComposerNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$composerNotifierHash() => r'a9c8963232a27d273c2dc4f1671c9cbc3dc968d8';

/// Notifier for managing composer screen state.
///
/// Handles draft creation, autosave, media management, and publishing.

final class ComposerNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ComposerNotifier,
          AsyncValue<ComposerState>,
          ComposerState,
          FutureOr<ComposerState>,
          ComposerArgs?
        > {
  ComposerNotifierFamily._()
    : super(
        retry: null,
        name: r'composerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notifier for managing composer screen state.
  ///
  /// Handles draft creation, autosave, media management, and publishing.

  ComposerNotifierProvider call(ComposerArgs? args) =>
      ComposerNotifierProvider._(argument: args, from: this);

  @override
  String toString() => r'composerProvider';
}

/// Notifier for managing composer screen state.
///
/// Handles draft creation, autosave, media management, and publishing.

abstract class _$ComposerNotifier extends $AsyncNotifier<ComposerState> {
  late final _$args = ref.$arg as ComposerArgs?;
  ComposerArgs? get args => _$args;

  FutureOr<ComposerState> build(ComposerArgs? args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ComposerState>, ComposerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ComposerState>, ComposerState>,
              AsyncValue<ComposerState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
