import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

enum InteractionTab { likes, reposts }

class PostInteractionsSheet extends StatefulWidget {
  const PostInteractionsSheet({
    super.key,
    required this.postUri,
    required this.likeCount,
    required this.repostCount,
    required this.repository,
    this.initialTab,
  });

  final AtUri postUri;
  final int likeCount;
  final int repostCount;
  final PostActionRepository repository;
  final InteractionTab? initialTab;

  @override
  State<PostInteractionsSheet> createState() => _PostInteractionsSheetState();
}

class _PostInteractionsSheetState extends State<PostInteractionsSheet> {
  late InteractionTab _selectedTab;

  final List<ProfileView> _likers = [];
  bool _loadingLikes = false;
  String? _likesCursor;
  bool _likesLoaded = false;

  final List<ProfileView> _reposters = [];
  bool _loadingReposts = false;
  String? _repostsCursor;
  bool _repostsLoaded = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTab ?? (widget.likeCount > 0 ? InteractionTab.likes : InteractionTab.reposts);
    _selectedTab = initial;
    if (initial == InteractionTab.likes) {
      _loadLikes();
    } else {
      _loadReposts();
    }
  }

  Future<void> _loadLikes() async {
    if (_loadingLikes) return;
    setState(() => _loadingLikes = true);
    try {
      final output = await widget.repository.getLikes(uri: widget.postUri, cursor: _likesCursor);
      if (mounted) {
        setState(() {
          _likers.addAll(output.likes.map((l) => l.actor));
          _likesCursor = output.cursor;
          _likesLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _likesLoaded = true);
    } finally {
      if (mounted) setState(() => _loadingLikes = false);
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
      if (mounted) setState(() => _repostsLoaded = true);
    } finally {
      if (mounted) setState(() => _loadingReposts = false);
    }
  }

  void _selectTab(InteractionTab tab) {
    setState(() => _selectedTab = tab);
    if (tab == InteractionTab.likes && !_likesLoaded) _loadLikes();
    if (tab == InteractionTab.reposts && !_repostsLoaded) _loadReposts();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final hasBothTabs = widget.likeCount > 0 && widget.repostCount > 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasBothTabs) ...[_buildTabBar(context, colorScheme)] else ...[_buildSectionLabel(context, colorScheme)],
            Expanded(
              child: _selectedTab == InteractionTab.likes
                  ? _buildProfileList(
                      profiles: _likers,
                      loading: _loadingLikes,
                      loaded: _likesLoaded,
                      cursor: _likesCursor,
                      onLoadMore: _loadLikes,
                      scrollController: scrollController,
                      colorScheme: colorScheme,
                    )
                  : _buildProfileList(
                      profiles: _reposters,
                      loading: _loadingReposts,
                      loaded: _repostsLoaded,
                      cursor: _repostsCursor,
                      onLoadMore: _loadReposts,
                      scrollController: scrollController,
                      colorScheme: colorScheme,
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionLabel(BuildContext context, ColorScheme colorScheme) {
    final label = _selectedTab == InteractionTab.likes ? 'LIKED BY' : 'REPOSTED BY';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.2,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          _buildTabChip(
            colorScheme: colorScheme,
            tab: InteractionTab.likes,
            icon: Icons.favorite_outline,
            label: '${widget.likeCount} Likes',
          ),
          const SizedBox(width: 10),
          _buildTabChip(
            colorScheme: colorScheme,
            tab: InteractionTab.reposts,
            icon: Icons.repeat,
            label: '${widget.repostCount} Reposts',
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip({
    required ColorScheme colorScheme,
    required InteractionTab tab,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTab == tab;
    return GestureDetector(
      onTap: () => _selectTab(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileList({
    required List<ProfileView> profiles,
    required bool loading,
    required bool loaded,
    required String? cursor,
    required VoidCallback onLoadMore,
    required ScrollController scrollController,
    required ColorScheme colorScheme,
  }) {
    if (!loaded && loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loaded && profiles.isEmpty) {
      return Center(
        child: Text('No interactions yet', style: TextStyle(color: colorScheme.onSurfaceVariant)),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: profiles.length + (cursor != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == profiles.length) {
          if (!loading) onLoadMore();
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = profiles[index];
        final initials = ((profile.displayName?.isNotEmpty == true ? profile.displayName! : profile.handle))
            .substring(0, 1)
            .toUpperCase();

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: profile.avatar != null ? NetworkImage(profile.avatar!) : null,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: profile.avatar == null ? Text(initials) : null,
          ),
          title: Text(profile.displayName ?? profile.handle, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('@${profile.handle}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          onTap: () {
            Navigator.pop(context);
            GoRouter.maybeOf(context)?.push('/profile/view?actor=${Uri.encodeQueryComponent(profile.did)}');
          },
        );
      },
    );
  }
}
