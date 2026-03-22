import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/starter_packs/cubit/actor_starter_packs_cubit.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/features/starter_packs/presentation/widgets/starter_pack_card.dart';

class ActorStarterPacksScreen extends StatelessWidget {
  const ActorStarterPacksScreen({super.key, required this.actor});

  final String actor;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ActorStarterPacksCubit(starterPackRepository: context.read<StarterPackRepository>())..load(actor: actor),
      child: _ActorStarterPacksView(actor: actor),
    );
  }
}

class _ActorStarterPacksView extends StatelessWidget {
  const _ActorStarterPacksView({required this.actor});

  final String actor;

  @override
  Widget build(BuildContext context) {
    String? currentUserDid;
    try {
      currentUserDid = context.read<String>();
    } catch (_) {}
    final isOwnProfile = currentUserDid != null && currentUserDid == actor;

    return Scaffold(
      appBar: AppBar(title: const Text('Starter Packs')),
      floatingActionButton: isOwnProfile
          ? FloatingActionButton(
              onPressed: () => context.push('/create-starter-pack'),
              tooltip: 'Create starter pack',
              child: const Icon(Icons.add),
            )
          : null,
      body: BlocBuilder<ActorStarterPacksCubit, ActorStarterPacksState>(
        builder: (context, state) {
          if (state.status == ActorStarterPacksStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ActorStarterPacksStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Failed to load starter packs'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<ActorStarterPacksCubit>().load(actor: actor),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.starterPacks.isEmpty) {
            return const Center(child: Text('No starter packs yet'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ActorStarterPacksCubit>().refresh(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels > notification.metrics.maxScrollExtent - 300 &&
                    state.hasMore &&
                    !state.isLoadingMore) {
                  context.read<ActorStarterPacksCubit>().loadMore();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.starterPacks.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.starterPacks.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final pack = state.starterPacks[index];
                  return StarterPackCard(
                    key: ValueKey(pack.uri),
                    pack: pack,
                    onTap: () => context.push('/starter-pack?uri=${Uri.encodeComponent(pack.uri.toString())}'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
