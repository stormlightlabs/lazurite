import 'package:poptart_core/poptart_core.dart' show AtUri;
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/starter_packs/bloc/starter_pack_bloc.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

/// Full-screen form for creating a new starter pack.
///
/// Expects a [StarterPackBloc] in scope. On successful creation ([StarterPackStatus.loaded])
/// the screen navigates to the new pack's detail screen.
class CreateStarterPackScreen extends StatefulWidget {
  const CreateStarterPackScreen({super.key, required this.userDid});

  final String userDid;

  @override
  State<CreateStarterPackScreen> createState() => _CreateStarterPackScreenState();
}

class _CreateStarterPackScreenState extends State<CreateStarterPackScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _searchController = TextEditingController();

  final List<ProfileViewBasic> _selectedMembers = [];
  final List<GeneratorView> _selectedFeeds = [];

  List<ProfileViewBasic> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await context.read<TypeaheadRepository>().search(query: query.trim(), limit: 10);
      if (mounted) {
        setState(() {
          _searchResults = results.map((result) => result.toProfileViewBasic()).toList(growable: false);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _addMember(ProfileViewBasic profile) {
    if (_selectedMembers.any((m) => m.did == profile.did)) return;
    setState(() {
      _selectedMembers.add(profile);
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _removeMember(String did) {
    setState(() => _selectedMembers.removeWhere((m) => m.did == did));
  }

  void _removeFeed(AtUri uri) {
    setState(() => _selectedFeeds.removeWhere((f) => f.uri == uri));
  }

  Future<void> _showFeedPicker() async {
    final selected = await showModalBottomSheet<GeneratorView>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FeedPickerSheet(
        alreadySelected: _selectedFeeds.map((f) => f.uri).toSet(),
        starterPackRepository: context.read<StarterPackRepository>(),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _selectedFeeds.add(selected));
    }
  }

  void _save() {
    context.read<StarterPackBloc>().add(
      StarterPackCreated(
        userDid: widget.userDid,
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        memberDids: _selectedMembers.map((m) => m.did).toList(),
        feedUris: _selectedFeeds.map((f) => f.uri).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StarterPackBloc, StarterPackState>(
      listenWhen: (prev, curr) =>
          (prev.status == StarterPackStatus.loading && curr.status == StarterPackStatus.loaded) ||
          (prev.status == StarterPackStatus.loading && curr.status == StarterPackStatus.error),
      listener: (context, state) {
        if (state.status == StarterPackStatus.loaded && state.packUri != null) {
          context.pushReplacement('/starter-pack?uri=${Uri.encodeComponent(state.packUri!.toString())}');
        } else if (state.status == StarterPackStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? context.l10n.errorFailedToCreateStarterPack),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<StarterPackBloc, StarterPackState>(
        builder: (context, state) {
          final isCreating = state.status == StarterPackStatus.loading;

          return Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.labelNewStarterPack),
              actions: [
                if (isCreating)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else
                  TextButton(onPressed: _canSave ? _save : null, child: Text(context.l10n.buttonCreate)),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: context.l10n.labelName,
                    border: const OutlineInputBorder(),
                    helperText: context.l10n.formatValidationRequiredMaxCharacters(50),
                  ),
                  maxLength: 50,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !isCreating,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: context.l10n.labelDescriptionOptional,
                    border: const OutlineInputBorder(),
                  ),
                  maxLength: 300,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !isCreating,
                ),
                const SizedBox(height: 24),
                _buildMembersSection(context, isCreating),
                const SizedBox(height: 24),
                _buildFeedsSection(context, isCreating),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context, bool isCreating) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.labelMembers, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: context.l10n.messageSearchPeopleToAddPlaceholder,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : (_searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchResults = []);
                          },
                        )
                      : null),
            border: const OutlineInputBorder(),
          ),
          onChanged: _search,
          enabled: !isCreating,
        ),
        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: _searchResults.map((profile) {
                final isAlreadyAdded = _selectedMembers.any((m) => m.did == profile.did);
                return ListTile(
                  dense: true,
                  leading: ProfileAvatar(
                    size: 32,
                    imageUrl: profile.avatar,
                    fallbackText: profile.displayName?.isNotEmpty == true ? profile.displayName! : profile.handle,
                    placeholderTextStyle: const TextStyle(fontSize: 12),
                  ),
                  title: Text(profile.displayName ?? profile.handle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('@${profile.handle}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  trailing: isAlreadyAdded
                      ? Icon(Icons.check_circle, color: colorScheme.primary)
                      : IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _addMember(profile)),
                );
              }).toList(),
            ),
          ),
        ],
        if (_selectedMembers.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedMembers.map((member) {
              return Chip(
                avatar: ProfileAvatar(
                  size: 24,
                  imageUrl: member.avatar,
                  fallbackText: member.displayName?.isNotEmpty == true ? member.displayName! : member.handle,
                  placeholderTextStyle: const TextStyle(fontSize: 10),
                ),
                label: Text(member.displayName ?? member.handle, maxLines: 1, overflow: TextOverflow.ellipsis),
                onDeleted: isCreating ? null : () => _removeMember(member.did),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFeedsSection(BuildContext context, bool isCreating) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(context.l10n.labelFeeds, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text(
              context.l10n.labelUpToThree,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final feed in _selectedFeeds)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ProfileAvatar(
              size: 40,
              imageUrl: feed.avatar,
              fallbackText: feed.displayName,
              fallbackBuilder: (_) => const Icon(Icons.rss_feed),
            ),
            title: Text(feed.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: feed.description != null
                ? Text(feed.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            trailing: isCreating
                ? null
                : IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: colorScheme.error),
                    onPressed: () => _removeFeed(feed.uri),
                  ),
          ),
        if (_selectedFeeds.length < 3)
          OutlinedButton.icon(
            onPressed: isCreating ? null : _showFeedPicker,
            icon: const Icon(Icons.add),
            label: Text(context.l10n.buttonAddFeed),
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
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _feeds!.length,
                      itemBuilder: (context, index) {
                        final feed = _feeds![index];
                        final isSelected = widget.alreadySelected.contains(feed.uri);

                        return ListTile(
                          leading: ProfileAvatar(
                            size: 40,
                            imageUrl: feed.avatar,
                            fallbackText: feed.displayName,
                            fallbackBuilder: (_) => const Icon(Icons.rss_feed),
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
