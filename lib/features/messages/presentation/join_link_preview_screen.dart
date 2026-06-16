import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:bluesky_poptart/chat/bsky/group/defs.dart';
import 'package:bluesky_poptart/chat/bsky/group/request_join.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/messages/presentation/message_thread_route_args.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

class JoinLinkPreviewScreen extends StatefulWidget {
  const JoinLinkPreviewScreen({super.key, required this.code});

  final String code;

  @override
  State<JoinLinkPreviewScreen> createState() => _JoinLinkPreviewScreenState();
}

class _JoinLinkPreviewScreenState extends State<JoinLinkPreviewScreen> {
  late Future<JoinLinkPreviewView> _previewFuture;
  bool _isRequesting = false;
  String? _message;
  ConvoView? _pendingConvo;
  bool _pendingWithoutConvo = false;

  ConvoRepository get _repository => context.read<ConvoRepository>();

  @override
  void initState() {
    super.initState();
    _previewFuture = _repository.previewJoinLink(widget.code);
  }

  Future<void> _requestJoin() async {
    setState(() {
      _isRequesting = true;
      _message = null;
    });
    try {
      final result = await _repository.requestJoin(widget.code);
      if (!mounted) return;
      final convo = result.convo;
      if (convo != null) {
        context.read<ConvoListBloc>().add(ConvoUpserted(convo: convo));
      }
      final status = result.status.knownValue;
      if (status == KnownGroupRequestJoinStatus.joined && convo != null) {
        _openConvo(convo);
        return;
      }
      setState(() {
        _pendingConvo = convo;
        _pendingWithoutConvo = status == KnownGroupRequestJoinStatus.pending && convo == null;
        _message = context.l10n.messageJoinRequestSent;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _message = context.l10n.errorCouldNotRequestJoinGroup);
      }
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  Future<void> _withdrawRequest(String convoId) async {
    setState(() {
      _isRequesting = true;
      _message = null;
    });
    try {
      await _repository.withdrawJoinRequest(convoId);
      if (mounted) {
        setState(() {
          _pendingConvo = null;
          _pendingWithoutConvo = false;
          _message = context.l10n.messageJoinRequestWithdrawn;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = context.l10n.errorCouldNotWithdrawJoinRequest);
      }
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  void _openConvo(ConvoView convo) => context.go(
    '/alerts/messages/${convo.id}',
    extra: MessageThreadRouteArgs(title: convo.kind?.groupConvo?.name ?? context.l10n.labelConversation, convo: convo),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.labelJoinGroup)),
    body: FutureBuilder<JoinLinkPreviewView>(
      future: _previewFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return _JoinPreviewError(
            onRetry: () => setState(() => _previewFuture = _repository.previewJoinLink(widget.code)),
          );
        }
        return _JoinPreviewBody(
          preview: snapshot.data!,
          isRequesting: _isRequesting,
          message: _message,
          pendingConvo: _pendingConvo,
          pendingWithoutConvo: _pendingWithoutConvo,
          onOpenConvo: _openConvo,
          onRequestJoin: _requestJoin,
          onWithdrawRequest: _withdrawRequest,
        );
      },
    ),
  );
}

class _JoinPreviewBody extends StatelessWidget {
  const _JoinPreviewBody({
    required this.preview,
    required this.isRequesting,
    required this.message,
    required this.pendingConvo,
    required this.pendingWithoutConvo,
    required this.onOpenConvo,
    required this.onRequestJoin,
    required this.onWithdrawRequest,
  });

  final JoinLinkPreviewView preview;
  final bool isRequesting;
  final String? message;
  final ConvoView? pendingConvo;
  final bool pendingWithoutConvo;
  final void Function(ConvoView convo) onOpenConvo;
  final VoidCallback onRequestJoin;
  final void Function(String convoId) onWithdrawRequest;

  @override
  Widget build(BuildContext context) {
    final owner = preview.owner;
    final ownerName = owner.displayName?.trim().isNotEmpty == true ? owner.displayName! : owner.handle;
    final existingConvo = preview.convo;
    final withdrawConvo = _withdrawableConvo(pendingConvo ?? existingConvo);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Text(preview.name, style: context.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          context.l10n.formatMemberCount(preview.memberCount),
          style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ProfileAvatar(size: 44, imageUrl: owner.avatar, fallbackText: ownerName),
          title: Text(ownerName, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('@${owner.handle}', maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(height: 16),
        if (message != null) ...[Text(message!, style: context.textTheme.bodyMedium), const SizedBox(height: 12)],
        if (pendingWithoutConvo)
          _PendingWithoutConvoNotice(isRequesting: isRequesting)
        else if (withdrawConvo != null)
          OutlinedButton.icon(
            key: const ValueKey('join_link_withdraw_request_button'),
            onPressed: isRequesting ? null : () => onWithdrawRequest(withdrawConvo.id),
            icon: const Icon(Icons.undo),
            label: Text(context.l10n.buttonWithdrawRequest),
          )
        else if (existingConvo != null)
          FilledButton.icon(
            key: const ValueKey('join_link_open_group_button'),
            onPressed: () => onOpenConvo(existingConvo),
            icon: const Icon(Icons.forum_outlined),
            label: Text(context.l10n.buttonOpenGroup),
          )
        else
          FilledButton.icon(
            key: const ValueKey('join_link_request_join_button'),
            onPressed: isRequesting ? null : onRequestJoin,
            icon: isRequesting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.group_add_outlined),
            label: Text(preview.requireApproval ? context.l10n.buttonRequestToJoin : context.l10n.buttonJoinGroup),
          ),
      ],
    );
  }

  ConvoView? _withdrawableConvo(ConvoView? convo) {
    if (convo?.status?.knownValue == KnownConvoStatus.request) {
      return convo;
    }
    return null;
  }
}

class _PendingWithoutConvoNotice extends StatelessWidget {
  const _PendingWithoutConvoNotice({required this.isRequesting});

  final bool isRequesting;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hourglass_empty, size: 18, color: context.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(context.l10n.labelRequestPending, style: context.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(context.l10n.messagePendingJoinRequestCannotWithdrawHere, style: context.textTheme.bodyMedium),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey('join_link_pending_without_convo_button'),
            onPressed: null,
            icon: isRequesting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.schedule),
            label: Text(context.l10n.labelWaitingForApproval),
          ),
        ],
      ),
    ),
  );
}

class _JoinPreviewError extends StatelessWidget {
  const _JoinPreviewError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.errorJoinLinkInvalidOrDisabled),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: Text(context.l10n.buttonRetry)),
      ],
    ),
  );
}
