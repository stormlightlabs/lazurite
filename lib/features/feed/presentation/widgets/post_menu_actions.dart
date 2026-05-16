import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_web_links.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_interactions_sheet.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_quote_repost_sheet.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/shared/presentation/helpers/haptic_helper.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';

Future<void> showPostOverflowMenu({
  required BuildContext context,
  required PostView post,
  required String accountDid,
  required PostActionRepository repository,
  required VoidCallback onQuote,
  required VoidCallback onShowReport,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  bool isOffline = false,
}) async {
  HapticHelper.mediumImpact();
  final postUri = post.uri.toString();
  final bskyUrl = AppViewWebLinks.postFromAtUri(postUri, appViewProvider: _resolveAppViewProvider(context));

  await showOptionsSheet<void>(
    context: context,
    isScrollControlled: true,
    items: [
      OptionsSheetItem(
        leading: const Icon(Icons.favorite_outline),
        title: context.l10n.labelShowLikedUsers,
        subtitle: context.l10n.messageShowLikedUsersSubtitle,
        enabled: !isOffline,
        onTap: () => showLikedUsersSheet(context: context, post: post, repository: repository),
      ),
      OptionsSheetItem(
        leading: const Icon(Icons.repeat),
        title: context.l10n.labelShowQuoteRepostList,
        subtitle: context.l10n.messageShowQuoteRepostListSubtitle,
        enabled: !isOffline,
        onTap: () => showQuoteRepostSheet(context: context, post: post, repository: repository),
      ),
      OptionsSheetItem(
        leading: const Icon(Icons.format_quote),
        title: context.l10n.labelQuotePost,
        subtitle: context.l10n.messageQuotePostSubtitle,
        enabled: !isOffline,
        onTap: onQuote,
      ),
      OptionsSheetItem(
        leading: const Icon(Icons.copy),
        title: context.l10n.labelCopyLink,
        onTap: () => _copyToClipboard(context, bskyUrl),
      ),
      OptionsSheetItem(
        leading: const Icon(Icons.person_outline),
        title: context.l10n.formatViewHandle(post.author.handle),
        onTap: () => navigateToProfile(context, post.author.did),
      ),
      OptionsSheetItem(
        leading: const Icon(Icons.report_outlined, color: Colors.orange),
        title: context.l10n.labelReportPost,
        onTap: onShowReport,
      ),
      if (post.author.did == accountDid && onEdit != null)
        OptionsSheetItem(leading: const Icon(Icons.edit_outlined), title: context.l10n.labelEditPost, onTap: onEdit),
      if (post.author.did == accountDid && onDelete != null)
        OptionsSheetItem(
          leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
          title: context.l10n.labelDeletePost,
          isDestructive: true,
          onTap: onDelete,
        ),
    ],
  );
}

void showLikedUsersSheet({
  required BuildContext context,
  required PostView post,
  required PostActionRepository repository,
}) {
  showAppBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => PostInteractionsSheet(
      postUri: post.uri,
      likeCount: post.likeCount ?? 0,
      repostCount: post.repostCount ?? 0,
      initialTab: InteractionTab.likes,
      repository: repository,
    ),
  );
}

void showQuoteRepostSheet({
  required BuildContext context,
  required PostView post,
  required PostActionRepository repository,
}) {
  showAppBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => PostQuoteRepostSheet(
      postUri: post.uri,
      quoteCount: post.quoteCount ?? 0,
      repostCount: post.repostCount ?? 0,
      repository: repository,
    ),
  );
}

void _copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  showAppSnackBar(context, context.l10n.messageLinkCopiedToClipboard, behavior: SnackBarBehavior.floating);
}

String _resolveAppViewProvider(BuildContext context) {
  try {
    return context.read<SettingsCubit>().state.appViewProvider;
  } catch (_) {
    return AppViewProviders.defaultKey;
  }
}
