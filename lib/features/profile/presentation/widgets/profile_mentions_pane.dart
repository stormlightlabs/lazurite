import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:poptart_bluesky_moderation/poptart_bluesky_moderation.dart' as bsky_moderation;

/// Profile tab that shows posts whose rich-text facets mention the profile DID.
class ProfileMentionsPane extends StatefulWidget {
  const ProfileMentionsPane({super.key, required this.actorDid, required this.profileRepository});

  final String actorDid;
  final ProfileRepository profileRepository;

  @override
  State<ProfileMentionsPane> createState() => _ProfileMentionsPaneState();
}

class _ProfileMentionsPaneState extends State<ProfileMentionsPane> {
  List<PostView> _posts = const [];
  String? _cursor;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void didUpdateWidget(covariant ProfileMentionsPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actorDid != widget.actorDid) {
      _loadInitial();
    }
  }

  /// Loads the first mentions page for the current profile DID.
  ///
  /// The widget resets local paging state because `didUpdateWidget` can reuse
  /// the same pane while the enclosing profile screen changes actors.
  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _posts = const [];
      _cursor = null;
      _hasMore = true;
    });

    try {
      final page = await widget.profileRepository.getActorMentions(actor: widget.actorDid, limit: 50);
      if (!mounted) return;
      setState(() {
        _posts = page.posts;
        _cursor = page.cursor;
        _hasMore = page.cursor != null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load mentions: $error';
        _isLoading = false;
      });
    }
  }

  /// Loads the next AppView search page and appends only unseen post URIs.
  ///
  /// Search results can shift between requests, so duplicate filtering happens
  /// in the pane even though the repository ranks each page independently.
  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _cursor == null) {
      return;
    }
    setState(() => _isLoadingMore = true);

    try {
      final page = await widget.profileRepository.getActorMentions(actor: widget.actorDid, cursor: _cursor, limit: 50);
      if (!mounted) return;
      final seen = _posts.map((post) => post.uri.toString()).toSet();
      setState(() {
        _posts = [
          ..._posts,
          for (final post in page.posts)
            if (seen.add(post.uri.toString())) post,
        ];
        _cursor = page.cursor;
        _hasMore = page.cursor != null;
        _isLoadingMore = false;
      });
    } catch (error, stackTrace) {
      log.d('ProfileMentionsPane: ignored load-more failure', error: error, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CustomScrollView(
        key: PageStorageKey<String>('profile-mentions-loading'),
        slivers: [SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()))],
      );
    }

    if (_error != null) {
      return CustomScrollView(
        key: const PageStorageKey<String>('profile-mentions-error'),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _loadInitial, child: Text(context.l10n.buttonRetry)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_posts.isEmpty) {
      return const CustomScrollView(
        key: PageStorageKey<String>('profile-mentions-empty'),
        slivers: [SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('No mentions yet')))],
      );
    }

    final accountDid = context.read<AuthBloc>().state.tokens?.did ?? '';
    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels > notification.metrics.maxScrollExtent - 300) {
            _loadMore();
          }
          return false;
        },
        child: ListView.builder(
          key: const PageStorageKey<String>('profile-mentions-list'),
          itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return PostCardWithActions(
              feedViewPost: FeedViewPost(post: _posts[index]),
              accountDid: accountDid,
              moderationContext: bsky_moderation.ModerationBehaviorContext.contentList,
            );
          },
        ),
      ),
    );
  }
}
