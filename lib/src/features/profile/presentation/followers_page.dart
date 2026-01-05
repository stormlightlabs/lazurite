import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/widgets/actor_row.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/core/widgets/paged_list_footer.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';

/// Screen showing a user's followers.
class FollowersPage extends ConsumerStatefulWidget {
  const FollowersPage({required this.did, super.key});

  final String did;

  @override
  ConsumerState<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends ConsumerState<FollowersPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(followersProvider(widget.did).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final followersAsync = ref.watch(followersProvider(widget.did));

    return Scaffold(
      appBar: AppBar(title: const Text('Followers')),
      body: followersAsync.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          title: 'Failed to load followers',
          onRetry: () => ref.invalidate(followersProvider(widget.did)),
        ),
        data: (followers) {
          if (followers.isEmpty) {
            return const Center(child: Text('No followers yet'));
          }

          final notifier = ref.read(followersProvider(widget.did).notifier);

          return ListView.builder(
            controller: _scrollController,
            itemCount: followers.length + 1,
            itemBuilder: (context, index) {
              if (index == followers.length) {
                final hasMore = notifier.hasMore;
                if (!hasMore) {
                  return const PagedListFooter(state: PagedListState.end);
                }
                return const PagedListFooter(state: PagedListState.loading);
              }

              final actor = followers[index];
              return ActorRow(
                did: actor.did,
                handle: actor.handle,
                displayName: actor.displayName,
                avatar: actor.avatar,
                onTap: () => context.push('/home/u/${Uri.encodeComponent(actor.did)}'),
              );
            },
          );
        },
      ),
    );
  }
}
