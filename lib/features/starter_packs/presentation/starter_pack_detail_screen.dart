import 'package:poptart_core/poptart_core.dart' show AtUri;
import 'package:bluesky_poptart/app/bsky/feed/defs.dart' show GeneratorView;
import 'package:bluesky_poptart/app/bsky/graph/defs.dart' as bsky_graph;
import 'package:flutter/material.dart' hide ListView;
import 'package:flutter/material.dart' as material show ListView;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/starter_packs/bloc/starter_pack_bloc.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

class StarterPackDetailScreen extends StatelessWidget {
  const StarterPackDetailScreen({super.key, required this.packUri});

  final AtUri packUri;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StarterPackBloc(starterPackRepository: context.read<StarterPackRepository>())
            ..add(StarterPackRequested(starterPackUri: packUri)),
      child: const _StarterPackDetailView(),
    );
  }
}

class _StarterPackDetailView extends StatelessWidget {
  const _StarterPackDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StarterPackBloc, StarterPackState>(
      listenWhen: (prev, curr) =>
          (prev.followedCount == null && curr.followedCount != null) ||
          (prev.errorMessage != curr.errorMessage && curr.errorMessage != null && !curr.isLoading) ||
          curr.status == StarterPackStatus.deleted,
      listener: (context, state) {
        if (state.status == StarterPackStatus.deleted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/profile/me');
          }
          return;
        }

        if (state.followedCount != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.formatFollowedMemberCount(state.followedCount!)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!), behavior: SnackBarBehavior.floating));
        }
      },
      builder: (context, state) {
        final pack = state.starterPack;
        String? currentUserDid;
        try {
          currentUserDid = context.read<String>();
        } catch (_) {}
        final isCreator = currentUserDid != null && pack?.creator.did == currentUserDid;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: true,
                title: Text(
                  pack != null
                      ? ((pack.record['name'] as String?) ?? context.l10n.labelStarterPack)
                      : context.l10n.labelStarterPack,
                ),
                actions: [
                  if (state.isMutating)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else if (isCreator && pack != null)
                    PopupMenuButton<_PackAction>(
                      onSelected: (action) => _handleAction(context, action, state, pack),
                      itemBuilder: (_) => [
                        PopupMenuItem(value: _PackAction.edit, child: Text(context.l10n.buttonEdit)),
                        PopupMenuItem(value: _PackAction.delete, child: Text(context.l10n.buttonDelete)),
                      ],
                    ),
                ],
              ),
              if (state.isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (state.status == StarterPackStatus.error && pack == null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.errorMessage ?? context.l10n.errorFailedToLoadStarterPack),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => context.read<StarterPackBloc>().add(
                              StarterPackRequested(starterPackUri: state.packUri!),
                            ),
                            child: Text(context.l10n.buttonRetry),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (pack != null)
                SliverToBoxAdapter(
                  child: _StarterPackContent(pack: pack, state: state),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleAction(
    BuildContext context,
    _PackAction action,
    StarterPackState state,
    bsky_graph.StarterPackView pack,
  ) {
    switch (action) {
      case _PackAction.edit:
        _showEditDialog(context, pack);
      case _PackAction.delete:
        _showDeleteConfirmation(context);
    }
  }

  Future<void> _showEditDialog(BuildContext context, bsky_graph.StarterPackView pack) async {
    final bloc = context.read<StarterPackBloc>();
    final currentFeeds = pack.feeds ?? const [];
    await showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _EditStarterPackDialog(
          initialName: (pack.record['name'] as String?) ?? '',
          initialDescription: pack.record['description'] as String?,
          initialFeeds: currentFeeds,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final bloc = context.read<StarterPackBloc>();
    String? currentUserDid;
    try {
      currentUserDid = context.read<String>();
    } catch (_) {}
    if (currentUserDid == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.dialogDeleteStarterPackTitle),
        content: Text(context.l10n.dialogDeleteStarterPackContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.buttonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: context.colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.buttonDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(StarterPackDeleted(userDid: currentUserDid));
    }
  }
}

enum _PackAction { edit, delete }

class _EditStarterPackDialog extends StatefulWidget {
  const _EditStarterPackDialog({required this.initialName, this.initialDescription, this.initialFeeds = const []});

  final String initialName;
  final String? initialDescription;
  final List<GeneratorView> initialFeeds;

  @override
  State<_EditStarterPackDialog> createState() => _EditStarterPackDialogState();
}

class _EditStarterPackDialogState extends State<_EditStarterPackDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final List<GeneratorView> _feeds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descController = TextEditingController(text: widget.initialDescription ?? '');
    _feeds = List.of(widget.initialFeeds);
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _showFeedPicker() async {
    StarterPackRepository? repo;
    try {
      repo = context.read<StarterPackRepository>();
    } catch (_) {}
    if (repo == null) return;

    final selected = await showModalBottomSheet<GeneratorView>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FeedPickerSheet(alreadySelected: _feeds.map((f) => f.uri).toSet(), starterPackRepository: repo!),
    );
    if (selected != null && mounted) {
      setState(() => _feeds.add(selected));
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    context.read<StarterPackBloc>().add(
      StarterPackUpdated(
        name: name,
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        feedUris: _feeds.map((f) => f.uri).toList(),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return AlertDialog(
      title: Text(context.l10n.labelEditStarterPack),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: context.l10n.labelName, border: const OutlineInputBorder()),
                maxLength: 50,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: context.l10n.labelDescriptionOptional,
                  border: const OutlineInputBorder(),
                ),
                maxLength: 300,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              Text(context.l10n.labelFeeds, style: context.textTheme.labelLarge),
              const SizedBox(height: 8),
              for (final feed in _feeds)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage: feed.avatar != null ? NetworkImage(feed.avatar!) : null,
                    child: feed.avatar == null ? const Icon(Icons.rss_feed, size: 14) : null,
                  ),
                  title: Text(feed.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: colorScheme.error, size: 20),
                    onPressed: () => setState(() => _feeds.remove(feed)),
                  ),
                ),
              if (_feeds.length < 3)
                TextButton.icon(
                  onPressed: _showFeedPicker,
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.buttonAddFeed),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.buttonCancel)),
        FilledButton(
          onPressed: _nameController.text.trim().isEmpty ? null : _save,
          child: Text(context.l10n.buttonSave),
        ),
      ],
    );
  }
}

