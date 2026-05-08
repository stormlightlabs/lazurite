import 'package:bluesky/chat_bsky_convo_getmessages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/bloc/message_bloc.dart';
import 'package:lazurite/features/messages/presentation/widgets/message_bubble.dart';

class MessageThreadScreen extends StatefulWidget {
  const MessageThreadScreen({super.key, required this.convoId, required this.title});

  final String convoId;
  final String title;

  @override
  State<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends State<MessageThreadScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<MessageBloc>()
      ..add(MessagesRequested(convoId: widget.convoId))
      ..add(const ConvoMarkedRead());
  }

  @override
  void dispose() {
    try {
      context.read<ConvoListBloc>().add(const ConvosRefreshed());
    } catch (_) {}
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MessageBloc>().add(const MessagesPageLoaded());
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    context.read<MessageBloc>().add(MessageSent(text: text));
  }

  void _copyAllMessages(List<UConvoGetMessagesMessages> messages) {
    final lines = messages.reversed
        .map(
          (m) => m.when(messageView: (data) => data.text, deletedMessageView: (_) => '[deleted]', unknown: (_) => ''),
        )
        .where((t) => t.isNotEmpty)
        .join('\n');
    Clipboard.setData(ClipboardData(text: lines));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.messageThreadCopied), duration: const Duration(seconds: 2)));
  }

  ThemeData get _theme => Theme.of(context);

  @override
  Widget build(BuildContext context) {
    final currentUserDid = context.read<MessageBloc>().currentUserDid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: _theme.textTheme.titleMedium),
        actions: [
          BlocBuilder<MessageBloc, MessageState>(
            builder: (context, state) => PopupMenuButton<_ThreadAction>(
              onSelected: (action) {
                if (action == _ThreadAction.copyAll && state.messages.isNotEmpty) {
                  _copyAllMessages(state.messages);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: _ThreadAction.copyAll, child: Text(context.l10n.buttonCopyAll)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MessageBloc, MessageState>(
              builder: (context, state) {
                if (state.status == MessageStatus.initial ||
                    (state.status == MessageStatus.loading && state.messages.isEmpty)) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == MessageStatus.error && state.messages.isEmpty) {
                  return _buildErrorWidget();
                }

                if (state.messages.isEmpty) {
                  return Center(child: Text(context.l10n.messageNoMessagesYet, style: _theme.textTheme.bodyLarge));
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: state.messages.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final message = state.messages[index];
                    return message.when(
                      messageView: (data) =>
                          MessageBubble(message: data, isCurrentUser: data.sender.did == currentUserDid),
                      deletedMessageView: (data) => const DeletedMessageBubble(isCurrentUser: false),
                      unknown: (_) => const SizedBox.shrink(),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) => SafeArea(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _theme.colorScheme.surface,
        border: Border(top: BorderSide(color: _theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: context.l10n.messagePlaceholder,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                isDense: true,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<MessageBloc, MessageState>(
            builder: (context, state) => IconButton.filled(
              onPressed: state.isSending ? null : _sendMessage,
              icon: state.isSending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.send, color: _theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildErrorWidget() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.l10n.errorFailedToLoadMessages, style: _theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => context.read<MessageBloc>().add(MessagesRequested(convoId: widget.convoId)),
          child: Text(context.l10n.buttonRetry),
        ),
      ],
    ),
  );
}

enum _ThreadAction { copyAll }
