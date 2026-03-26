import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/features/connectivity/connectivity_helpers.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/presentation/widgets/facet_text.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_blur_overlay.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderation_badge_row.dart';
import 'package:lazurite/features/search/bloc/search_bloc.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
    context.read<SearchBloc>().add(TypeaheadRequested(query: _searchController.text));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchBloc>().add(const LoadMoreRequested());
    }
  }

  void _onSubmit(String query) {
    if (query.trim().isEmpty) return;
    context.read<SearchBloc>().add(QuerySubmitted(query: query));
    _focusNode.unfocus();
  }

  void _onCancel() {
    _searchController.clear();
    setState(() {});
    context.read<SearchBloc>().add(const QueryCleared());
  }

  void _onTabChanged(SearchTab tab) {
    context.read<SearchBloc>().add(SearchTabChanged(tab: tab));
  }

  void _onSortChanged(String sort) {
    context.read<SearchBloc>().add(SearchSortChanged(sort: sort));
  }

  void _onHistoryTap(String query, String type) {
    _searchController.text = query;
    final tab = type == 'posts' ? SearchTab.posts : SearchTab.actors;
    context.read<SearchBloc>().add(SearchTabChanged(tab: tab));
    context.read<SearchBloc>().add(QuerySubmitted(query: query));
    _focusNode.unfocus();
  }

  void _onHistoryDelete(int id) {
    context.read<SearchBloc>().add(HistoryEntryDeleted(id: id));
  }

  void _onClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear search history?'),
        content: const Text('This will delete all your recent searches.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SearchBloc>().add(const HistoryCleared());
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _openJumpToProfileDialog() {
    final controller = TextEditingController();
    final searchBloc = context.read<SearchBloc>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: searchBloc,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              void submitHandle([String? value]) {
                final rawValue = (value ?? controller.text).trim();
                final handle = rawValue.startsWith('@') ? rawValue.substring(1).trim() : rawValue;
                if (handle.isEmpty) {
                  return;
                }

                searchBloc.add(const TypeaheadRequested(query: ''));
                Navigator.of(dialogContext).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    GoRouter.of(this.context).push('/profile/view?actor=${Uri.encodeQueryComponent(handle)}');
                  }
                });
              }

              return AlertDialog(
                title: const Text('Jump to profile'),
                content: SizedBox(
                  width: 420,
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      final hasResults = state.typeaheadActors.isNotEmpty;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: controller,
                            autofocus: true,
                            autocorrect: false,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              labelText: 'Handle',
                              hintText: 'alice.bsky.social',
                              prefixText: '@',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setDialogState(() {});
                              searchBloc.add(TypeaheadRequested(query: value.isEmpty ? '' : '@$value'));
                            },
                            onSubmitted: submitHandle,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.topLeft,
                            // TODO: hide this when there are > 3 chars in the text field
                            child: Text(
                              'Start typing to search handles.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topCenter,
                            child: hasResults
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: SizedBox(
                                      height: 220,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: state.typeaheadActors.length,
                                        itemBuilder: (context, index) {
                                          final actor = state.typeaheadActors[index];
                                          return _ActorListTile(
                                            actor: actor,
                                            onTap: () {
                                              controller.text = actor.handle;
                                              submitHandle(actor.did);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      searchBloc.add(const TypeaheadRequested(query: ''));
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: controller.text.trim().isEmpty ? null : submitHandle,
                    child: const Text('Open'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openJumpToProfileDialog,
        icon: const Icon(Icons.person_search),
        label: const Text('Jump to profile'),
      ),
      body: SafeArea(
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildSearchBar(context, state),
                _buildTabs(context, state),
                if (state.currentTab == SearchTab.posts && state.hasResults) _buildSortToggle(context, state),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, SearchState state) {
    final hasText = _searchController.text.isNotEmpty;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          const AppShellMenuButton(),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onSubmitted: _onSubmit,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search posts or people',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: hasText ? _buildSuffixIcon(context, theme) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(999)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuffixIcon(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _onCancel,
          icon: const Icon(Icons.close, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
        IconButton(
          onPressed: () => _onSubmit(_searchController.text),
          icon: Icon(Icons.arrow_forward_rounded, size: 20, color: theme.colorScheme.primary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context, SearchState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(children: [_buildTab(context, SearchTab.posts, state), _buildTab(context, SearchTab.actors, state)]),
    );
  }

  Widget _buildTab(BuildContext context, SearchTab tab, SearchState state) {
    final isSelected = state.currentTab == tab;
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
    );
    return Expanded(
      child: InkWell(
        onTap: () => _onTabChanged(tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.transparent, width: 2),
            ),
          ),
          child: Text(tab.label, textAlign: TextAlign.center, style: textStyle),
        ),
      ),
    );
  }

  Widget _buildSortToggle(BuildContext context, SearchState state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Text('Sort by', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSortOption(context, SearchSort.top, state),
                _buildSortOption(context, SearchSort.latest, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, SearchSort sort, SearchState state) {
    final isSelected = state.currentSort == sort.name;
    final theme = Theme.of(context);
    final labelColor = isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => _onSortChanged(sort.name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          sort.label,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: labelColor),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchState state) {
    if (state.typeaheadActors.isNotEmpty && _searchController.text.startsWith('@')) {
      return _buildTypeaheadResults(context, state);
    }

    if (state.query.isEmpty) {
      return _buildSearchHistory(context, state);
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Search failed', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<SearchBloc>().add(QuerySubmitted(query: state.query)),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.currentTab == SearchTab.posts) {
      return _buildPostResults(context, state);
    } else {
      return _buildActorResults(context, state);
    }
  }

  Widget _buildSearchHistory(BuildContext context, SearchState state) {
    final history = state.searchHistory;
    if (history.isEmpty) {
      return const _SearchEmptyState();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Searches', style: Theme.of(context).textTheme.titleSmall),
              TextButton(onPressed: _onClearHistory, child: const Text('Clear All')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              final label = entry.type == 'posts' ? 'Posts' : 'People';
              return Dismissible(
                key: Key('history_${entry.id}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _onHistoryDelete(entry.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  color: Theme.of(context).colorScheme.error,
                  child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
                ),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(entry.query),
                  subtitle: Text('$label · ${_formatHistoryTime(entry.searchedAt)}'),
                  onTap: () => _onHistoryTap(entry.query, entry.type),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeaheadResults(BuildContext context, SearchState state) {
    return ListView.builder(
      itemCount: state.typeaheadActors.length,
      itemBuilder: (context, index) {
        final actor = state.typeaheadActors[index];
        return _ActorListTile(
          actor: actor,
          onTap: () {
            _searchController.text = '@${actor.handle}';
            _onSubmit('@${actor.handle}');
          },
        );
      },
    );
  }

  Widget _buildPostResults(BuildContext context, SearchState state) {
    final posts = state.posts;
    if (posts.isEmpty) {
      return Center(child: Text('No posts found', style: Theme.of(context).textTheme.bodyLarge));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: posts.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return const Center(
            child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          );
        }
        return _PostViewCard(post: posts[index]);
      },
    );
  }

  Widget _buildActorResults(BuildContext context, SearchState state) {
    final actors = state.actors;
    if (actors.isEmpty) {
      return Center(child: Text('No people found', style: Theme.of(context).textTheme.bodyLarge));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: actors.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == actors.length) {
          return const Center(
            child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          );
        }
        return _ActorResultTile(actor: actors[index]);
      },
    );
  }

  String _formatHistoryTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return DateFormat('MMM d').format(time);
  }
}

class _PostViewCard extends StatelessWidget {
  const _PostViewCard({required this.post});

  final PostView post;

  @override
  Widget build(BuildContext context) {
    final record = _tryParseRecord(post.record);
    final createdAt = record?.createdAt ?? post.indexedAt;
    final moderationService = maybeModerationService(context);
    final postUi =
        moderationService?.postUi(post, bsky_moderation.ModerationBehaviorContext.contentList) ??
        const bsky_moderation.ModerationUI();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: ModeratedBlurOverlay(
        ui: postUi,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, post.author, createdAt),
              if (postUi.alert || postUi.inform) ...[const SizedBox(height: 10), ModerationBadgeRow(ui: postUi)],
              if (record != null && record.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                FacetText(text: record.text, facets: record.facets, style: Theme.of(context).textTheme.bodyLarge),
              ],
              const SizedBox(height: 12),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileViewBasic author, DateTime createdAt) {
    final moderationService = maybeModerationService(context);
    final avatarUi =
        moderationService?.profileBasicUi(author, bsky_moderation.ModerationBehaviorContext.avatar) ??
        const bsky_moderation.ModerationUI();
    return InkWell(
      onTap: () => _navigateToProfile(context, author.did),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModeratedAvatar(
            size: 44,
            ui: avatarUi,
            imageUrl: author.avatar,
            initials: _initials(author.displayName ?? author.handle),
            shape: BoxShape.circle,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.displayName ?? author.handle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '@${author.handle} · ${_formatTime(createdAt)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(context, Icons.chat_bubble_outline, '${post.replyCount ?? 0}'),
        _buildActionButton(context, Icons.repeat, '${post.repostCount ?? 0}'),
        _buildActionButton(context, Icons.favorite_border, '${post.likeCount ?? 0}'),
        _buildActionButton(context, Icons.share_outlined, ''),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String count) {
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(count, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: iconColor)),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context, String did) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push('/profile/view?actor=${Uri.encodeQueryComponent(did)}');
    }
  }

  FeedPostRecord? _tryParseRecord(Map<String, dynamic> record) {
    try {
      return FeedPostRecord.fromJson(record);
    } catch (_) {
      return null;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }
    return DateFormat('MMM d').format(time);
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}

class _ActorResultTile extends StatelessWidget {
  const _ActorResultTile({required this.actor});

  final ProfileView actor;

  @override
  Widget build(BuildContext context) {
    final moderationService = maybeModerationService(context);
    final profileUi =
        moderationService?.profileUi(actor, bsky_moderation.ModerationBehaviorContext.profileList) ??
        const bsky_moderation.ModerationUI();
    final avatarUi =
        moderationService?.profileUi(actor, bsky_moderation.ModerationBehaviorContext.avatar) ??
        const bsky_moderation.ModerationUI();

    return InkWell(
      onTap: () => _navigateToProfile(context, actor.did),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            ModeratedAvatar(
              size: 48,
              ui: avatarUi,
              imageUrl: actor.avatar,
              initials: _initials(actor.displayName ?? actor.handle),
              shape: BoxShape.circle,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actor.displayName ?? actor.handle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '@${actor.handle}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  if (profileUi.alert || profileUi.inform) ...[
                    const SizedBox(height: 8),
                    ModerationBadgeRow(ui: profileUi),
                  ],
                  if (actor.description != null && actor.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      actor.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _FollowButton(actor: actor),
          ],
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context, String did) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push('/profile/view?actor=${Uri.encodeQueryComponent(did)}');
    }
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}

class _ActorListTile extends StatelessWidget {
  const _ActorListTile({required this.actor, required this.onTap});

  final ProfileViewBasic actor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final moderationService = maybeModerationService(context);
    final profileUi =
        moderationService?.profileBasicUi(actor, bsky_moderation.ModerationBehaviorContext.profileList) ??
        const bsky_moderation.ModerationUI();
    final avatarUi =
        moderationService?.profileBasicUi(actor, bsky_moderation.ModerationBehaviorContext.avatar) ??
        const bsky_moderation.ModerationUI();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ModeratedAvatar(
              size: 40,
              ui: avatarUi,
              imageUrl: actor.avatar,
              initials: _initials(actor.displayName ?? actor.handle),
              shape: BoxShape.circle,
              placeholderTextStyle: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actor.displayName ?? actor.handle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '@${actor.handle}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  if (profileUi.alert || profileUi.inform) ...[
                    const SizedBox(height: 8),
                    ModerationBadgeRow(ui: profileUi),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}

class _FollowButton extends StatefulWidget {
  const _FollowButton({required this.actor});

  final ProfileView actor;

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.actor.viewer?.following != null;
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);
    if (_isFollowing) {
      final button = OutlinedButton(
        onPressed: isOffline ? null : _toggleFollow,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: const Text('Following'),
      );

      return isOffline ? Tooltip(message: offlineActionMessage('change your follow state'), child: button) : button;
    }

    final button = FilledButton.tonal(
      onPressed: isOffline ? null : _toggleFollow,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: const Text('Follow'),
    );

    return isOffline ? Tooltip(message: offlineActionMessage('follow this account'), child: button) : button;
  }

  void _toggleFollow() {
    setState(() => _isFollowing = !_isFollowing);
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text('Search', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Find posts and people on the network.\n'
              'Type @ to search for users.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
