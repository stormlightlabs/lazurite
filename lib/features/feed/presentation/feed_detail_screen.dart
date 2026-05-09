import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/feed_layout_view.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';
import 'package:lazurite/shared/presentation/widgets/staggered_entrance.dart';

class FeedDetailScreen extends StatefulWidget {
  const FeedDetailScreen({super.key, this.feedUri, this.actor, this.rkey});

  final AtUri? feedUri;
  final String? actor;
  final String? rkey;

  @override
  State<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends State<FeedDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _seenPostUris = <String>{};

  GeneratorView? _generator;
  final List<FeedViewPost> _posts = [];
  String? _cursor;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  AtUri? _resolvedFeedUri;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    _setStateIfMounted(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = context.read<FeedRepository>();
    AtUri? targetUri;
    try {
      targetUri = await _resolveTargetUri(repo);
    } catch (error) {
      _setStateIfMounted(() {
        _isLoading = false;
        _errorMessage = 'Failed to resolve feed: $error';
      });
      return;
    }

    if (targetUri == null) {
      _setStateIfMounted(() {
        _isLoading = false;
        _errorMessage = 'Missing feed identifier.';
      });
      return;
    }

    GeneratorView? generator;
    try {
      generator = await repo.getFeedGenerator(targetUri);
    } catch (_) {}

    try {
      final result = await repo.getFeed(feedUri: targetUri);
      _setStateIfMounted(() {
        _resolvedFeedUri = targetUri;
        _generator = generator;
        _posts
          ..clear()
          ..addAll(result.posts);
        _cursor = result.cursor;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      _setStateIfMounted(() {
        _resolvedFeedUri = targetUri;
        _generator = generator;
        _isLoading = false;
        _errorMessage = 'Failed to load feed: $error';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _cursor == null || _isLoading) {
      return;
    }

    _setStateIfMounted(() => _isLoadingMore = true);
    try {
      final feedUri = _resolvedFeedUri;
      if (feedUri == null) {
        _setStateIfMounted(() => _isLoadingMore = false);
        return;
      }
      final result = await context.read<FeedRepository>().getFeed(feedUri: feedUri, cursor: _cursor);
      _setStateIfMounted(() {
        _posts.addAll(result.posts);
        _cursor = result.cursor;
        _isLoadingMore = false;
      });
    } catch (_) {
      _setStateIfMounted(() => _isLoadingMore = false);
    }
  }

  void _setStateIfMounted(VoidCallback callback) {
    if (!mounted) {
      return;
    }
    setState(callback);
  }

  String _title() {
    final displayName = _generator?.displayName.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    return 'Feed';
  }

  Future<AtUri?> _resolveTargetUri(FeedRepository repo) async {
    final direct = widget.feedUri;
    if (direct != null) {
      return direct;
    }

    final actor = widget.actor?.trim();
    final rkey = widget.rkey?.trim();
    if (actor == null || actor.isEmpty || rkey == null || rkey.isEmpty) {
      return null;
    }

    return repo.resolveFeedGeneratorUri(actor: actor, rkey: rkey);
  }

  String? _subtitle() {
    final creator = _generator?.creator;
    if (creator == null) {
      return null;
    }
    return creator.displayName?.trim().isNotEmpty == true ? 'by ${creator.displayName}' : 'by ${creator.handle}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title()),
        bottom: _subtitle() == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _subtitle()!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Loading feed');
    }

    if (_errorMessage != null && _posts.isEmpty) {
      return ErrorState(
        title: 'Failed to load feed',
        message: _errorMessage!,
        onRetry: _loadInitial,
        icon: Icons.sync_problem_outlined,
      );
    }

    if (_posts.isEmpty) {
      return const EmptyState(message: 'No posts yet', icon: Icons.article_outlined);
    }

    final accountDid = context.read<AuthBloc>().state.tokens?.did ?? '';
    Widget buildCard(int index, PostCardVariant variant) {
      final post = _posts[index];
      final postUri = post.post.uri.toString();
      return StaggeredEntrance(
        itemKey: postUri,
        index: index,
        seenKeys: _seenPostUris,
        child: PostCardWithActions(
          feedViewPost: post,
          accountDid: accountDid,
          variant: variant,
          onDeleted: () {
            _setStateIfMounted(() => _posts.removeWhere((p) => p.post.uri.toString() == postUri));
          },
        ),
      );
    }

    return FeedLayoutView(
      itemCount: _posts.length,
      scrollController: _scrollController,
      isLoadingMore: _isLoadingMore,
      onRefresh: _loadInitial,
      gridItemBuilder: (context, index) => buildCard(index, PostCardVariant.compact),
      linearItemBuilder: (context, index) => buildCard(index, PostCardVariant.card),
    );
  }
}
