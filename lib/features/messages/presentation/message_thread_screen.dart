import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/get_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/bloc/message_bloc.dart';
import 'package:lazurite/features/messages/presentation/widgets/message_bubble.dart';

class MessageThreadScreen extends StatefulWidget {
  const MessageThreadScreen({super.key, required this.convoId, required this.title, this.convo});

  final String convoId;
  final String title;
  final ConvoView? convo;

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
    } catch (error, stackTrace) {
      log.d('Skipped conversation refresh after closing thread.', error: error, stackTrace: stackTrace);
    }
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
    if (_inputDisabledReason != null) return;
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    context.read<MessageBloc>().add(MessageSent(text: text));
  }

  void _copyAllMessages(List<UConvoGetMessagesMessages> messages) {
    final lines = messages.reversed
        .map(
          (m) => m.when(
            messageView: (data) => data.text,
            deletedMessageView: (_) => '[deleted]',
            systemMessageView: (_) => '',
            unknown: (_) => '',
          ),
        )
        .where((t) => t.isNotEmpty)
        .join('\n');
    Clipboard.setData(ClipboardData(text: lines));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.messageThreadCopied), duration: const Duration(seconds: 2)));
  }

  ThemeData get _theme => Theme.of(context);

  GroupConvo? get _group => widget.convo?.kind?.groupConvo;

  String get _threadTitle => _group?.name ?? widget.title;

  String? get _threadSubtitle {
    final group = _group;
    if (group == null) return null;
    final count = group.memberCount;
    return count == 1 ? '1 member' : '$count members';
  }

  String? get _inputDisabledReason {
    final convo = widget.convo;
    final status = convo?.status?.knownValue;
    if (status == KnownConvoStatus.request) {
      return 'Accept the message request before replying.';
    }

    final lockStatus = _group?.lockStatus.knownValue;
    if (lockStatus == KnownConvoLockStatus.lockedPermanently) {
      return 'This group is permanently locked.';
    }
    if (lockStatus == KnownConvoLockStatus.locked) {
      return 'This group is locked.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserDid = context.read<MessageBloc>().currentUserDid;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_threadTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: _theme.textTheme.titleMedium),
            if (_threadSubtitle != null)
              Text(
                _threadSubtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _theme.textTheme.bodySmall?.copyWith(color: _theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
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
                      systemMessageView: (data) => _SystemMessageRow(message: data),
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

  Widget _buildInputBar(BuildContext context) {
    final disabledReason = _inputDisabledReason;
    final inputEnabled = disabledReason == null;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _theme.colorScheme.surface,
          border: Border(top: BorderSide(color: _theme.dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (disabledReason != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        disabledReason,
                        textAlign: TextAlign.center,
                        style: _theme.textTheme.bodySmall?.copyWith(color: _theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                  TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    enabled: inputEnabled,
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
                ],
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<MessageBloc, MessageState>(
              builder: (context, state) => IconButton.filled(
                onPressed: inputEnabled && !state.isSending ? _sendMessage : null,
                icon: state.isSending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(
                        Icons.send,
                        color: inputEnabled ? _theme.colorScheme.onPrimary : _theme.colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

class _SystemMessageRow extends StatelessWidget {
  const _SystemMessageRow({required this.message});

  final SystemMessageView message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              _systemMessageText(message.data),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ),
    );
  }

  String _systemMessageText(USystemMessageViewData data) {
    if (data.systemMessageDataAddMember != null) return 'A member was added to the group.';
    if (data.systemMessageDataRemoveMember != null) return 'A member was removed from the group.';
    if (data.systemMessageDataMemberJoin != null) return 'A member joined the group.';
    if (data.systemMessageDataMemberLeave != null) return 'A member left the group.';
    if (data.systemMessageDataLockConvo != null) return 'The group was locked.';
    if (data.systemMessageDataUnlockConvo != null) return 'The group was unlocked.';
    if (data.systemMessageDataLockConvoPermanently != null) return 'The group was permanently locked.';
    final editGroup = data.systemMessageDataEditGroup;
    if (editGroup?.newName?.trim().isNotEmpty == true) {
      return 'The group was renamed to ${editGroup!.newName}.';
    }
    if (editGroup != null) return 'The group name was updated.';
    if (data.systemMessageDataCreateJoinLink != null) return 'A join link was created.';
    if (data.systemMessageDataEditJoinLink != null) return 'The join link was updated.';
    if (data.systemMessageDataEnableJoinLink != null) return 'The join link was enabled.';
    if (data.systemMessageDataDisableJoinLink != null) return 'The join link was disabled.';
    return 'Group updated.';
  }
}
