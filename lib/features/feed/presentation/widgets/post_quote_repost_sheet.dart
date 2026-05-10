import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:poptart_lex/app/bsky/feed/post.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/cache/lazurite_image_cache.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';

class PostQuoteRepostSheet extends StatefulWidget {
  const PostQuoteRepostSheet({
    super.key,
    required this.postUri,
    required this.quoteCount,
    required this.repostCount,
    required this.repository,
  });

  final AtUri postUri;
  final int quoteCount;
  final int repostCount;
  final PostActionRepository repository;

  @override
  State<PostQuoteRepostSheet> createState() => _PostQuoteRepostSheetState();
}

class _PostQuoteRepostSheetState extends State<PostQuoteRepostSheet> {
  final List<PostView> _quotes = [];
  bool _loadingQuotes = false;
  String? _quotesCursor;
  bool _quotesLoaded = false;

  final List<ProfileView> _reposters = [];
  bool _loadingReposts = false;
  String? _repostsCursor;
  bool _repostsLoaded = false;
  bool _repostsExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    if (_loadingQuotes) return;
    setState(() => _loadingQuotes = true);
    try {
      final output = await widget.repository.getQuotes(uri: widget.postUri, cursor: _quotesCursor);
      if (mounted) {
        setState(() {
          _quotes.addAll(output.posts);
          _quotesCursor = output.cursor;
          _quotesLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _quotesLoaded = true);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingQuotes = false);
      }
    }
  }

  Future<void> _loadReposts() async {
    if (_loadingReposts) return;
    setState(() => _loadingReposts = true);
    try {
      final output = await widget.repository.getRepostedBy(uri: widget.postUri, cursor: _repostsCursor);
      if (mounted) {
        setState(() {
          _reposters.addAll(output.repostedBy);
          _repostsCursor = output.cursor;
          _repostsLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _repostsLoaded = true);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingReposts = false);
      }
    }
  }

  void _toggleReposts(bool expanded) {
    setState(() => _repostsExpanded = expanded);
    if (expanded && !_repostsLoaded) {
      _loadReposts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.35,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              context.l10n.labelQuoteReposts,
              style: context.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuotesGroup(context),
            const SizedBox(height: 12),
            _buildRepostsGroup(context),
          ],
        );
      },
    );
  }

  Widget _buildQuotesGroup(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: colorScheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Icon(Icons.format_quote, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.labelQuotes,
                    style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${widget.quoteCount}',
                  style: context.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_loadingQuotes && _quotes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_quotesLoaded && _quotes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.messageNoQuotesYet, style: TextStyle(color: colorScheme.onSurfaceVariant)),
            )
          else
            Column(
              children: [
                for (final quote in _quotes) _QuotePostTile(quote: quote),
                if (_quotesCursor != null)
                  TextButton(
                    onPressed: _loadingQuotes ? null : _loadQuotes,
                    child: _loadingQuotes
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(context.l10n.buttonLoadMoreQuotes),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRepostsGroup(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: colorScheme.outlineVariant)),
      child: ExpansionTile(
        key: const ValueKey('quote-repost-reposts-expansion'),
        initiallyExpanded: _repostsExpanded,
        onExpansionChanged: _toggleReposts,
        iconColor: colorScheme.onSurfaceVariant,
        collapsedIconColor: colorScheme.onSurfaceVariant,
        leading: Icon(Icons.repeat, color: colorScheme.onSurfaceVariant),
        title: Text(
          context.l10n.labelReposts,
          style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.repostCount}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(width: 4),
            Icon(_repostsExpanded ? Icons.expand_less : Icons.expand_more, color: colorScheme.onSurfaceVariant),
          ],
        ),
        children: [
          const Divider(height: 1),
          if (_loadingReposts && _reposters.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_repostsLoaded && _reposters.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.messageNoRepostsYet, style: TextStyle(color: colorScheme.onSurfaceVariant)),
            )
          else
            Column(
              children: [
                for (final profile in _reposters) _ReposterTile(profile: profile),
                if (_repostsCursor != null)
                  TextButton(
                    onPressed: _loadingReposts ? null : _loadReposts,
                    child: _loadingReposts
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(context.l10n.buttonLoadMoreReposts),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _QuotePostTile extends StatelessWidget {
  const _QuotePostTile({required this.quote});

  final PostView quote;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final displayName = quote.author.displayName ?? quote.author.handle;
    final text = _quoteTextFromRecord(quote.record);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: CircleAvatar(
        backgroundImage: appCachedImageProvider(quote.author.avatar),
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: quote.author.avatar == null ? Text(displayName.substring(0, 1).toUpperCase()) : null,
      ),
      title: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(text.isEmpty ? '@${quote.author.handle}' : text, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () {
        final router = GoRouter.maybeOf(context);
        Navigator.of(context).pop();
        router?.push('/post?uri=${Uri.encodeQueryComponent(quote.uri.toString())}');
      },
    );
  }

  String _quoteTextFromRecord(Map<String, dynamic> record) {
    try {
      return FeedPostRecord.fromJson(record).text;
    } catch (_) {
      final value = record['text'];
      return value is String ? value : '';
    }
  }
}

class _ReposterTile extends StatelessWidget {
  const _ReposterTile({required this.profile});

  final ProfileView profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final displayName = profile.displayName ?? profile.handle;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: CircleAvatar(
        backgroundImage: appCachedImageProvider(profile.avatar),
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: profile.avatar == null ? Text(displayName.substring(0, 1).toUpperCase()) : null,
      ),
      title: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('@${profile.handle}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
      onTap: () {
        Navigator.of(context).pop();
        navigateToProfile(context, profile.did);
      },
    );
  }
}
