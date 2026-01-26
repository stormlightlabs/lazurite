import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/animations/animation_utils.dart';
import 'package:lazurite/src/core/utils/error_message.dart';
import 'package:lazurite/src/core/widgets/empty_state.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/core/widgets/pull_to_refresh_wrapper.dart';
import 'package:lazurite/src/features/dms/domain/dm_conversation.dart';
import 'package:lazurite/src/features/dms/presentation/widgets/message_request_card.dart';

import 'conversation_list_notifier.dart';
import 'widgets/conversation_list_item.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends ConsumerState<ConversationListScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _declinedConvoIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(conversationListProvider.notifier).loadMore();
    }
  }

  void _declineConversation(String convoId) {
    setState(() {
      _declinedConvoIds.add(convoId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message request declined'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _declinedConvoIds.remove(convoId);
            });
          },
        ),
      ),
    );
  }

  void _pop(BuildContext context, {bool? result}) => Navigator.pop(context, result);

  void _tapMute(BuildContext context, DmConversation convo) {
    _pop(context);
    final notifier = ref.read(conversationListProvider.notifier);
    if (convo.isMuted) {
      notifier.unmuteConversation(convo.convoId);
    } else {
      notifier.muteConversation(convo.convoId);
    }
  }

  Widget _buildEmptyRefresher() {
    return PullToRefreshWrapper(
      onRefresh: () => ref.read(conversationListProvider.notifier).refresh(),
      child: const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: EmptyState(
          icon: Icons.chat_bubble_outline,
          title: 'No messages yet',
          subtitle: 'Start a conversation with someone!',
        ),
      ),
    );
  }

  Widget _buildListTitle(TextTheme textTheme, ColorScheme colorScheme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          'Message Requests',
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _acceptConversation(String convoId) async {
    await ref.read(conversationListProvider.notifier).acceptConversation(convoId);
  }

  Widget _muteIcon(bool muted) {
    return Icon(muted ? Icons.notifications_off_outlined : Icons.notifications_outlined);
  }

  Widget _alertDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Leave conversation?'),
      content: const Text(
        'This will remove the conversation from your inbox. You can rejoin if you receive a new message.',
      ),
      actions: [
        TextButton(onPressed: () => _pop(context, result: false), child: const Text('Cancel')),
        TextButton(onPressed: () => _pop(context, result: true), child: const Text('Leave')),
      ],
    );
  }

  Future<bool> _onDismiss(
    BuildContext context,
    DmConversation convo,
    DismissDirection direction,
  ) async {
    final notifier = ref.read(conversationListProvider.notifier);
    if (direction == DismissDirection.startToEnd) {
      await notifier.markAsRead(convo.convoId);
      return false;
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => _alertDialog(context),
      );

      if (confirm == true) {
        await notifier.leaveConversation(convo.convoId);
        return true;
      }
      return false;
    }
  }

  Widget _conversationListItem(BuildContext context, DmConversation convo) {
    return ConversationListItem(
      conversation: convo,
      onTap: () => context.push('/messages/${convo.convoId}'),
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: _muteIcon(convo.isMuted),
                title: Text(convo.isMuted ? 'Unmute' : 'Mute'),
                onTap: () => _tapMute(context, convo),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShowAll(TextTheme textTheme, ColorScheme colorScheme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          'All Messages',
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationListProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), actions: null),
      body: AnimatedContentSwitcher(
        child: state.when(
          data: (conversations) {
            if (conversations.isEmpty) return _buildEmptyRefresher();

            final active = conversations.where((c) => c.isAccepted).toList();
            final requests = conversations
                .where((c) => !c.isAccepted && !_declinedConvoIds.contains(c.convoId))
                .toList();

            return PullToRefreshWrapper(
              onRefresh: () => ref.read(conversationListProvider.notifier).refresh(),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (requests.isNotEmpty) ...[
                    _buildListTitle(textTheme, colorScheme),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final convo = requests[index];
                        return MessageRequestCard(
                          conversation: convo,
                          onTap: () => context.push('/messages/${convo.convoId}'),
                          onAccept: () async => await _acceptConversation(convo.convoId),
                          onDecline: () => _declineConversation(convo.convoId),
                        );
                      }, childCount: requests.length),
                    ),
                    const SliverToBoxAdapter(child: Divider()),
                  ],
                  if (active.isNotEmpty) ...[
                    if (requests.isNotEmpty) _buildShowAll(textTheme, colorScheme),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final convo = active[index];
                        return Dismissible(
                          key: ValueKey(convo.convoId),
                          background: Container(
                            color: colorScheme.primary,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.mark_chat_read, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: colorScheme.error,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await _onDismiss(context, convo, direction);
                          },
                          child: _conversationListItem(context, convo),
                        );
                      }, childCount: active.length),
                    ),
                  ] else if (requests.isNotEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('No active conversations')),
                    ),
                ],
              ),
            );
          },
          loading: () => const LoadingView(),
          error: (error, stack) => ErrorView(
            title: 'Failed to load messages',
            message: errorMessage(error),
            onRetry: () => ref.read(conversationListProvider.notifier).refresh(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/search?type=people'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
