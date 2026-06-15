import 'package:bluesky_poptart/app/bsky/actor/defs.dart' as app_actor;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/bloc/group_create_cubit.dart';
import 'package:lazurite/features/messages/presentation/message_thread_route_args.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  List<app_actor.ProfileViewBasic> _searchResults = const [];
  bool _isSearching = false;
  String? _searchError;
  int _searchRequestId = 0;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onNameChanged)
      ..dispose();
    _searchController
      ..removeListener(_onSearchTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onNameChanged() {
    context.read<GroupCreateCubit>().nameChanged(_nameController.text);
  }

  void _onSearchTextChanged() {
    setState(() {});
  }

  Future<void> _search(String query) async {
    final normalized = query.trim();
    final requestId = ++_searchRequestId;

    if (normalized.isEmpty) {
      setState(() {
        _searchResults = const [];
        _searchError = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await context.read<TypeaheadRepository>().search(query: normalized, limit: 10);
      if (!mounted || requestId != _searchRequestId) {
        return;
      }
      setState(() {
        _searchResults = results.map((result) => result.toProfileViewBasic()).toList(growable: false);
      });
    } catch (error, stackTrace) {
      log.d('Failed to search group member candidates.', error: error, stackTrace: stackTrace);
      if (!mounted || requestId != _searchRequestId) {
        return;
      }
      setState(() {
        _searchResults = const [];
        _searchError = 'Search failed. Try a handle or display name again.';
      });
    } finally {
      if (mounted && requestId == _searchRequestId) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _addMember(app_actor.ProfileViewBasic profile) {
    context.read<GroupCreateCubit>().memberAdded(profile);
    _searchController.clear();
    setState(() {
      _searchResults = const [];
      _searchError = null;
    });
  }

  void _onCreatePressed() {
    context.read<GroupCreateCubit>().createSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupCreateCubit, GroupCreateState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == GroupCreateStatus.success && state.createdConvo != null) {
          final convo = state.createdConvo!;
          context.read<ConvoListBloc>().add(ConvoUpserted(convo: convo));
          context.go(
            '/alerts/messages/${convo.id}',
            extra: MessageThreadRouteArgs(title: state.trimmedName, convo: convo),
          );
          return;
        }

        final error = state.errorMessage;
        if (state.status == GroupCreateStatus.failure && error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error), behavior: SnackBarBehavior.floating));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('New group'),
            actions: [
              if (state.isSubmitting)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                TextButton(
                  key: const ValueKey('create_group_submit_button'),
                  onPressed: state.canCreate ? _onCreatePressed : null,
                  child: const Text('Create'),
                ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                TextField(
                  key: const ValueKey('create_group_name_field'),
                  controller: _nameController,
                  enabled: !state.isSubmitting,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: GroupCreateCubit.maxNameGraphemes,
                  decoration: InputDecoration(
                    labelText: 'Group name',
                    helperText: 'Up to 50 characters',
                    errorText: _nameError(state),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                _SelectedMembers(
                  members: state.members,
                  enabled: !state.isSubmitting,
                  onRemoved: (did) => context.read<GroupCreateCubit>().memberRemoved(did),
                ),
                const SizedBox(height: 18),
                Text('Add people', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  key: const ValueKey('create_group_member_search_field'),
                  controller: _searchController,
                  enabled: !state.isSubmitting,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search people',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchSuffix(state),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: _search,
                ),
                if (_searchError != null) ...[
                  const SizedBox(height: 8),
                  Text(_searchError!, style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.error)),
                ],
                const SizedBox(height: 8),
                _SearchResults(
                  results: _searchResults,
                  selectedDids: state.members.map((member) => member.did).toSet(),
                  onSelected: state.isSubmitting ? null : _addMember,
                ),
                if (state.members.isEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Add at least one person to create a group.',
                    style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String? _nameError(GroupCreateState state) {
    if (state.trimmedName.isEmpty || state.nameGraphemeCount <= GroupCreateCubit.maxNameGraphemes) {
      return null;
    }
    return 'Group names can be up to 50 characters.';
  }

  Widget? _searchSuffix(GroupCreateState state) {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_searchController.text.isEmpty || state.isSubmitting) {
      return null;
    }
    return IconButton(
      tooltip: 'Clear search',
      icon: const Icon(Icons.clear),
      onPressed: () {
        _searchRequestId += 1;
        _searchController.clear();
        setState(() {
          _searchResults = const [];
          _searchError = null;
          _isSearching = false;
        });
      },
    );
  }
}

class _SelectedMembers extends StatelessWidget {
  const _SelectedMembers({required this.members, required this.enabled, required this.onRemoved});

  final List<GroupCreateMember> members;
  final bool enabled;
  final ValueChanged<String> onRemoved;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: members.map((member) {
        return Chip(
          avatar: ProfileAvatar(
            size: 24,
            imageUrl: member.avatar,
            fallbackText: member.label,
            placeholderTextStyle: const TextStyle(fontSize: 10),
          ),
          label: Text(member.label, maxLines: 1, overflow: TextOverflow.ellipsis),
          onDeleted: enabled ? () => onRemoved(member.did) : null,
        );
      }).toList(),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results, required this.selectedDids, required this.onSelected});

  final List<app_actor.ProfileViewBasic> results;
  final Set<String> selectedDids;
  final ValueChanged<app_actor.ProfileViewBasic>? onSelected;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (final profile in results)
            ListTile(
              dense: true,
              leading: ProfileAvatar(
                size: 36,
                imageUrl: profile.avatar,
                fallbackText: profile.displayName?.isNotEmpty == true ? profile.displayName! : profile.handle,
                placeholderTextStyle: const TextStyle(fontSize: 12),
              ),
              title: Text(
                profile.displayName?.isNotEmpty == true ? profile.displayName! : profile.handle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('@${profile.handle}', maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: selectedDids.contains(profile.did)
                  ? Icon(Icons.check_circle, color: context.colorScheme.primary)
                  : IconButton(
                      tooltip: 'Add ${profile.handle}',
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: onSelected == null ? null : () => onSelected!(profile),
                    ),
              onTap: selectedDids.contains(profile.did) || onSelected == null ? null : () => onSelected!(profile),
            ),
        ],
      ),
    );
  }
}
