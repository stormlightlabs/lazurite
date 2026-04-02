import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/features/profile/cubit/suggested_follows_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';

class SuggestedFollowsList extends StatelessWidget {
  const SuggestedFollowsList({
    super.key,
    required this.actor,
    this.scrollController,
    this.onProfileTap,
    this.emptyMessage = 'No suggestions found',
    this.padding = EdgeInsets.zero,
  });

  final String actor;
  final ScrollController? scrollController;
  final ValueChanged<ProfileView>? onProfileTap;
  final String emptyMessage;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuggestedFollowsCubit, SuggestedFollowsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Failed to load suggestions', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<SuggestedFollowsCubit>().load(actor),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.isEmpty) {
          return Center(child: Text(emptyMessage));
        }

        return ListView.builder(
          controller: scrollController,
          padding: padding,
          itemCount: state.suggestions.length,
          itemBuilder: (context, index) {
            final profile = state.suggestions[index];
            return _SuggestedProfileTile(profile: profile, onTap: onProfileTap);
          },
        );
      },
    );
  }
}

class _SuggestedProfileTile extends StatelessWidget {
  const _SuggestedProfileTile({required this.profile, this.onTap});

  final ProfileView profile;
  final ValueChanged<ProfileView>? onTap;

  @override
  Widget build(BuildContext context) {
    ProfileActionRepository? profileActionRepository;
    try {
      profileActionRepository = context.read<ProfileActionRepository>();
    } catch (_) {
      profileActionRepository = null;
    }

    final child = _SuggestedProfileTileBody(profile: profile, onTap: onTap);
    if (profileActionRepository == null) {
      return _StaticSuggestedProfileTile(profile: profile, onTap: onTap);
    }

    return BlocProvider(
      create: (_) => ProfileActionCubit(
        profileActionRepository: profileActionRepository!,
        actorDid: profile.did,
        isFollowing: profile.viewer?.following != null,
        isMuted: profile.viewer?.muted ?? false,
        isBlocked: profile.viewer?.blocking != null,
        isBlockedBy: profile.viewer?.blockedBy ?? false,
        followUri: profile.viewer?.following?.toString(),
        blockUri: profile.viewer?.blocking?.toString(),
      ),
      child: child,
    );
  }
}

class _SuggestedProfileTileBody extends StatelessWidget {
  const _SuggestedProfileTileBody({required this.profile, this.onTap});

  final ProfileView profile;
  final ValueChanged<ProfileView>? onTap;

  @override
  Widget build(BuildContext context) {
    final title = profile.displayName?.isNotEmpty == true ? profile.displayName! : profile.handle;

    return BlocConsumer<ProfileActionCubit, ProfileActionState>(
      listener: (context, state) {
        if (state.error == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error!), behavior: SnackBarBehavior.floating));
        context.read<ProfileActionCubit>().clearError();
      },
      builder: (context, state) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: profile.avatar != null ? NetworkImage(profile.avatar!) : null,
            child: profile.avatar == null ? Text(title.substring(0, 1).toUpperCase()) : null,
          ),
          title: Text(title),
          subtitle: Text('@${profile.handle}'),
          trailing: _FollowButton(
            isFollowing: state.isFollowing,
            isLoading: state.isLoadingFollow,
            onPressed: state.isLoadingFollow ? null : () => context.read<ProfileActionCubit>().toggleFollow(),
          ),
          onTap: onTap == null ? null : () => onTap!(profile),
        );
      },
    );
  }
}

class _StaticSuggestedProfileTile extends StatelessWidget {
  const _StaticSuggestedProfileTile({required this.profile, this.onTap});

  final ProfileView profile;
  final ValueChanged<ProfileView>? onTap;

  @override
  Widget build(BuildContext context) {
    final title = profile.displayName?.isNotEmpty == true ? profile.displayName! : profile.handle;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: profile.avatar != null ? NetworkImage(profile.avatar!) : null,
        child: profile.avatar == null ? Text(title.substring(0, 1).toUpperCase()) : null,
      ),
      title: Text(title),
      subtitle: Text('@${profile.handle}'),
      onTap: onTap == null ? null : () => onTap!(profile),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.isFollowing, required this.isLoading, this.onPressed});

  final bool isFollowing;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (isFollowing) {
      return OutlinedButton(onPressed: onPressed, child: const Text('Following'));
    }

    return FilledButton(onPressed: onPressed, child: const Text('Follow'));
  }
}
