import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/presentation/message_thread_route_args.dart';
import 'package:lazurite/features/messages/presentation/widgets/convo_list_item.dart';
import 'package:lazurite/shared/presentation/widgets/animated_refresh_indicator.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';
import 'package:lazurite/shared/presentation/widgets/staggered_entrance.dart';

class ConvoListPane extends StatefulWidget {
  const ConvoListPane({super.key, required this.tab});

  final ConvoTab tab;

  @override
  State<ConvoListPane> createState() => _ConvoListPaneState();
}

class _ConvoListPaneState extends State<ConvoListPane> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _seenConvoIds = <String>{};

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
        final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);
        if (state.status == ConvoListStatus.initial ||
            (state.status == ConvoListStatus.loading && state.convos.isEmpty)) {
          if (isOffline) {
            return const _OfflineConvoState();
          }
          return const LoadingState();
        }

        if (state.status == ConvoListStatus.error && state.convos.isEmpty) {
          if (isOffline) {
            return const _OfflineConvoState();
          }
          return ErrorState(
            title: context.l10n.errorFailedToLoadMessages,
            message: state.errorMessage ?? context.l10n.errorUnknown,
            onRetry: () => context.read<ConvoListBloc>().add(const ConvosRequested()),
          );
        }

        final filtered = _filteredConvos(state.convos, widget.tab);

        if (filtered.isEmpty) {
          if (isOffline) {
            return const _OfflineConvoState();
          }
          return AnimatedRefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              controller: _scrollController,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: EmptyState(
                    message: widget.tab == ConvoTab.primary
                        ? context.l10n.messageNoConversationsYet
                        : context.l10n.messageNoMessageRequests,
                    icon: Icons.forum_outlined,
                  ),
                ),
              ],
            ),
          );
        }

        final currentUserDid = _currentUserDid(context);

        return AnimatedRefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final convo = filtered[index];
              return StaggeredEntrance(
                itemKey: convo.id,
                index: index,
                seenKeys: _seenConvoIds,
                child: ConvoListItem(
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
                ),
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
    final title = other?.displayName ?? other?.handle ?? context.l10n.labelConversation;
    context.push('/alerts/messages/${convo.id}', extra: MessageThreadRouteArgs(title: title));
  }
}

class _OfflineConvoState extends StatelessWidget {
  const _OfflineConvoState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: context.colorScheme.outline),
            const SizedBox(height: 12),
            Text(context.l10n.messageNoConnection, style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              context.l10n.messageReconnectToLoadMessages,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
