import 'package:bluesky_poptart/chat/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/bloc/group_details_cubit.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({super.key, required this.convoId});

  final String convoId;

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<GroupDetailsCubit>().load();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<GroupDetailsCubit>().loadMoreMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserDid = context.read<String>();

    return BlocConsumer<GroupDetailsCubit, GroupDetailsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.leaveSucceeded != current.leaveSucceeded ||
          previous.convo != current.convo,
      listener: (context, state) {
        if (state.convo != null) {
          context.read<ConvoListBloc>().add(ConvoUpserted(convo: state.convo!));
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!), behavior: SnackBarBehavior.floating));
        }
        if (state.leaveSucceeded) {
          context.go('/alerts/messages');
        }
      },
      builder: (context, state) {
        final group = state.group;
        final canManage = state.canManage(currentUserDid);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Group details'),
            actions: [
              if (state.isMutating)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
            ],
          ),
          body: switch (state.status) {
            GroupDetailsStatus.initial ||
            GroupDetailsStatus.loading => const Center(child: CircularProgressIndicator()),
            GroupDetailsStatus.error when state.convo == null => _ErrorView(
              onRetry: context.read<GroupDetailsCubit>().load,
            ),
            _ => ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _GroupSummary(group: group, fallbackName: state.convo?.id ?? widget.convoId),
                const SizedBox(height: 16),
                if (canManage) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        key: const ValueKey('group_details_rename_button'),
                        onPressed: state.isMutating ? null : () => _showRenameDialog(context, group?.name ?? ''),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Rename'),
                      ),
                      OutlinedButton.icon(
                        key: const ValueKey('group_details_add_member_button'),
                        onPressed: state.isMutating ? null : () => _showAddMemberSheet(context),
                        icon: const Icon(Icons.person_add_alt),
                        label: const Text('Add member'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton.tonalIcon(
                  key: const ValueKey('group_details_leave_button'),
                  onPressed: state.isMutating ? null : context.read<GroupDetailsCubit>().leaveGroup,
                  icon: const Icon(Icons.logout),
                  label: const Text('Leave group'),
                ),
                const SizedBox(height: 24),
                Text('Members', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final member in state.members)
                  _MemberTile(
                    member: member,
                    canRemove: canManage && member.did != currentUserDid,
                    isMutating: state.isMutating,
                    onRemove: () => context.read<GroupDetailsCubit>().removeMember(member.did),
                  ),
                if (state.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.hasMore)
                  TextButton(
                    key: const ValueKey('group_details_load_more_button'),
                    onPressed: context.read<GroupDetailsCubit>().loadMoreMembers,
                    child: const Text('Load more members'),
                  ),
              ],
            ),
          },
        );
      },
    );
  }

  Future<void> _showRenameDialog(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename group'),
        content: TextField(
          key: const ValueKey('group_details_rename_field'),
          controller: controller,
          autofocus: true,
          maxLength: 50,
          decoration: const InputDecoration(labelText: 'Group name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          FilledButton(
            key: const ValueKey('group_details_rename_submit'),
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && context.mounted) {
      await context.read<GroupDetailsCubit>().renameGroup(name);
    }
  }

  Future<void> _showAddMemberSheet(BuildContext context) async {
    final selectedDid = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddMemberSheet(repository: context.read<TypeaheadRepository>()),
    );
    if (selectedDid != null && context.mounted) {
      await context.read<GroupDetailsCubit>().addMember(selectedDid);
    }
  }
}

class _GroupSummary extends StatelessWidget {
  const _GroupSummary({required this.group, required this.fallbackName});

  final GroupConvo? group;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memberCount = group?.memberCount;
    final lockStatus = group?.lockStatus.toJson();
    final memberLimit = group?.$unknown?['memberLimit'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group?.name ?? fallbackName,
          style: theme.textTheme.headlineSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (memberCount != null) Chip(label: Text(memberCount == 1 ? '1 member' : '$memberCount members')),
            if (memberLimit is int) Chip(label: Text('Limit $memberLimit')),
            if (lockStatus != null) Chip(label: Text(lockStatus)),
          ],
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.canRemove, required this.isMutating, required this.onRemove});

  final ProfileViewBasic member;
  final bool canRemove;
  final bool isMutating;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final role = member.kind?.groupConvoMember?.role.knownValue?.value;
    final label = member.displayName?.trim().isNotEmpty == true ? member.displayName! : member.handle;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ProfileAvatar(size: 40, imageUrl: member.avatar, fallbackText: label),
      title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '@${member.handle}${role == null ? '' : ' · $role'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: canRemove
          ? IconButton(
              tooltip: 'Remove ${member.handle}',
              icon: const Icon(Icons.person_remove_outlined),
              onPressed: isMutating ? null : onRemove,
            )
          : null,
    );
  }
}

class _AddMemberSheet extends StatefulWidget {
  const _AddMemberSheet({required this.repository});

  final TypeaheadRepository repository;

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _controller = TextEditingController();
  List<TypeaheadResult> _results = const [];
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await widget.repository.search(query: normalized, limit: 10);
      if (mounted) {
        setState(() => _results = results);
      }
    } catch (error, stackTrace) {
      log.d('Failed to search add-member candidates.', error: error, stackTrace: stackTrace);
      if (mounted) setState(() => _results = const []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const ValueKey('group_details_add_member_search'),
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search people',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : null,
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 12),
            for (final result in _results)
              ListTile(
                leading: ProfileAvatar(
                  size: 36,
                  imageUrl: result.avatarUrl,
                  fallbackText: result.displayName?.trim().isNotEmpty == true ? result.displayName! : result.handle,
                ),
                title: Text(result.displayName?.trim().isNotEmpty == true ? result.displayName! : result.handle),
                subtitle: Text('@${result.handle}'),
                onTap: () => Navigator.of(context).pop(result.did),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Failed to load group details.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