class _FeedPickerSheet extends StatefulWidget {
  const _FeedPickerSheet({required this.alreadySelected, required this.starterPackRepository});

  final Set<AtUri> alreadySelected;
  final StarterPackRepository starterPackRepository;

  @override
  State<_FeedPickerSheet> createState() => _FeedPickerSheetState();
}

class _FeedPickerSheetState extends State<_FeedPickerSheet> {
  List<GeneratorView>? _feeds;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    try {
      final feeds = await widget.starterPackRepository.getSuggestedFeeds(limit: 50);
      if (mounted) setState(() => _feeds = feeds);
    } catch (e) {
      if (mounted) setState(() => _error = context.l10n.errorFailedToLoadFeeds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(context.l10n.labelSelectFeed, style: context.textTheme.titleMedium),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _error != null
                  ? Center(child: Text(_error!))
                  : _feeds == null
                  ? const Center(child: CircularProgressIndicator())
                  : material.ListView.builder(
                      controller: scrollController,
                      itemCount: _feeds!.length,
                      itemBuilder: (context, index) {
                        final feed = _feeds![index];
                        final isSelected = widget.alreadySelected.contains(feed.uri);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            backgroundImage: feed.avatar != null ? NetworkImage(feed.avatar!) : null,
                            child: feed.avatar == null ? const Icon(Icons.rss_feed) : null,
                          ),
                          title: Text(feed.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: feed.description != null
                              ? Text(feed.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                              : null,
                          trailing: isSelected ? Icon(Icons.check_circle, color: colorScheme.primary) : null,
                          enabled: !isSelected,
                          onTap: isSelected ? null : () => Navigator.pop(context, feed),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StarterPackContent extends StatelessWidget {
  const _StarterPackContent({required this.pack, required this.state});

  final bsky_graph.StarterPackView pack;
  final StarterPackState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final name = (pack.record['name'] as String?) ?? context.l10n.labelStarterPack;
    final description = pack.record['description'] as String?;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => navigateToProfile(context, pack.creator.did),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: pack.creator.avatar != null ? NetworkImage(pack.creator.avatar!) : null,
                  child: pack.creator.avatar == null
                      ? Text(
                          (pack.creator.displayName?.isNotEmpty == true
                                  ? pack.creator.displayName!
                                  : pack.creator.handle)
                              .substring(0, 1)
                              .toUpperCase(),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.creator.displayName ?? pack.creator.handle,
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '@${pack.creator.handle}',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          if (description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text(description!, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          if (pack.joinedWeekCount != null || pack.joinedAllTimeCount != null) ...[
            Row(
              children: [
                if (pack.joinedWeekCount != null) ...[
                  _buildStatChip(context, pack.joinedWeekCount!, context.l10n.labelJoinedThisWeek),
                  const SizedBox(width: 12),
                ],
                if (pack.joinedAllTimeCount != null)
                  _buildStatChip(context, pack.joinedAllTimeCount!, context.l10n.labelTotalJoined),
              ],
            ),
            const SizedBox(height: 16),
          ],
          const Divider(),
          const SizedBox(height: 8),
          _buildMembersSection(context),
          if (pack.feeds?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildFeedsSection(context),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, int count, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(formatCount(count), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final sample = pack.listItemsSample ?? const [];
    final refListUri = pack.list?.uri;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(context.l10n.labelMembers, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            if (refListUri != null) ...[
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/list?uri=${Uri.encodeComponent(refListUri.toString())}'),
                child: Text(context.l10n.buttonSeeAll),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (sample.isEmpty)
          Text(
            context.l10n.messageNoMembers,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          )
        else
          SizedBox(
            height: 72,
            child: material.ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sample.length,
              itemBuilder: (context, index) {
                final member = sample[index];
                return GestureDetector(
                  onTap: () => navigateToProfile(context, member.subject.did),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          backgroundImage: member.subject.avatar != null ? NetworkImage(member.subject.avatar!) : null,
                          child: member.subject.avatar == null
                              ? Text(
                                  (member.subject.displayName?.isNotEmpty == true
                                          ? member.subject.displayName!
                                          : member.subject.handle)
                                      .substring(0, 1)
                                      .toUpperCase(),
                                )
                              : null,
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 56,
                          child: Text(
                            member.subject.displayName ?? member.subject.handle,
                            style: textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        if (refListUri != null)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isFollowingAll
                  ? null
                  : () => context.read<StarterPackBloc>().add(const FollowAllRequested()),
              icon: state.isFollowingAll
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.group_add_outlined),
              label: Text(state.isFollowingAll ? context.l10n.buttonFollowingInProgress : context.l10n.buttonFollowAll),
            ),
          ),
      ],
    );
  }

  Widget _buildFeedsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final feeds = pack.feeds ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.labelRecommendedFeeds, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final feed in feeds.take(3))
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.surfaceContainerHighest,
              backgroundImage: feed.avatar != null ? NetworkImage(feed.avatar!) : null,
              child: feed.avatar == null ? const Icon(Icons.rss_feed) : null,
            ),
            title: Text(feed.displayName, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: feed.description != null
                ? Text(feed.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
          ),
      ],
    );
  }
}
