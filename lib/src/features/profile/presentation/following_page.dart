import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/widgets/actor_row.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/core/widgets/paged_list_footer.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';

/// Screen showing users that a profile is following.
class FollowingPage extends ConsumerStatefulWidget {
  const FollowingPage({required this.did, super.key});

  final String did;

  @override
  ConsumerState<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends ConsumerState<FollowingPage> {
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
      ref.read(followingProvider(widget.did).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final followingAsync = ref.watch(followingProvider(widget.did));

    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body: followingAsync.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          title: 'Failed to load following',
          onRetry: () => ref.invalidate(followingProvider(widget.did)),
        ),
        data: (following) {
          if (following.isEmpty) {
            return const Center(child: Text('Not following anyone yet'));
          }

          final notifier = ref.read(followingProvider(widget.did).notifier);

          return ListView.builder(
            controller: _scrollController,
            itemCount: following.length + 1,
            itemBuilder: (context, index) {
              if (index == following.length) {
                final hasMore = notifier.hasMore;
                if (!hasMore) {
                  return const PagedListFooter(state: PagedListState.end);
                }
                return const PagedListFooter(state: PagedListState.loading);
              }

              final actor = following[index];
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
