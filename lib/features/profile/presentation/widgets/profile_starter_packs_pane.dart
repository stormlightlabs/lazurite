import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/features/starter_packs/cubit/actor_starter_packs_cubit.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/features/starter_packs/presentation/widgets/starter_pack_card.dart';

/// Pane that loads and displays starter packs for a given [actor] within the profile screen.
class ProfileStarterPacksPane extends StatefulWidget {
  const ProfileStarterPacksPane({super.key, required this.actor, required this.starterPackRepository});

  final String actor;
  final StarterPackRepository starterPackRepository;

  @override
  State<ProfileStarterPacksPane> createState() => _ProfileStarterPacksPaneState();
}

class _ProfileStarterPacksPaneState extends State<ProfileStarterPacksPane> {
  late final ActorStarterPacksCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ActorStarterPacksCubit(starterPackRepository: widget.starterPackRepository)..load(actor: widget.actor);
  }

  @override
  void didUpdateWidget(ProfileStarterPacksPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actor != widget.actor) {
      _cubit.load(actor: widget.actor);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActorStarterPacksCubit, ActorStarterPacksState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state.status == ActorStarterPacksStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ActorStarterPacksStatus.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage ?? context.l10n.errorFailedToLoadStarterPacks),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _cubit.load(actor: widget.actor),
                  child: Text(context.l10n.buttonRetry),
                ),
              ],
            ),
          );
        }

        if (state.starterPacks.isEmpty) {
          return Center(child: Text(context.l10n.messageNoStarterPacksYet));
        }

        return RefreshIndicator(
          onRefresh: _cubit.refresh,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.starterPacks.length,
            itemBuilder: (context, index) => StarterPackCard(
              key: ValueKey(state.starterPacks[index].uri),
              pack: state.starterPacks[index],
              onTap: () {
                final component = Uri.encodeComponent(state.starterPacks[index].uri.toString());
                final uri = '/starter-pack?uri=$component';
                context.push(uri);
              },
            ),
          ),
        );
      },
    );
  }
}
