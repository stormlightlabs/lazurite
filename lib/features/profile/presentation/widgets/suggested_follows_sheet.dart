import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/profile/cubit/suggested_follows_cubit.dart';

class SuggestedFollowsSheet extends StatelessWidget {
  const SuggestedFollowsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Suggested Follows',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<SuggestedFollowsCubit, SuggestedFollowsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.hasError) {
                  return Center(child: Text(state.errorMessage ?? 'Failed to load suggestions'));
                }

                if (state.isEmpty) {
                  return const Center(child: Text('No suggestions found'));
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: state.suggestions.length,
                  itemBuilder: (context, index) {
                    final profile = state.suggestions[index];
                    return _SuggestedProfileTile(profile: profile);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedProfileTile extends StatelessWidget {
  const _SuggestedProfileTile({required this.profile});

  final ProfileView profile;

  @override
  Widget build(BuildContext context) {
    final isFollowing = profile.viewer?.following != null;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: profile.avatar != null ? NetworkImage(profile.avatar!) : null,
        child: profile.avatar == null
            ? Text((profile.displayName ?? profile.handle).substring(0, 1).toUpperCase())
            : null,
      ),
      title: Text(profile.displayName ?? profile.handle),
      subtitle: Text('@${profile.handle}'),
      trailing: _FollowButton(profile: profile, isFollowing: isFollowing),
      onTap: () {
        Navigator.of(context).pop();
        context.push('/profile?actor=${Uri.encodeComponent(profile.did)}');
      },
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.profile, required this.isFollowing});

  final ProfileView profile;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    if (isFollowing) {
      return const OutlinedButton(onPressed: null, child: Text('Following'));
    }

    return const FilledButton(onPressed: null, child: Text('Follow'));
  }
}
