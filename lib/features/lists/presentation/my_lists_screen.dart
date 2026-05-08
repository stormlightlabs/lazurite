import 'package:bluesky/app_bsky_graph_defs.dart' as bsky_graph;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/lists/cubit/my_lists_cubit.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/widgets/create_edit_list_dialog.dart';
import 'package:lazurite/features/lists/presentation/widgets/list_row_tile.dart';
import 'package:lazurite/shared/presentation/widgets/animated_refresh_indicator.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';
import 'package:lazurite/shared/presentation/widgets/staggered_entrance.dart';

class MyListsScreen extends StatelessWidget {
  const MyListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actor = context.read<AuthBloc>().state.tokens?.did ?? '';
    return BlocProvider(
      create: (context) => MyListsCubit(listRepository: context.read<ListRepository>())..load(actor: actor),
      child: const _MyListsView(),
    );
  }
}

class _MyListsView extends StatefulWidget {
  const _MyListsView();

  @override
  State<_MyListsView> createState() => _MyListsViewState();
}

class _MyListsViewState extends State<_MyListsView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<String> _seenListUris = <String>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final result = await showDialog<CreateEditListResult>(
      context: context,
      builder: (_) => const CreateEditListDialog(),
    );

    if (result == null || !context.mounted) return;

    final authState = context.read<AuthBloc>().state;
    final userDid = authState.tokens?.did;
    if (userDid == null) return;

    final listUri = await context.read<MyListsCubit>().createList(
      userDid: userDid,
      name: result.name,
      purpose: result.purpose,
      description: result.description,
      avatarBytes: result.avatarBytes,
      avatarMimeType: result.avatarMimeType,
    );

    if (listUri != null && context.mounted) {
      await context.push('/list?uri=${Uri.encodeComponent(listUri.toString())}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.labelMyLists),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.labelFeeds.toUpperCase()),
            Tab(text: context.l10n.labelModeration.toUpperCase()),
          ],
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.2),
          unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.2),
          indicatorWeight: 2,
        ),
      ),
      body: BlocBuilder<MyListsCubit, MyListsState>(
        builder: (context, state) {
          if (state.status == MyListsStatus.loading) {
            return const LoadingState();
          }

          if (state.status == MyListsStatus.error) {
            return ErrorState(
              title: context.l10n.errorFailedToLoadLists,
              message: state.errorMessage ?? context.l10n.errorUnknown,
              onRetry: () => context.read<MyListsCubit>().refresh(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [_buildListTab(context, state.curationLists), _buildListTab(context, state.moderationLists)],
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton(
            heroTag: 'my-lists-fab',
            onPressed: () => _showCreateDialog(context),
            child: const Icon(Icons.add),
          ).animateIfAllowed(
            context,
            effects: const [
              FadeEffect(duration: Anim.feedItem, curve: Anim.enter),
              ScaleEffect(begin: Offset(0, 0), end: Offset(1, 1), duration: Anim.feedItem, curve: Anim.emphasis),
            ],
          ),
    );
  }

  Widget _buildListTab(BuildContext context, List<bsky_graph.ListView> lists) {
    if (lists.isEmpty) {
      return EmptyState(message: context.l10n.messageNoListsYet, icon: Icons.list_alt_outlined);
    }

    return AnimatedRefreshIndicator(
      onRefresh: () => context.read<MyListsCubit>().refresh(),
      child: ListView.builder(
        itemCount: lists.length,
        itemBuilder: (context, index) {
          final list = lists[index];
          return StaggeredEntrance(
            itemKey: list.uri.toString(),
            index: index,
            seenKeys: _seenListUris,
            child: ListRowTile(
              key: ValueKey(list.uri),
              list: list,
              onTap: () => context.push('/list?uri=${Uri.encodeComponent(list.uri.toString())}'),
            ),
          );
        },
      ),
    );
  }
}
