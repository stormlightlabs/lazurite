import 'package:bluesky_poptart/chat/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/get_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/bloc/message_bloc.dart';
import 'package:lazurite/features/messages/presentation/group_details_route_args.dart';
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
      ..add(MessagesRequested(convoId: widget.convoId, initialConvo: widget.convo))
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
    if (_inputDisabledReason(context.read<MessageBloc>().state) != null) return;
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
    // TODO: review
    Clipboard.setData(ClipboardData(text: lines));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.messageThreadCopied), duration: const Duration(seconds: 2)));
  }

  ThemeData get _theme => Theme.of(context);

  GroupConvo? _group(MessageState state) => (state.convo ?? widget.convo)?.kind?.groupConvo;

  String _threadTitle(MessageState state) => _group(state)?.name ?? widget.title;

  String? _threadSubtitle(MessageState state) {
    final group = _group(state);
    if (group == null) return null;
    return context.l10n.formatMemberCount(group.memberCount);
  }

  String? _inputDisabledReason(MessageState state) {
    final convo = state.convo ?? widget.convo;
    final status = convo?.status?.knownValue;
    if (status == KnownConvoStatus.request) {
      return context.l10n.messageAcceptRequestBeforeReplying;
    }

    final lockStatus = _group(state)?.lockStatus.knownValue;
    if (lockStatus == KnownConvoLockStatus.lockedPermanently) {
      return context.l10n.messageGroupPermanentlyLocked;
    }
    if (lockStatus == KnownConvoLockStatus.locked) {
      return context.l10n.messageGroupLocked;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserDid = context.read<MessageBloc>().currentUserDid;

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<MessageBloc, MessageState>(
          buildWhen: (previous, current) => previous.convo != current.convo,
          builder: (context, state) {
            final subtitle = _threadSubtitle(state);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _threadTitle(state),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _theme.textTheme.titleMedium,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _theme.textTheme.bodySmall?.copyWith(color: _theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<MessageBloc, MessageState>(
            builder: (context, state) {
              final convo = state.convo ?? widget.convo;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (convo?.kind?.groupConvo != null)
                    IconButton(
                      tooltip: context.l10n.tooltipGroupDetails,
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => context.push(
                        '/alerts/messages/${widget.convoId}/details',
                        extra: GroupDetailsRouteArgs(convo: convo),
                      ),
                    ),
                  PopupMenuButton<_ThreadAction>(
                    onSelected: (action) {
                      if (action == _ThreadAction.copyAll && state.messages.isNotEmpty) {
                        _copyAllMessages(state.messages);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: _ThreadAction.copyAll, child: Text(context.l10n.buttonCopyAll)),
                    ],
                  ),
                ],
              );
            },
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
                    final members = (state.convo ?? widget.convo)?.members ?? const <ProfileViewBasic>[];
                    return message.when(
                      messageView: (data) => MessageBubble(
                        message: data,
                        isCurrentUser: data.sender.did == currentUserDid,
                        senderProfile: _profileForDid(members, data.sender.did),
                      ),
                      deletedMessageView: (data) => const DeletedMessageBubble(isCurrentUser: false),
                      systemMessageView: (data) => _SystemMessageRow(message: data, members: members),
                      unknown: (_) => const SizedBox.shrink(),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<MessageBloc, MessageState>(
            buildWhen: (previous, current) =>
                previous.convo != current.convo || previous.isSending != current.isSending,
            builder: (context, state) => _buildInputBar(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, MessageState state) {
    final disabledReason = _inputDisabledReason(state);
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
            IconButton.filled(
              onPressed: inputEnabled && !state.isSending ? _sendMessage : null,
              icon: state.isSending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(
                      Icons.send,
                      color: inputEnabled ? _theme.colorScheme.onPrimary : _theme.colorScheme.onSurfaceVariant,
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

ProfileViewBasic? _profileForDid(List<ProfileViewBasic> members, String did) {
  for (final member in members) {
    if (member.did == did) return member;
  }
  return null;
}

class _SystemMessageRow extends StatelessWidget {
  const _SystemMessageRow({required this.message, required this.members});

  final SystemMessageView message;
  final List<ProfileViewBasic> members;

  @override
  Widget build(BuildContext context) {
    final text = _systemMessageText(context, message.data);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: Semantics(
          label: context.l10n.semanticSystemMessage(text),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _systemMessageText(BuildContext context, USystemMessageViewData data) {
    final added = data.systemMessageDataAddMember;
    if (added != null) {
      final name = _displayNameForDid(added.member.did);
      return name == null ? context.l10n.systemMessageMemberAdded : context.l10n.systemMessageNamedMemberAdded(name);
    }
    final removed = data.systemMessageDataRemoveMember;
    if (removed != null) {
      final name = _displayNameForDid(removed.member.did);
      return name == null
          ? context.l10n.systemMessageMemberRemoved
          : context.l10n.systemMessageNamedMemberRemoved(name);
    }
    final joined = data.systemMessageDataMemberJoin;
    if (joined != null) {
      final name = _displayNameForDid(joined.member.did);
      return name == null ? context.l10n.systemMessageMemberJoined : context.l10n.systemMessageNamedMemberJoined(name);
    }
    final left = data.systemMessageDataMemberLeave;
    if (left != null) {
      final name = _displayNameForDid(left.member.did);
      return name == null ? context.l10n.systemMessageMemberLeft : context.l10n.systemMessageNamedMemberLeft(name);
    }
    if (data.systemMessageDataLockConvo != null) return context.l10n.systemMessageGroupLocked;
    if (data.systemMessageDataUnlockConvo != null) return context.l10n.systemMessageGroupUnlocked;
    if (data.systemMessageDataLockConvoPermanently != null) return context.l10n.systemMessageGroupPermanentlyLocked;
    final editGroup = data.systemMessageDataEditGroup;
    if (editGroup?.newName?.trim().isNotEmpty == true) {
      return context.l10n.systemMessageGroupRenamed(editGroup!.newName!);
    }
    if (editGroup != null) return context.l10n.systemMessageGroupNameUpdated;
    if (data.systemMessageDataCreateJoinLink != null) return context.l10n.systemMessageJoinLinkCreated;
    if (data.systemMessageDataEditJoinLink != null) return context.l10n.systemMessageJoinLinkUpdated;
    if (data.systemMessageDataEnableJoinLink != null) return context.l10n.systemMessageJoinLinkEnabled;
    if (data.systemMessageDataDisableJoinLink != null) return context.l10n.systemMessageJoinLinkDisabled;
    return context.l10n.messageGroupUpdated;
  }

  String? _displayNameForDid(String did) {
    final profile = _profileForDid(members, did);
    if (profile == null) return null;
    final displayName = profile.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    return profile.handle;
  }
}
