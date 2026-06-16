import 'package:bluesky_poptart/chat/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.isCurrentUser, this.senderProfile});

  final MessageView message;
  final bool isCurrentUser;
  final ProfileViewBasic? senderProfile;

  @override
  Widget build(BuildContext context) {
    final avatar = _MessageAvatar(message: message, profile: senderProfile);
    final bubble = GestureDetector(
      onLongPress: () => _copyMessage(context),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.68),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isCurrentUser ? context.colorScheme.primary : context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isCurrentUser ? 18 : 4),
              bottomRight: Radius.circular(isCurrentUser ? 4 : 18),
            ),
          ),
          child: Text(
            message.text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: isCurrentUser ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          textDirection: isCurrentUser ? TextDirection.rtl : TextDirection.ltr,
          children: [
            avatar,
            const SizedBox(width: 8),
            Flexible(child: bubble),
          ],
        ),
      ),
    );
  }

  void _copyMessage(BuildContext context) {
    // TODO: review
    Clipboard.setData(ClipboardData(text: message.text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.messageCopied), duration: const Duration(seconds: 2)));
  }
}

class _MessageAvatar extends StatelessWidget {
  const _MessageAvatar({required this.message, required this.profile});

  final MessageView message;
  final ProfileViewBasic? profile;

  @override
  Widget build(BuildContext context) {
    final label = profile?.displayName?.trim().isNotEmpty == true ? profile!.displayName! : profile?.handle;
    final fallbackText = label ?? message.sender.did;
    return Tooltip(
      message: fallbackText,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => navigateToProfile(context, profile?.did ?? message.sender.did),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ProfileAvatar(size: 30, imageUrl: profile?.avatar, fallbackText: fallbackText),
        ),
      ),
    );
  }
}

class DeletedMessageBubble extends StatelessWidget {
  const DeletedMessageBubble({super.key, required this.isCurrentUser});

  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    child: Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.outlineVariant),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isCurrentUser ? 18 : 4),
            bottomRight: Radius.circular(isCurrentUser ? 4 : 18),
          ),
        ),
        child: Text(
          context.l10n.messageDeleted,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    ),
  );
}
