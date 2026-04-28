import 'dart:async';
import 'dart:convert';

import 'package:atproto/com_atproto_repo_listrecords.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/theme/typography.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/core/widgets/app_breadcrumbs.dart';
import 'package:lazurite/features/devtools/cubit/dev_tools_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class DevToolsScreen extends StatelessWidget {
  const DevToolsScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDS Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Go to pds.ls',
            onPressed: () => _openExternalUrl('https://pds.ls'),
          ),
        ],
      ),
      body: BlocConsumer<DevToolsCubit, DevToolsState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null &&
            current.status != DevToolsStatus.error,
        listener: (context, state) {
          final message = state.errorMessage;
          if (message == null) {
            return;
          }

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
        },
        builder: (context, state) {
          return Column(
            children: [
              _SearchInput(state: state, initialQuery: initialQuery),
              if (state.status == DevToolsStatus.repoLoaded ||
                  state.status == DevToolsStatus.collectionLoaded ||
                  state.status == DevToolsStatus.recordLoaded)
                _BreadcrumbBar(state: state),
              Expanded(child: _Content(state: state)),
            ],
          );
        },
      ),
    );
  }
}

class _SearchInput extends StatefulWidget {
  const _SearchInput({required this.state, this.initialQuery});

  final DevToolsState state;
  final String? initialQuery;

  @override
  State<_SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<_SearchInput> {
  late final TextEditingController _controller;
  bool _resolvedInitialQuery = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    final initialQuery = widget.initialQuery?.trim();
    if (initialQuery != null && initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _resolvedInitialQuery) {
          return;
        }
        _resolvedInitialQuery = true;
        _resolve(initialQuery);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowTypeahead =
        _controller.text.trim().startsWith('@') &&
        (widget.state.isTypeaheadLoading || widget.state.typeaheadActors.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Handle, DID, or at:// URI',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    isDense: true,
                  ),
                  style: AppTypography.googleSansCode(fontSize: 13),
                  onChanged: _onQueryChanged,
                  onSubmitted: _resolve,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: widget.state.isLoading ? null : () => _resolve(_controller.text),
                child: const Text('Resolve'),
              ),
            ],
          ),
          if (shouldShowTypeahead) ...[
            const SizedBox(height: 8),
            _TypeaheadResults(
              actors: widget.state.typeaheadActors,
              isLoading: widget.state.isTypeaheadLoading,
              onSelected: _resolveHandleSuggestion,
            ),
          ],
        ],
      ),
    );
  }

  void _resolve(String value) {
    final query = _normalizeHandleQuery(value);
    if (query.isEmpty) {
      return;
    }

    final cubit = context.read<DevToolsCubit>();
    cubit.clearTypeahead();
    cubit.resolve(query);
  }

  void _resolveHandleSuggestion(ProfileViewBasic actor) {
    final suggestion = '@${actor.handle}';
    _controller
      ..text = suggestion
      ..selection = TextSelection.collapsed(offset: suggestion.length);
    _resolve(suggestion);
  }

  void _onQueryChanged(String value) {
    setState(() {});

    final cubit = context.read<DevToolsCubit>();
    final query = value.trim();
    if (!query.startsWith('@')) {
      cubit.clearTypeahead();
      return;
    }

    unawaited(cubit.queryTypeahead(query));
  }

  String _normalizeHandleQuery(String value) {
    final query = value.trim();
    if (query.startsWith('@') && !query.startsWith('at://')) {
      return query.replaceFirst(RegExp(r'^@+'), '');
    }
    return query;
  }
}

class _TypeaheadResults extends StatelessWidget {
  const _TypeaheadResults({required this.actors, required this.isLoading, required this.onSelected});

