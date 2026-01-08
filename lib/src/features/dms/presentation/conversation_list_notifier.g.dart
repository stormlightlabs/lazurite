// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_list_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConversationListNotifier)
final conversationListProvider = ConversationListNotifierProvider._();

final class ConversationListNotifierProvider
    extends $StreamNotifierProvider<ConversationListNotifier, List<DmConversation>> {
  ConversationListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationListNotifierHash();

  @$internal
  @override
  ConversationListNotifier create() => ConversationListNotifier();
}

String _$conversationListNotifierHash() => r'8a0c48fc15f890677f632249df5371a3ff84de0a';

abstract class _$ConversationListNotifier extends $StreamNotifier<List<DmConversation>> {
  Stream<List<DmConversation>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<DmConversation>>, List<DmConversation>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<DmConversation>>, List<DmConversation>>,
              AsyncValue<List<DmConversation>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
