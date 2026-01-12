// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autocomplete_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AutocompleteNotifier)
final autocompleteProvider = AutocompleteNotifierProvider._();

final class AutocompleteNotifierProvider
    extends $AsyncNotifierProvider<AutocompleteNotifier, List<AutocompleteSuggestion>> {
  AutocompleteNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autocompleteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autocompleteNotifierHash();

  @$internal
  @override
  AutocompleteNotifier create() => AutocompleteNotifier();
}

String _$autocompleteNotifierHash() => r'3becb0707d41d2346819baf57d0dde8e16b8a637';

abstract class _$AutocompleteNotifier extends $AsyncNotifier<List<AutocompleteSuggestion>> {
  FutureOr<List<AutocompleteSuggestion>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AutocompleteSuggestion>>, List<AutocompleteSuggestion>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AutocompleteSuggestion>>, List<AutocompleteSuggestion>>,
              AsyncValue<List<AutocompleteSuggestion>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
