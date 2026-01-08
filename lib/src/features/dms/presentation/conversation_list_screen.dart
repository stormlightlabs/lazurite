import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/animation_utils.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/pull_to_refresh_wrapper.dart';
import 'conversation_list_notifier.dart';
import 'widgets/conversation_list_item.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends ConsumerState<ConversationListScreen> {
  final ScrollController _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), actions: null),
      body: AnimatedContentSwitcher(
        child: state.when(
          data: (conversations) {
            if (conversations.isEmpty) {
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

            final requests = conversations.where((c) => !c.isAccepted).toList();
            final active = conversations.where((c) => c.isAccepted).toList();

            return PullToRefreshWrapper(
              onRefresh: () => ref.read(conversationListProvider.notifier).refresh(),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (requests.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Message Requests',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final convo = requests[index];
                        return ConversationListItem(
                          conversation: convo,
                          onTap: () => context.push('/messages/${convo.convoId}'),
                        );
                      }, childCount: requests.length),
                    ),
                    const SliverToBoxAdapter(child: Divider()),
                  ],
                  if (active.isNotEmpty) ...[
                    if (requests.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'All Messages',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final convo = active[index];
                        return Dismissible(
                          key: ValueKey(convo.convoId),
                          background: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.mark_chat_read, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            final notifier = ref.read(conversationListProvider.notifier);
                            if (direction == DismissDirection.startToEnd) {
                              await notifier.markAsRead(convo.convoId);
                              return false;
                            } else {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Leave conversation?'),
                                  content: const Text(
                                    'This will remove the conversation from your inbox. You can rejoin if you receive a new message.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Leave'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await notifier.leaveConversation(convo.convoId);
                                return true;
                              }
                              return false;
                            }
                          },
                          child: ConversationListItem(
                            conversation: convo,
                            onTap: () => context.push('/messages/${convo.convoId}'),
                            onLongPress: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        convo.isMuted
                                            ? Icons.notifications_off_outlined
                                            : Icons.notifications_outlined,
                                      ),
                                      title: Text(convo.isMuted ? 'Unmute' : 'Mute'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        final notifier = ref.read(
                                          conversationListProvider.notifier,
                                        );
                                        if (convo.isMuted) {
                                          notifier.unmuteConversation(convo.convoId);
                                        } else {
                                          notifier.muteConversation(convo.convoId);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
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
            message: error.toString(),
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