  final List<ProfileViewBasic> actors;
  final bool isLoading;
  final ValueChanged<ProfileViewBasic> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listHeight = (actors.length * 56.0).clamp(56.0, 220.0);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) const LinearProgressIndicator(minHeight: 2),
          if (actors.isNotEmpty)
            SizedBox(
              height: listHeight,
              child: ListView.separated(
                itemCount: actors.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: theme.dividerColor),
                itemBuilder: (context, index) {
                  final actor = actors[index];
                  return ListTile(
                    dense: true,
                    title: Text(actor.displayName ?? actor.handle),
                    subtitle: Text('@${actor.handle}'),
                    onTap: () => onSelected(actor),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _BreadcrumbBar extends StatelessWidget {
  const _BreadcrumbBar({required this.state});

  final DevToolsState state;

  @override
  Widget build(BuildContext context) {
    return AppBreadcrumbs(items: _items(context), isLoading: state.isNavigating);
  }

  List<AppBreadcrumbItem> _items(BuildContext context) {
    final cubit = context.read<DevToolsCubit>();
    final repoLabel = state.repoHandle ?? state.handle ?? state.did ?? 'Repository';
    final items = <AppBreadcrumbItem>[
      AppBreadcrumbItem(
        label: repoLabel,
        tooltip: state.did == null ? repoLabel : '$repoLabel\n${state.did}',
        key: const ValueKey('dev-tools-breadcrumb-repo'),
        onTap: state.status == DevToolsStatus.repoLoaded ? null : cubit.goBackToRepo,
      ),
    ];

    if (state.selectedCollection != null) {
      items.add(
        AppBreadcrumbItem(
          label: state.selectedCollection!,
          key: const ValueKey('dev-tools-breadcrumb-collection'),
          onTap: state.status == DevToolsStatus.collectionLoaded ? null : cubit.goBackToCollection,
        ),
      );
    }

    if (state.selectedRecord != null) {
      items.add(
        AppBreadcrumbItem(
          label: state.selectedRecord!.rkey.isEmpty ? 'Record JSON' : state.selectedRecord!.rkey,
          tooltip: state.selectedRecord!.uri,
          key: const ValueKey('dev-tools-breadcrumb-record'),
        ),
      );
    }

    return items;
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final DevToolsState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.status == DevToolsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == DevToolsStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: context.colorScheme.error),
              const SizedBox(height: 16),
              Text('Error', style: context.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == DevToolsStatus.recordLoaded && state.selectedRecord != null) {
      return _RecordInspector(record: state.selectedRecord!);
    }

    if (state.status == DevToolsStatus.collectionLoaded && state.selectedCollection != null) {
      return _RecordsList(state: state);
    }

    if (state.status == DevToolsStatus.repoLoaded && state.did != null) {
      return _RepoOverview(state: state);
    }

    return const _EmptyState();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_outlined, size: 64, color: context.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('PDS Explorer', style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Enter a handle, DID, or AT-URI to explore\n'
                    'a user\'s repository.',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.outline),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => _openExternalUrl('https://pds.ls'),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Inspired by pds.ls'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RepoOverview extends StatelessWidget {
  const _RepoOverview({required this.state});

  final DevToolsState state;

  @override
  Widget build(BuildContext context) {
    final totalRepoRecords = state.totalRepoRecords;
    final theme = Theme.of(context);
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(_initialFor(state.repoHandle ?? state.handle))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.repoHandle ?? state.handle ?? 'Unknown', style: context.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          state.did ?? '',
                          style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text(
                    '${state.collections.length} collections',
                    style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  Text(
                    totalRepoRecords == null
                        ? (state.isCollectionCountsLoading ? 'Counting records...' : 'Record counts unavailable')
                        : '$totalRepoRecords records',
                    style: context.textTheme.bodySmall!.copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'COLLECTIONS',
            style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
        ...state.collections.map((collection) => _CollectionItem(collection: collection)),
      ],
    );
  }
}

class _CollectionItem extends StatelessWidget {
  const _CollectionItem({required this.collection});

  final CollectionSummary collection;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: context.colorScheme.surfaceContainerHighest,
        ),
        child: Icon(_getCollectionIcon(collection.name), size: 16, color: context.colorScheme.primary),
      ),
      title: Text(collection.name, style: AppTypography.googleSansCode(fontSize: 13)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              collection.countLabel,
              style: context.textTheme.labelSmall!.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => context.read<DevToolsCubit>().loadCollection(collection.name),
    );
  }

  /// NOTE: repost must come before post
  IconData _getCollectionIcon(String collection) {
    if (collection.contains('repost')) return Icons.repeat;
    if (collection.contains('post')) return Icons.chat_bubble_outline;
    if (collection.contains('like')) return Icons.favorite_outline;
    if (collection.contains('follow')) return Icons.person_add_outlined;
    if (collection.contains('profile')) return Icons.person_outline;
    if (collection.contains('generator')) return Icons.auto_awesome_outlined;
    if (collection.contains('list')) return Icons.list_outlined;
    if (collection.contains('block')) return Icons.block;
    return Icons.folder_outlined;
  }
}

