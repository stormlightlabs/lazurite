import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/presentation/widgets/convo_list_pane.dart';

class ConvoListScreen extends StatefulWidget {
  const ConvoListScreen({super.key});

  @override
  State<ConvoListScreen> createState() => _ConvoListScreenState();
}

class _ConvoListScreenState extends State<ConvoListScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final tab = _tabController.index == 0 ? ConvoTab.primary : ConvoTab.requests;
    context.read<ConvoListBloc>().add(ConvoTabChanged(tab: tab));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppShellMenuButton(),
        title: Text(context.l10n.labelMessages, style: context.textTheme.titleMedium),
        actions: [
          IconButton(
            tooltip: context.l10n.tooltipCreateGroup,
            icon: const Icon(Icons.group_add_outlined),
            onPressed: () => context.push('/alerts/messages/new-group'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.labelPrimary),
            Tab(text: context.l10n.labelMessageRequests),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ConvoListPane(tab: ConvoTab.primary),
          ConvoListPane(tab: ConvoTab.requests),
        ],
      ),
    );
  }
}
