import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/theme/spacing.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/features/profile/cubit/profile_connections_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

class ProfileConnectionsScreen extends StatefulWidget {
  const ProfileConnectionsScreen({
    super.key,
    required this.actor,
    this.handle,
    this.initialTab = ProfileConnectionsTab.following,
  });

  final String actor;
  final String? handle;
  final ProfileConnectionsTab initialTab;

  @override
  State<ProfileConnectionsScreen> createState() => _ProfileConnectionsScreenState();
}

class _ProfileConnectionsScreenState extends State<ProfileConnectionsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ProfileConnectionsTab.values.length,
      initialIndex: ProfileConnectionsTab.values.indexOf(widget.initialTab),
      vsync: this,
    )..addListener(_loadSelectedTab);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSelectedTab());
  }

  @override
  void dispose() {
    _tabController.removeListener(_loadSelectedTab);
    _tabController.dispose();
    super.dispose();
  }

  void _loadSelectedTab() {
    if (!mounted || _tabController.indexIsChanging) {
      return;
    }
    final tab = ProfileConnectionsTab.values[_tabController.index];
    final cubit = context.read<ProfileConnectionsCubit>();
    cubit.loadTab(tab);
    cubit.ensureSearchForTab(tab);
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.handle?.trim();
    return Scaffold(
      appBar: AppBar(
        title: Text(subtitle == null || subtitle.isEmpty ? context.l10n.labelConnections : '@$subtitle'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            final tab = ProfileConnectionsTab.values[index];
            final cubit = context.read<ProfileConnectionsCubit>();
            cubit.loadTab(tab);
            cubit.ensureSearchForTab(tab);
          },
          tabs: [
            Tab(text: context.l10n.labelFollowing),
            Tab(text: context.l10n.labelFollowers),
            Tab(text: context.l10n.labelMutuals),
          ],
        ),
      ),
      body: Column(
        children: [
          _ConnectionsSearchField(activeTab: () => ProfileConnectionsTab.values[_tabController.index]),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ConnectionsTabView(tab: ProfileConnectionsTab.following),
                _ConnectionsTabView(tab: ProfileConnectionsTab.followers),
                _ConnectionsTabView(tab: ProfileConnectionsTab.mutuals),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionsSearchField extends StatefulWidget {
  const _ConnectionsSearchField({required this.activeTab});

  final ValueGetter<ProfileConnectionsTab> activeTab;

  @override
  State<_ConnectionsSearchField> createState() => _ConnectionsSearchFieldState();
}

class _ConnectionsSearchFieldState extends State<_ConnectionsSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        key: const ValueKey('profile_connections_search_field'),
        controller: _controller,
        onChanged: (query) => context.read<ProfileConnectionsCubit>().setSearchQuery(query, widget.activeTab()),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: context.l10n.messageSearchConnectionsPlaceholder,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: BlocBuilder<ProfileConnectionsCubit, ProfileConnectionsState>(
            buildWhen: (previous, current) => previous.searchQuery != current.searchQuery,
            builder: (context, state) {
              if (state.searchQuery.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: context.l10n.tooltipClearSearch,
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  context.read<ProfileConnectionsCubit>().setSearchQuery('', widget.activeTab());
                  FocusScope.of(context).unfocus();
                },
              );
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _ConnectionsTabView extends StatelessWidget {
  const _ConnectionsTabView({required this.tab});

  final ProfileConnectionsTab tab;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileConnectionsCubit, ProfileConnectionsState>(
      buildWhen: (previous, current) =>
          previous.searchQuery != current.searchQuery || previous.dataFor(tab) != current.dataFor(tab),
      builder: (context, state) {
        final data = state.dataFor(tab);
        if (data.isLoading && data.profiles.isEmpty) {
          return LoadingState(
            message: context.l10n.formatConnectionsLoading(_localizedTabTitle(context, tab, lowercase: true)),
          );
        }

        if (data.hasError && data.profiles.isEmpty) {
          return ErrorState(
            title: context.l10n.errorUnableToLoadConnections(_localizedTabTitle(context, tab, lowercase: true)),
            message: data.errorMessage ?? context.l10n.errorUnknown,
            onRetry: () => context.read<ProfileConnectionsCubit>().loadTab(tab, force: true),
          );
        }

        final profiles = state.visibleProfilesFor(tab);
        final isSearchMode = state.searchQuery.isNotEmpty;
        if (profiles.isEmpty) {
          if (isSearchMode && data.isSearching) {
            return LoadingState(message: context.l10n.formatConnectionsSearching(data.searchedCount));
          }

          final message = state.searchQuery.isEmpty
              ? context.l10n.formatConnectionsNoneFound(_localizedTabTitle(context, tab, lowercase: true))
              : context.l10n.formatConnectionsNoMatches(
                  _localizedTabTitle(context, tab, lowercase: true),
                  state.searchQuery,
                );
          return EmptyState(message: message, icon: Icons.person_search_outlined);
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ProfileConnectionsCubit>().refreshTab(tab),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
            itemCount: profiles.length + (isSearchMode || data.hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index >= profiles.length) {
                if (isSearchMode) {
                  return _SearchProgressFooter(data: data);
                }
                return _LoadMoreFooter(tab: tab, data: data);
              }
              return _ConnectionProfileTile(profile: profiles[index]);
            },
          ),
        );
      },
    );
  }
}

class _ConnectionProfileTile extends StatelessWidget {
  const _ConnectionProfileTile({required this.profile});

  final ProfileView profile;

  @override
  Widget build(BuildContext context) {
    final repository = _readActionRepository(context);
    final currentUserDid = _readCurrentUserDid(context);
    if (repository == null || profile.did == currentUserDid) {
      return _ConnectionProfileTileBody(
        profile: profile,
        trailing: profile.did == currentUserDid ? const _YouPill() : null,
      );
    }

    return BlocProvider(
      create: (_) => ProfileActionCubit(
        profileActionRepository: repository,
        actorDid: profile.did,
        isFollowing: profile.viewer?.following != null,
        isMuted: profile.viewer?.muted ?? false,
        isBlocked: profile.viewer?.blocking != null,
        isBlockedBy: profile.viewer?.blockedBy ?? false,
        followUri: profile.viewer?.following?.toString(),
        blockUri: profile.viewer?.blocking?.toString(),
      ),
      child: BlocConsumer<ProfileActionCubit, ProfileActionState>(
        listener: (context, state) {
          if (state.error == null) {
            return;
          }
          showAppSnackBar(context, state.error!, behavior: SnackBarBehavior.floating);
          context.read<ProfileActionCubit>().clearError();
        },
        builder: (context, state) {
          return _ConnectionProfileTileBody(
            profile: profile,
            trailing: _InlineFollowButton(
              isFollowing: state.isFollowing,
              isLoading: state.isLoadingFollow,
              isBlockedBy: state.isBlockedBy,
              onPressed: () => context.read<ProfileActionCubit>().toggleFollow(),
            ),
          );
        },
      ),
    );
  }

  ProfileActionRepository? _readActionRepository(BuildContext context) {
    try {
      return context.read<ProfileActionRepository>();
    } catch (error, stackTrace) {
      log.d('ProfileConnectionsScreen: ProfileActionRepository unavailable', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  String? _readCurrentUserDid(BuildContext context) {
    try {
      return context.read<String>();
    } catch (error, stackTrace) {
      log.d('ProfileConnectionsScreen: current user DID unavailable', error: error, stackTrace: stackTrace);
      return null;
    }
  }
}

class _ConnectionProfileTileBody extends StatelessWidget {
  const _ConnectionProfileTileBody({required this.profile, this.trailing});

  final ProfileView profile;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final title = profile.displayName?.trim().isNotEmpty == true ? profile.displayName!.trim() : profile.handle;
    final description = profile.description?.trim();
    final joined = profile.createdAt == null
        ? null
        : context.l10n.formatJoinedRelative(_formatJoinedAgo(profile.createdAt!));
    final metaStyle = context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant);

    return Material(
      color: context.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => navigateToProfile(context, profile.did),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileAvatar(size: 44, imageUrl: profile.avatar, fallbackText: title),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text('@${profile.handle}', maxLines: 1, overflow: TextOverflow.ellipsis, style: metaStyle),
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                    if (joined != null) ...[const SizedBox(height: 8), Text(joined, style: metaStyle)],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: AppSpacing.sm), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineFollowButton extends StatelessWidget {
  const _InlineFollowButton({
    required this.isFollowing,
    required this.isLoading,
    required this.isBlockedBy,
    required this.onPressed,
  });

  final bool isFollowing;
  final bool isLoading;
  final bool isBlockedBy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);
    if (isLoading) {
      return const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2));
    }

    final effectiveOnPressed = isOffline || isBlockedBy ? null : onPressed;
    final button = isFollowing
        ? OutlinedButton(onPressed: effectiveOnPressed, child: Text(context.l10n.buttonFollowing))
        : FilledButton.tonal(onPressed: effectiveOnPressed, child: Text(context.l10n.buttonFollow));

    if (!isOffline) {
      return button;
    }
    return Tooltip(message: context.l10n.formatOfflineReconnectAction('change your follow state'), child: button);
  }
}

