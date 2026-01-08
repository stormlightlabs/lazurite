// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing conversation detail state.
///
/// Provides a stream of messages for a specific conversation and handles
/// sending new messages via the outbox pattern.

@ProviderFor(ConversationDetailNotifier)
final conversationDetailProvider = ConversationDetailNotifierFamily._();

/// Notifier for managing conversation detail state.
///
/// Provides a stream of messages for a specific conversation and handles
/// sending new messages via the outbox pattern.
final class ConversationDetailNotifierProvider
    extends $StreamNotifierProvider<ConversationDetailNotifier, List<AppDmMessage>> {
  /// Notifier for managing conversation detail state.
  ///
  /// Provides a stream of messages for a specific conversation and handles
  /// sending new messages via the outbox pattern.
  ConversationDetailNotifierProvider._({
    required ConversationDetailNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationDetailNotifierHash();

  @override
  String toString() {
    return r'conversationDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ConversationDetailNotifier create() => ConversationDetailNotifier();

  @override
  bool operator ==(Object other) {
    return other is ConversationDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationDetailNotifierHash() => r'82824e14b49d96cd6ee2fe248f5673e7f9f07704';

/// Notifier for managing conversation detail state.
///
/// Provides a stream of messages for a specific conversation and handles
/// sending new messages via the outbox pattern.

final class ConversationDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ConversationDetailNotifier,
          AsyncValue<List<AppDmMessage>>,
          List<AppDmMessage>,
          Stream<List<AppDmMessage>>,
          String
        > {
  ConversationDetailNotifierFamily._()
    : super(
        retry: null,
        name: r'conversationDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notifier for managing conversation detail state.
  ///
  /// Provides a stream of messages for a specific conversation and handles
  /// sending new messages via the outbox pattern.

  ConversationDetailNotifierProvider call(String convoId) =>
      ConversationDetailNotifierProvider._(argument: convoId, from: this);

  @override
  String toString() => r'conversationDetailProvider';
}

/// Notifier for managing conversation detail state.
///
/// Provides a stream of messages for a specific conversation and handles
/// sending new messages via the outbox pattern.

abstract class _$ConversationDetailNotifier extends $StreamNotifier<List<AppDmMessage>> {
  late final _$args = ref.$arg as String;
  String get convoId => _$args;

  Stream<List<AppDmMessage>> build(String convoId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<AppDmMessage>>, List<AppDmMessage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AppDmMessage>>, List<AppDmMessage>>,
              AsyncValue<List<AppDmMessage>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
