import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
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
        title: 'Show Liked Users',
        subtitle: 'View who liked this post',
        enabled: !isOffline,
        onTap: () => showLikedUsersSheet(context: context, post: post, repository: repository),
      ),
      OptionsSheetItem(
        leading: const Icon(Icons.repeat),
        title: 'Show Quote/Repost List',
        subtitle: 'View quote posts and expand reposts',
        enabled: !isOffline,
        onTap: () => showQuoteRepostSheet(context: context, post: post, repository: repository),
      ),
      OptionsSheetItem(
        leading: const Icon(Icons.format_quote),
        title: 'Quote Post',
        subtitle: 'Quote this post with your own text',
        enabled: !isOffline,
        onTap: onQuote,
      ),
      OptionsSheetItem(
        leading: const Icon(Icons.copy),
        title: 'Copy Link',
        onTap: () => _copyToClipboard(context, bskyUrl),
      ),
      OptionsSheetItem(
        leading: const Icon(Icons.person_outline),
        title: 'View @${post.author.handle}',
        onTap: () => navigateToProfile(context, post.author.did),
      ),
      OptionsSheetItem(
        leading: const Icon(Icons.report_outlined, color: Colors.orange),
        title: 'Report Post',
        onTap: onShowReport,
      ),
      if (post.author.did == accountDid && onEdit != null)
        OptionsSheetItem(leading: const Icon(Icons.edit_outlined), title: 'Edit Post', onTap: onEdit),
      if (post.author.did == accountDid && onDelete != null)
        OptionsSheetItem(
          leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
          title: 'Delete Post',
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
  showAppSnackBar(context, 'Link copied to clipboard', behavior: SnackBarBehavior.floating);
}

String _resolveAppViewProvider(BuildContext context) {
  try {
    return context.read<SettingsCubit>().state.appViewProvider;
  } catch (_) {
    return AppViewProviders.defaultKey;
  }
}
