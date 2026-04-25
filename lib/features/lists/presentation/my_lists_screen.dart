import 'package:bluesky/app_bsky_graph_defs.dart' as bsky_graph;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/lists/cubit/my_lists_cubit.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/widgets/create_edit_list_dialog.dart';
import 'package:lazurite/features/lists/presentation/widgets/list_row_tile.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';

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
        title: const Text('My Lists'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'FEEDS'),
            Tab(text: 'MODERATION'),
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
              title: 'Failed to load lists',
              message: state.errorMessage ?? 'Unknown error',
              onRetry: () => context.read<MyListsCubit>().refresh(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [_buildListTab(context, state.curationLists), _buildListTab(context, state.moderationLists)],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'my-lists-fab',
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListTab(BuildContext context, List<bsky_graph.ListView> lists) {
    if (lists.isEmpty) {
      return const EmptyState(message: 'No lists yet', icon: Icons.list_alt_outlined);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MyListsCubit>().refresh(),
      child: ListView.builder(
        itemCount: lists.length,
        itemBuilder: (context, index) => ListRowTile(
          key: ValueKey(lists[index].uri),
          list: lists[index],
          onTap: () => context.push('/list?uri=${Uri.encodeComponent(lists[index].uri.toString())}'),
        ),
      ),
    );
  }
}
