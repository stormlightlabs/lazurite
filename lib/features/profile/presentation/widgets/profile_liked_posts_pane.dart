import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';

class ProfileLikedPostsPane extends StatefulWidget {
  const ProfileLikedPostsPane({super.key, required this.actor, required this.profileRepository});

  final String actor;
  final ProfileRepository profileRepository;

  @override
  State<ProfileLikedPostsPane> createState() => _ProfileLikedPostsPaneState();
}

class _ProfileLikedPostsPaneState extends State<ProfileLikedPostsPane> {
  List<ProfileActorLikeEntry> _entries = const [];
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
  void didUpdateWidget(covariant ProfileLikedPostsPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actor != widget.actor) {
      _loadInitial();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _entries = const [];
      _cursor = null;
      _hasMore = true;
    });

    try {
      final page = await widget.profileRepository.getActorLikes(actor: widget.actor, limit: 50);
      if (!mounted) return;
      setState(() {
        _entries = page.entries;
        _cursor = page.cursor;
        _hasMore = page.cursor != null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load liked posts: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadInitial();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _cursor == null) {
      return;
    }
    setState(() => _isLoadingMore = true);

    try {
      final page = await widget.profileRepository.getActorLikes(actor: widget.actor, cursor: _cursor, limit: 50);
      if (!mounted) return;
      setState(() {
        _entries = [..._entries, ...page.entries];
        _cursor = page.cursor;
        _hasMore = page.cursor != null;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _loadInitial, child: Text(context.l10n.buttonRetry)),
          ],
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(child: Text(context.l10n.messageNoLikedPostsYet));
    }

    final accountDid = context.read<AuthBloc>().state.tokens?.did ?? '';
    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels > notification.metrics.maxScrollExtent - 300) {
            _loadMore();
          }
          return false;
        },
        child: ListView.builder(
          key: const PageStorageKey<String>('profile-liked-posts-list'),
          itemCount: _entries.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _entries.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final entry = _entries[index];
            if (entry.feedViewPost != null) {
              return PostCardWithActions(
                feedViewPost: entry.feedViewPost!,
                accountDid: accountDid,
                moderationContext: bsky_moderation.ModerationBehaviorContext.contentList,
              );
            }

            return _UnavailableLikedPostCard(
              subjectUri: entry.subjectUri ?? '',
              reason: entry.unavailableReason ?? 'Post unavailable',
            );
          },
        ),
      ),
    );
  }
}

class _UnavailableLikedPostCard extends StatelessWidget {
  const _UnavailableLikedPostCard({required this.subjectUri, required this.reason});

  final String subjectUri;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.hide_source_outlined),
        title: Text(context.l10n.labelUnavailableLikedPost),
        subtitle: Text(reason),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => context.push('/post?uri=${Uri.encodeQueryComponent(subjectUri)}'),
          tooltip: context.l10n.buttonOpen,
        ),
      ),
    );
  }
}
