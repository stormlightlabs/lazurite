import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animations/animation_utils.dart';
import '../../../core/utils/error_message.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/pull_to_refresh_wrapper.dart';
import '../../../features/auth/application/auth_providers.dart';
import '../../../features/auth/domain/auth_state.dart';
import '../domain/dm_conversation.dart';
import '../providers.dart';
import 'conversation_detail_notifier.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_composer.dart';

/// Screen displaying a conversation's message thread.
///
/// Shows messages in chronological order with newest at bottom,
/// supports pull-to-refresh for older messages, and includes
/// a composer for sending new messages.
class ConversationDetailScreen extends ConsumerStatefulWidget {
  const ConversationDetailScreen({super.key, required this.convoId});

  final String convoId;

  @override
  ConsumerState<ConversationDetailScreen> createState() => _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends ConsumerState<ConversationDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  DmConversation? _conversation;

  @override
  void initState() {
    super.initState();
    _loadConversation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationDetailProvider(widget.convoId).notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) return;

    final repo = ref.read(dmsRepositoryProvider);
    final convo = await repo.getConversation(widget.convoId, authState.session.did);
    if (mounted) {
      setState(() => _conversation = convo);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String? _extractOutboxId(String messageId) {
    if (messageId.startsWith('pending:')) {
      return messageId.substring(8);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(conversationDetailProvider(widget.convoId));
    final authState = ref.watch(authProvider);
    final currentUserDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    final otherParty = _conversation?.otherParty;
    final title = otherParty?.displayName ?? otherParty?.handle ?? 'Conversation';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: AnimatedContentSwitcher(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start the conversation!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final sortedMessages = List.of(messages)
                    ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

                  return PullToRefreshWrapper(
                    onRefresh: () =>
                        ref.read(conversationDetailProvider(widget.convoId).notifier).loadMore(),
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: sortedMessages.length,
                      itemBuilder: (context, index) {
                        final message = sortedMessages[index];
                        final isFromMe = message.sender.did == currentUserDid;

                        final showAvatar =
                            index == sortedMessages.length - 1 ||
                            sortedMessages[index + 1].sender.did != message.sender.did;

                        return MessageBubble(
                          message: message,
                          isFromMe: isFromMe,
                          senderProfile: isFromMe ? null : message.sender,
                          showAvatar: showAvatar,
                          onRetry: message.isFailed
                              ? () {
                                  final outboxId = _extractOutboxId(message.messageId);
                                  if (outboxId != null) {
                                    ref
                                        .read(conversationDetailProvider(widget.convoId).notifier)
                                        .retryMessage(outboxId);
                                  }
                                }
                              : null,
                        );
                      },
                    ),
                  );
                },
                loading: () => const LoadingView(),
                error: (error, stack) => ErrorView(
                  title: 'Failed to load messages',
                  message: errorMessage(error),
                  onRetry: () =>
                      ref.read(conversationDetailProvider(widget.convoId).notifier).refresh(),
                ),
              ),
            ),
          ),
          MessageComposer(
            onSend: (text) async {
              await ref
                  .read(conversationDetailProvider(widget.convoId).notifier)
                  .sendMessage(text);
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }
}
