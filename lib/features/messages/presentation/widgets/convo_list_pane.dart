import 'package:bluesky/chat_bsky_convo_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/presentation/message_thread_route_args.dart';
import 'package:lazurite/features/messages/presentation/widgets/convo_list_item.dart';

class ConvoListPane extends StatefulWidget {
  const ConvoListPane({super.key, required this.tab});

  final ConvoTab tab;

  @override
  State<ConvoListPane> createState() => _ConvoListPaneState();
}

class _ConvoListPaneState extends State<ConvoListPane> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _syncTab();
    if (context.read<ConvoListBloc>().state.status == ConvoListStatus.initial) {
      context.read<ConvoListBloc>().add(const ConvosRequested());
    }
  }

  @override
  void didUpdateWidget(covariant ConvoListPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) {
      _syncTab();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _syncTab() {
    if (context.read<ConvoListBloc>().state.activeTab != widget.tab) {
      context.read<ConvoListBloc>().add(ConvoTabChanged(tab: widget.tab));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      log.d('Pagination not yet implemented');
    }
  }

  Future<void> _onRefresh() async => context.read<ConvoListBloc>().add(const ConvosRefreshed());

  String _currentUserDid(BuildContext context) {
    try {
      return context.read<String>();
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConvoListBloc, ConvoListState>(
      builder: (context, state) {
        if (state.status == ConvoListStatus.initial ||
            (state.status == ConvoListStatus.loading && state.convos.isEmpty)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ConvoListStatus.error && state.convos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Failed to load messages', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(state.errorMessage ?? 'Unknown error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.read<ConvoListBloc>().add(const ConvosRequested()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final filtered = _filteredConvos(state.convos, widget.tab);

        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              controller: _scrollController,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Text(
                      widget.tab == ConvoTab.primary ? 'No conversations yet' : 'No message requests',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final currentUserDid = _currentUserDid(context);

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final convo = filtered[index];
              return ConvoListItem(
                convo: convo,
                currentUserDid: currentUserDid,
                onTap: () => _openThread(context, convo, currentUserDid),
                onMuteTap: () {
                  if (convo.muted) {
                    context.read<ConvoListBloc>().add(ConvoUnmuted(convoId: convo.id));
                  } else {
                    context.read<ConvoListBloc>().add(ConvoMuted(convoId: convo.id));
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  List<ConvoView> _filteredConvos(List<ConvoView> convos, ConvoTab tab) => convos.where((c) {
    final isRequest = c.status?.when(knownValue: (data) => data.value == 'request', unknown: (_) => false) ?? false;
    return tab == ConvoTab.requests ? isRequest : !isRequest;
  }).toList();

  void _openThread(BuildContext context, ConvoView convo, String currentUserDid) {
    final other = convo.members.where((m) => m.did != currentUserDid).firstOrNull;
    final title = other?.displayName ?? other?.handle ?? 'Conversation';
    context.push('/alerts/messages/${convo.id}', extra: MessageThreadRouteArgs(title: title));
  }
}