class _YouPill extends StatelessWidget {
  const _YouPill();

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: context.colorScheme.outlineVariant),
      label: Text(context.l10n.labelYou),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.tab, required this.data});

  final ProfileConnectionsTab tab;
  final ProfileConnectionsTabData data;

  @override
  Widget build(BuildContext context) {
    final errorMessage = data.loadMoreErrorMessage;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: data.isLoadingMore
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.error),
                      ),
                    ),
                  ],
                  OutlinedButton(
                    onPressed: () => context.read<ProfileConnectionsCubit>().loadMore(tab),
                    child: Text(errorMessage == null ? context.l10n.buttonLoadMore : context.l10n.buttonRetry),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SearchProgressFooter extends StatelessWidget {
  const _SearchProgressFooter({required this.data});

  final ProfileConnectionsTabData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final message = switch (data.searchStatus) {
      ProfileConnectionsSearchStatus.searching => context.l10n.formatConnectionsSearching(data.searchedCount),
      ProfileConnectionsSearchStatus.complete => context.l10n.formatConnectionsSearched(data.searchedCount),
      ProfileConnectionsSearchStatus.error => context.l10n.formatConnectionsSearchStopped(data.searchedCount),
      ProfileConnectionsSearchStatus.idle => '',
    };

    if (message.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (data.searchStatus == ProfileConnectionsSearchStatus.searching) ...[
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              data.searchErrorMessage ?? message,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatJoinedAgo(DateTime joinedAt) {
  final now = DateTime.now();
  var difference = now.difference(joinedAt);
  if (difference.isNegative) {
    difference = Duration.zero;
  }

  if (difference.inDays >= 365) {
    return '${difference.inDays ~/ 365}y ago';
  }
  if (difference.inDays >= 30) {
    return '${difference.inDays ~/ 30}mo ago';
  }
  if (difference.inDays >= 7) {
    return '${difference.inDays ~/ 7}w ago';
  }
  if (difference.inDays >= 1) {
    return '${difference.inDays}d ago';
  }
  if (difference.inHours >= 1) {
    return '${difference.inHours}h ago';
  }
  if (difference.inMinutes >= 1) {
    return '${difference.inMinutes}m ago';
  }
  return 'now';
}

String _localizedTabTitle(BuildContext context, ProfileConnectionsTab tab, {bool lowercase = false}) {
  final title = switch (tab) {
    ProfileConnectionsTab.following => context.l10n.labelFollowing,
    ProfileConnectionsTab.followers => context.l10n.labelFollowers,
    ProfileConnectionsTab.mutuals => context.l10n.labelMutuals,
  };
  return lowercase ? title.toLowerCase() : title;
}