class _RecordsList extends StatefulWidget {
  const _RecordsList({required this.state});

  final DevToolsState state;

  @override
  State<_RecordsList> createState() => _RecordsListState();
}

class _RecordsListState extends State<_RecordsList> {
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
      if (widget.state.hasMoreRecords && !widget.state.isLoading) {
        context.read<DevToolsCubit>().loadMoreRecords();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = widget.state.records ?? [];
    final selectedCollection = _collectionSummary(widget.state, widget.state.selectedCollection);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.state.selectedCollection ?? '',
                  style: AppTypography.googleSansCode(
                    fontSize: context.textTheme.titleSmall?.fontSize ?? 14,
                    fontWeight: context.textTheme.titleSmall?.fontWeight ?? FontWeight.w500,
                    letterSpacing: context.textTheme.titleSmall?.letterSpacing,
                    height: context.textTheme.titleSmall?.height,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
              Text(
                selectedCollection?.recordCount == null
                    ? '${records.length} loaded'
                    : '${records.length} of ${selectedCollection!.recordCount}',
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: records.length + (widget.state.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == records.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                );
              }

              final record = records[index];
              return _RecordItem(record: record);
            },
          ),
        ),
      ],
    );
  }
}

class _RecordItem extends StatelessWidget {
  const _RecordItem({required this.record});

  final RepoListRecordsRecord record;

  @override
  Widget build(BuildContext context) {
    final rkey = record.uri.rkey;
    final preview = _getRecordPreview(record.value);

    return ListTile(
      title: Text(rkey, style: AppTypography.googleSansCode(fontSize: 13)),
      subtitle: preview != null ? Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.read<DevToolsCubit>().loadRecord(record),
    );
  }

  String? _getRecordPreview(Map<String, dynamic> value) {
    final text = value['text'];
    if (text is String && text.isNotEmpty) {
      return text.length > 50 ? '${text.substring(0, 50)}...' : text;
    }

    final displayName = value['displayName'];
    if (displayName is String && displayName.isNotEmpty) {
      return displayName;
    }

    return null;
  }
}

class _RecordInspector extends StatelessWidget {
  const _RecordInspector({required this.record});

  final RecordInfo record;

  @override
  Widget build(BuildContext context) {
    final jsonString = _formatJson(record.value);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.rkey,
                style: context.textTheme.titleSmall?.copyWith(color: context.colorScheme.primary),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                record.uri,
                style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.tertiary),
                overflow: TextOverflow.ellipsis,
              ),
              if (record.cid != null) ...[
                const SizedBox(height: 2),
                Text(
                  'CID: ${record.cid!}',
                  style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.secondary),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: jsonString));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('JSON copied to clipboard'), behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('aturi.to'),
                    onPressed: () => _openExternalUrl(record.atUriToLink),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _JsonViewer(json: record.value),
          ),
        ),
      ],
    );
  }
}

class _JsonViewer extends StatelessWidget {
  const _JsonViewer({required this.json});

  final Object? json;

  @override
  Widget build(BuildContext context) {
    return SelectableText(_formatJson(json), style: AppTypography.googleSansCode(fontSize: 12, height: 1.8));
  }
}

const JsonEncoder _jsonFormatter = JsonEncoder.withIndent('  ');

String _formatJson(Object? value) {
  try {
    return _jsonFormatter.convert(value);
  } catch (_) {
    return value?.toString() ?? 'null';
  }
}

CollectionSummary? _collectionSummary(DevToolsState state, String? collectionName) {
  if (collectionName == null) {
    return null;
  }

  for (final collection in state.collections) {
    if (collection.name == collectionName) {
      return collection;
    }
  }

  return null;
}

String _initialFor(String? value) {
  if (value == null || value.isEmpty) {
    return '?';
  }

  return value.substring(0, 1).toUpperCase();
}

Future<void> _openExternalUrl(String value) async {
  final uri = Uri.parse(value);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
