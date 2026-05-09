import 'package:poptart_core/poptart_core.dart' show AtUri;
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/lists/bloc/list_bloc.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/shared/presentation/widgets/staggered_entrance.dart';

/// Screen for adding and removing members from a list.
///
/// Expects a [ListBloc] in scope (the router provides one). Shows a
/// typeahead search field to add members and lists current members with
/// remove buttons.
class ListMembersScreen extends StatelessWidget {
  const ListMembersScreen({super.key, required this.listUri});

  final AtUri listUri;

  @override
  Widget build(BuildContext context) => const _ListMembersView();
}

class _ListMembersView extends StatefulWidget {
  const _ListMembersView();

  @override
  State<_ListMembersView> createState() => _ListMembersViewState();
}

class _ListMembersViewState extends State<_ListMembersView> {
  final _searchController = TextEditingController();
  List<ProfileViewBasic> _searchResults = [];
  bool _isSearching = false;
  final Set<String> _seenSearchResultDids = <String>{};
  final Set<String> _seenMemberUris = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.buttonAddMembers)),
      body: BlocBuilder<ListBloc, ListState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: context.l10n.messageSearchForPeoplePlaceholder,
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: _search,
                ),
              ),
              if (_searchResults.isNotEmpty)
                _buildSearchResults(context, state)
              else
                Expanded(child: _buildCurrentMembers(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, ListState state) {
    final currentDids = state.items.map((item) => item.subject.did).toSet();
    final colorScheme = context.colorScheme;

    return Expanded(
      child: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final profile = _searchResults[index];
          final isAlreadyMember = currentDids.contains(profile.did);

          return StaggeredEntrance(
            itemKey: profile.did,
            index: index,
            seenKeys: _seenSearchResultDids,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: profile.avatar != null ? NetworkImage(profile.avatar!) : null,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: profile.avatar == null
                    ? Text(
                        (profile.displayName?.isNotEmpty == true ? profile.displayName! : profile.handle)
                            .substring(0, 1)
                            .toUpperCase(),
                      )
                    : null,
              ),
              title: Text(profile.displayName ?? profile.handle, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('@${profile.handle}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
              trailing: isAlreadyMember
                  ? Icon(Icons.check_circle, color: colorScheme.primary)
                  : IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        context.read<ListBloc>().add(ListItemAdded(subjectDid: profile.did));
                        _searchController.clear();
                        setState(() => _searchResults = []);
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentMembers(BuildContext context, ListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.hasItems) {
      return Center(child: Text(context.l10n.messageNoMembersYetSearch));
    }

    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            context.l10n.labelCurrentMembers.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              final subject = item.subject;

              return StaggeredEntrance(
                itemKey: item.uri.toString(),
                index: index,
                seenKeys: _seenMemberUris,
                child: ListTile(
                  key: ValueKey(item.uri),
                  leading: CircleAvatar(
                    backgroundImage: subject.avatar != null ? NetworkImage(subject.avatar!) : null,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: subject.avatar == null
                        ? Text(
                            (subject.displayName?.isNotEmpty == true ? subject.displayName! : subject.handle)
                                .substring(0, 1)
                                .toUpperCase(),
                          )
                        : null,
                  ),
                  title: Text(subject.displayName ?? subject.handle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('@${subject.handle}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  onTap: () => navigateToProfile(context, subject.did),
                  trailing: state.isMutating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: colorScheme.error),
                          onPressed: () => context.read<ListBloc>().add(ListItemRemoved(listItemUri: item.uri)),
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
