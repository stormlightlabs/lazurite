import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:bsky_moderation/bsky_moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/presentation/widgets/compact_post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_footer.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderation_badge_row.dart';
import 'package:lazurite/features/search/bloc/search_bloc.dart';
import 'package:lazurite/features/search/data/post_search_filters.dart';
import 'package:lazurite/features/search/presentation/widgets/follow_button.dart';
import 'package:lazurite/features/search/presentation/widgets/search_result_states.dart';
import 'package:lazurite/features/starter_packs/presentation/widgets/starter_pack_card.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/presentation/typeahead_text_field.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/app_screen_entrance.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:lazurite/shared/presentation/widgets/staggered_entrance.dart';
import 'package:lazurite/shared/utils/format_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    this.postsOnlyMode = false,
    this.fixedPostAuthor,
    this.showBackButton = false,
    this.title,
    this.showJumpToProfileAction = true,
  });

  final bool postsOnlyMode;
  final String? fixedPostAuthor;
  final bool showBackButton;
  final String? title;
  final bool showJumpToProfileAction;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static final Uri _starterPackSearchIssueUri = Uri.parse('https://github.com/bluesky-social/bsky-docs/issues/306');

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _seenResultKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchBloc>().add(const LoadMoreRequested());
    }
  }

  void _onSubmit(String query) {
    final state = context.read<SearchBloc>().state;
    if (query.trim().isEmpty && state.currentTab != SearchTab.posts) {
      return;
    }
    if (state.currentTab == SearchTab.starterPacks) {
      _focusNode.unfocus();
      return;
    }
    context.read<SearchBloc>().add(QuerySubmitted(query: query));
    _focusNode.unfocus();
  }

  void _onCancel() {
    _searchController.clear();
    setState(() {});
    context.read<SearchBloc>().add(const QueryCleared());
  }

  void _onTabChanged(SearchTab tab) {
    if (widget.postsOnlyMode) {
      return;
    }
    context.read<SearchBloc>().add(SearchTabChanged(tab: tab));
    if (tab == SearchTab.starterPacks) {
      _focusNode.unfocus();
    }
  }

  void _onSortChanged(String sort) {
    context.read<SearchBloc>().add(SearchSortChanged(sort: sort));
  }

  void _onHistoryTap(String query, String type) {
    _searchController.text = query;
    final tab = switch (type) {
      'posts' => SearchTab.posts,
      'feeds' => SearchTab.feeds,
      'starter_packs' => SearchTab.starterPacks,
      _ => SearchTab.actors,
    };
    context.read<SearchBloc>().add(SearchTabChanged(tab: tab));
    context.read<SearchBloc>().add(QuerySubmitted(query: query));
    _focusNode.unfocus();
  }

  void _onHistoryDelete(int id) {
    context.read<SearchBloc>().add(HistoryEntryDeleted(id: id));
  }

  Future<void> _onClearHistory() async {
    await showConfirmationDialog(
      context: context,
      title: Text(context.l10n.messageClearSearchHistoryTitle),
      content: Text(context.l10n.messageClearSearchHistoryContent),
      confirmLabel: context.l10n.buttonClear,
      onConfirmed: () => context.read<SearchBloc>().add(const HistoryCleared()),
    );
  }

  void _openJumpToProfileDialog() {
    final controller = TextEditingController();
    final typeaheadRepository = context.read<TypeaheadRepository>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void submitHandle([String? value]) {
              final rawValue = (value ?? controller.text).trim();
              final handle = rawValue.startsWith('@') ? rawValue.substring(1).trim() : rawValue;
              if (handle.isEmpty) {
                return;
              }

              Navigator.of(dialogContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  navigateToProfile(this.context, handle);
                }
              });
            }

            final showTypingHint = controller.text.trim().length <= 3;
            return ConfirmationDialog(
              title: Text(context.l10n.labelJumpToProfile),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TypeaheadTextField(
                      controller: controller,
                      repository: typeaheadRepository,
                      onSelected: (result) {
                        controller.text = result.handle;
                        submitHandle(result.did);
                      },
                      minChars: 2,
                      debounceMs: 300,
                      limit: 8,
                      autocorrect: false,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: submitHandle,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: context.l10n.labelHandle,
                        hintText: 'alice.bsky.social',
                        prefixText: '@',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (showTypingHint)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(context.l10n.messageStartTypingToSearchHandles, style: context.textTheme.bodySmall),
                      ),
                  ],
                ),
              ),
              confirmLabel: context.l10n.buttonOpen,
              confirmEnabled: controller.text.trim().isNotEmpty,
              onCancel: () => Navigator.of(dialogContext).pop(),
              onConfirm: submitHandle,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowFab = widget.showJumpToProfileAction && !widget.postsOnlyMode;
    final l10n = context.l10n;
    return AppScreenEntrance(
      child: Scaffold(
        appBar: widget.postsOnlyMode
            ? AppBar(
                title: Text(widget.title ?? l10n.labelSearchPosts),
                leading: widget.showBackButton
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.canPop() ? context.pop() : context.go('/search'),
                      )
                    : null,
              )
            : null,
        floatingActionButton: shouldShowFab
            ? FloatingActionButton.extended(
                onPressed: _openJumpToProfileDialog,
                icon: const Icon(Icons.person_search),
                label: Text(l10n.labelJumpToProfile),
              ).animateIfAllowed(
                context,
                effects: const [
                  FadeEffect(duration: Anim.feedItem, curve: Anim.enter),
                  ScaleEffect(begin: Offset(0, 0), end: Offset(1, 1), duration: Anim.feedItem, curve: Anim.emphasis),
                ],
              )
            : null,
        body: SafeArea(
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              return Column(
                children: [
                  _buildSearchBar(context, state),
                  if (!widget.postsOnlyMode) _buildTabs(context, state),
                  if (state.currentTab == SearchTab.posts || widget.postsOnlyMode) _buildSortToggle(context, state),
                  if (state.currentTab == SearchTab.posts || widget.postsOnlyMode)
                    _buildPostFilterChips(context, state),
                  Expanded(child: _buildBody(context, state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, SearchState state) {
    final hasText = _searchController.text.isNotEmpty;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isSearchDisabled = state.currentTab == SearchTab.starterPacks;
    final fieldFillColor = isSearchDisabled
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)
        : theme.colorScheme.surfaceContainerHighest;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          if (!widget.postsOnlyMode) const AppShellMenuButton() else const SizedBox(width: 0),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              enabled: !isSearchDisabled,
              autocorrect: false,
              enableSuggestions: false,
              smartDashesType: SmartDashesType.disabled,
              smartQuotesType: SmartQuotesType.disabled,
              onSubmitted: _onSubmit,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: _searchPlaceholderForTab(state.currentTab),
                helperText: isSearchDisabled ? l10n.messageStarterPackSearchApiUnavailable : null,
                helperMaxLines: 1,
                prefixIcon: Icon(
                  isSearchDisabled ? Icons.block_outlined : Icons.search,
                  size: 20,
                  color: isSearchDisabled ? theme.colorScheme.onSurfaceVariant : null,
                ),
                suffixIcon: hasText && !isSearchDisabled ? _buildSuffixIcon(context, theme) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(999)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                filled: true,
                fillColor: fieldFillColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuffixIcon(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _onCancel,
          icon: const Icon(Icons.close, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
        IconButton(
          onPressed: () => _onSubmit(_searchController.text),
          icon: Icon(Icons.arrow_forward_rounded, size: 20, color: theme.colorScheme.primary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context, SearchState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab(context, SearchTab.posts, state),
            _buildTab(context, SearchTab.actors, state),
            _buildTab(context, SearchTab.feeds, state),
            _buildTab(context, SearchTab.starterPacks, state),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, SearchTab tab, SearchState state) {
    final isSelected = state.currentTab == tab;
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
    );
    return InkWell(
      onTap: () => _onTabChanged(tab),
      child: Container(
        constraints: const BoxConstraints(minWidth: 96),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.transparent, width: 2),
          ),
        ),
        child: Text(
          _tabLabel(context, tab),
          textAlign: TextAlign.center,
          style: textStyle,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }

  Widget _buildSortToggle(BuildContext context, SearchState state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.l10n.labelSortBy,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSortOption(context, SearchSort.top, state),
                _buildSortOption(context, SearchSort.latest, state),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _openPostFiltersSheet(state.postFilters),
            icon: const Icon(Icons.tune, size: 16),
            label: Text(context.l10n.labelFilters),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, SearchSort sort, SearchState state) {
    final isSelected = state.currentSort == sort.name;
    final theme = Theme.of(context);
    final labelColor = isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => _onSortChanged(sort.name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _sortLabel(context, sort),
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: labelColor),
        ),
      ),
    );
  }

  Widget _buildPostFilterChips(BuildContext context, SearchState state) {
    final filters = state.postFilters;
    final chips = <Widget>[];

    void addChip(String label, {required VoidCallback onDeleted}) {
      chips.add(
        InputChip(
          label: Text(label),
          onDeleted: onDeleted,
          deleteIcon: const Icon(Icons.close, size: 16),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    if (filters.mentions?.isNotEmpty == true) {
      addChip('Mentions: ${filters.mentions}', onDeleted: () => _updatePostFilters(filters.copyWith(mentions: null)));
    }
    if (widget.fixedPostAuthor == null && filters.author?.isNotEmpty == true) {
      addChip('Author: ${filters.author}', onDeleted: () => _updatePostFilters(filters.copyWith(author: null)));
    }
    if (filters.lang?.isNotEmpty == true) {
      addChip('Lang: ${filters.lang}', onDeleted: () => _updatePostFilters(filters.copyWith(lang: null)));
    }
    if (filters.domain?.isNotEmpty == true) {
      addChip('Domain: ${filters.domain}', onDeleted: () => _updatePostFilters(filters.copyWith(domain: null)));
    }
    if (filters.url?.isNotEmpty == true) {
      addChip('URL: ${filters.url}', onDeleted: () => _updatePostFilters(filters.copyWith(url: null)));
    }
    if (filters.since != null) {
      addChip(
        'Since: ${formatTimestamp(filters.since!)}',
        onDeleted: () => _updatePostFilters(filters.copyWith(since: null)),
      );
    }
    if (filters.until != null) {
      addChip(
        'Until: ${formatTimestamp(filters.until!)}',
        onDeleted: () => _updatePostFilters(filters.copyWith(until: null)),
      );
    }
    for (final tag in filters.tags) {
      addChip('#$tag', onDeleted: () => _removeTag(filters, tag));
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 8, runSpacing: 6, children: chips),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _updatePostFilters(
                widget.fixedPostAuthor == null
                    ? const PostSearchFilters()
                    : PostSearchFilters(author: widget.fixedPostAuthor),
              ),
              child: Text(context.l10n.buttonClearAll),
            ),
          ),
        ],
      ),
    );
  }

  void _removeTag(PostSearchFilters filters, String tag) {
    final updatedTags = filters.tags.where((entry) => entry.toLowerCase() != tag.toLowerCase()).toList(growable: false);
    _updatePostFilters(filters.copyWith(tags: updatedTags));
  }

  Future<void> _openPostFiltersSheet(PostSearchFilters currentFilters) async {
    final mentionsController = TextEditingController(text: currentFilters.mentions ?? '');
    final authorController = TextEditingController(text: currentFilters.author ?? '');
    final langController = TextEditingController(text: currentFilters.lang ?? '');
    final domainController = TextEditingController(text: currentFilters.domain ?? '');
    final urlController = TextEditingController(text: currentFilters.url ?? '');
    final tagsController = TextEditingController(text: currentFilters.tags.join(', '));
    DateTime? since = currentFilters.since;
    DateTime? until = currentFilters.until;

    Future<DateTime?> pickDateTime(DateTime? initial, {required bool isUntil}) async {
      final now = DateTime.now();
      final initialDate = initial ?? now;
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year + 5),
      );
      if (date == null || !mounted) {
        return initial;
      }

      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initialDate));
      if (time == null) {
        final boundary = DateTime(date.year, date.month, date.day);
        return (isUntil ? boundary.add(const Duration(days: 1)) : boundary).toUtc();
      }

      return DateTime(date.year, date.month, date.day, time.hour, time.minute).toUtc();
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.labelPostFilters, style: context.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: mentionsController,
                      autocorrect: false,
                      enableSuggestions: false,
                      smartDashesType: SmartDashesType.disabled,
                      smartQuotesType: SmartQuotesType.disabled,
                      decoration: InputDecoration(
                        labelText: context.l10n.labelMentions,
                        hintText: 'did:plc:... or handle',
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (widget.fixedPostAuthor == null) ...[
                      TextField(
                        controller: authorController,
                        autocorrect: false,
                        enableSuggestions: false,
                        smartDashesType: SmartDashesType.disabled,
                        smartQuotesType: SmartQuotesType.disabled,
                        decoration: InputDecoration(
                          labelText: context.l10n.labelAuthor,
                          hintText: 'did:plc:... or handle',
                        ),
                      ),
                      const SizedBox(height: 10),
                    ] else ...[
                      InputDecorator(
                        decoration: InputDecoration(labelText: context.l10n.labelAuthorFixed),
                        child: Text(widget.fixedPostAuthor!),
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      controller: langController,
                      autocorrect: false,
                      enableSuggestions: false,
                      smartDashesType: SmartDashesType.disabled,
                      smartQuotesType: SmartQuotesType.disabled,
                      decoration: InputDecoration(labelText: context.l10n.labelLanguage, hintText: 'en'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: domainController,
                      autocorrect: false,
                      enableSuggestions: false,
                      smartDashesType: SmartDashesType.disabled,
                      smartQuotesType: SmartQuotesType.disabled,
                      decoration: InputDecoration(labelText: context.l10n.labelDomain, hintText: 'example.com'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: urlController,
                      autocorrect: false,
                      enableSuggestions: false,
                      smartDashesType: SmartDashesType.disabled,
                      smartQuotesType: SmartQuotesType.disabled,
                      decoration: InputDecoration(
                        labelText: context.l10n.labelUrl,
                        hintText: 'https://example.com/path',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tagsController,
                      autocorrect: false,
                      enableSuggestions: false,
                      smartDashesType: SmartDashesType.disabled,
                      smartQuotesType: SmartQuotesType.disabled,
                      decoration: InputDecoration(labelText: context.l10n.labelTags, hintText: '#dart, flutter'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              FocusScope.of(sheetContext).unfocus();
                              final selected = await pickDateTime(since, isUntil: false);
                              if (selected == null) {
                                return;
                              }
                              setState(() => since = selected);
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(since == null ? context.l10n.labelSince : formatTimestamp(since!)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              FocusScope.of(sheetContext).unfocus();
                              final selected = await pickDateTime(until, isUntil: true);
                              if (selected == null) {
                                return;
                              }
                              setState(() => until = selected);
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(until == null ? context.l10n.labelUntil : formatTimestamp(until!)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => setState(() => since = null),
                          child: Text(context.l10n.labelClearSince),
                        ),
                        TextButton(
                          onPressed: () => setState(() => until = null),
                          child: Text(context.l10n.labelClearUntil),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: Text(context.l10n.buttonCancel),
                        ),
                        TextButton(
                          onPressed: () {
                            FocusScope.of(sheetContext).unfocus();
                            _updatePostFilters(
                              widget.fixedPostAuthor == null
                                  ? const PostSearchFilters()
                                  : PostSearchFilters(author: widget.fixedPostAuthor),
                            );
                            Navigator.of(sheetContext).pop();
                          },
                          child: Text(context.l10n.buttonClearAll),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {
                            FocusScope.of(sheetContext).unfocus();
                            final tags = tagsController.text
                                .split(',')
                                .map((value) => value.trim())
                                .where((value) => value.isNotEmpty)
                                .toList(growable: false);
                            final nextFilters = PostSearchFilters(
                              mentions: mentionsController.text,
                              author: widget.fixedPostAuthor ?? authorController.text,
                              lang: langController.text,
                              domain: domainController.text,
                              url: urlController.text,
                              tags: tags,
                              since: since,
                              until: until,
                            );
                            _updatePostFilters(nextFilters);
                            Navigator.of(sheetContext).pop();
                          },
                          child: Text(context.l10n.buttonApply),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _updatePostFilters(PostSearchFilters filters) {
    try {
      context.read<SearchBloc>().add(PostFiltersChanged(filters: filters));
    } on PostSearchValidationException catch (error) {
      showAppSnackBar(context, error.message);
    }
  }

  Widget _buildBody(BuildContext context, SearchState state) {
    if (state.currentTab == SearchTab.starterPacks) {
      return _buildStarterPacksUnavailableState(context);
    }

    if (state.query.isEmpty && (state.currentTab != SearchTab.posts || state.postFilters.isEmpty)) {
      return _buildSearchHistory(context, state);
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Search failed', style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<SearchBloc>().add(QuerySubmitted(query: state.query)),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.currentTab == SearchTab.posts) {
      return _buildPostResults(context, state);
    } else if (state.currentTab == SearchTab.feeds) {
      return _buildFeedResults(context, state);
    } else if (state.currentTab == SearchTab.starterPacks) {
      return _buildStarterPackResults(context, state);
    } else {
      return _buildActorResults(context, state);
    }
  }

  Widget _buildSearchHistory(BuildContext context, SearchState state) {
    final history = state.searchHistory;
    if (history.isEmpty) {
      return SearchEmptyState(tab: state.currentTab);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Searches', style: context.textTheme.titleSmall),
              TextButton(onPressed: _onClearHistory, child: const Text('Clear All')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              final label = switch (entry.type) {
                'posts' => 'Posts',
                'feeds' => 'Feeds',
                'starter_packs' => 'Starter Packs',
                _ => 'People',
              };
              return Dismissible(
                key: Key('history_${entry.id}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _onHistoryDelete(entry.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  color: context.colorScheme.error,
                  child: Icon(Icons.delete, color: context.colorScheme.onError),
                ),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(entry.query),
                  subtitle: Text(
                    '$label · ${formatRelativeTime(entry.searchedAt, nowLabel: 'Just now', includeAgo: true)}',
                  ),
                  onTap: () => _onHistoryTap(entry.query, entry.type),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostResults(BuildContext context, SearchState state) {
    final posts = state.posts;
    if (posts.isEmpty) {
      return SearchNoResultsState(tab: SearchTab.posts, query: state.query);
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: posts.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return const Center(
            child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          );
        }
        final post = posts[index];
        return StaggeredEntrance(
          itemKey: post.uri.toString(),
          index: index,
          seenKeys: _seenResultKeys,
          child: CompactPostCard(
            feedViewPost: FeedViewPost(post: post),
            onTap: () => context.push('/post?uri=${Uri.encodeQueryComponent(post.uri.toString())}'),
            footer: PostCardFooter(
              timestamp: formatPostTime(post.indexedAt),
              replyCount: post.replyCount ?? 0,
              repostCount: post.repostCount ?? 0,
              likeCount: post.likeCount ?? 0,
              showCounts: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActorResults(BuildContext context, SearchState state) {
    final actors = state.actors;
    if (actors.isEmpty) {
      return SearchNoResultsState(tab: SearchTab.actors, query: state.query);
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: actors.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == actors.length) {
          return const Center(
            child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          );
        }
        final actor = actors[index];
        return StaggeredEntrance(
          itemKey: actor.did,
          index: index,
          seenKeys: _seenResultKeys,
          child: _ActorResultTile(actor: actor),
        );
      },
    );
  }

  Widget _buildFeedResults(BuildContext context, SearchState state) {
    final feeds = state.feeds;
    if (feeds.isEmpty) {
      return SearchNoResultsState(tab: SearchTab.feeds, query: state.query);
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: feeds.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == feeds.length) {
          return const Center(
            child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          );
        }

        final feed = feeds[index];
        return StaggeredEntrance(
          itemKey: feed.uri.toString(),
          index: index,
          seenKeys: _seenResultKeys,
          child: _FeedResultTile(
            feed: feed,
            onAdded: (displayName) {
              showAppSnackBar(
                context,
                'Added $displayName to your saved feeds',
                actionLabel: 'Manage',
                onAction: () => GoRouter.maybeOf(context)?.push('/feeds'),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStarterPackResults(BuildContext context, SearchState state) {
    final packs = state.starterPacks;
    if (packs.isEmpty) {
      return SearchNoResultsState(tab: SearchTab.starterPacks, query: state.query);
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: packs.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == packs.length) {
          return const Center(
            child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          );
        }
        final pack = packs[index];
        return StaggeredEntrance(
          itemKey: pack.uri.toString(),
          index: index,
          seenKeys: _seenResultKeys,
          child: StarterPackCard(
            pack: pack,
            onTap: () {
              final router = GoRouter.maybeOf(context);
              if (router != null) {
                router.push('/starter-pack?uri=${Uri.encodeComponent(pack.uri.toString())}');
              }
            },
          ),
        );
      },
    );
  }

  String _searchPlaceholderForTab(SearchTab tab) => switch (tab) {
    SearchTab.posts =>
      widget.postsOnlyMode
          ? context.l10n.messageSearchThisProfilesPostsPlaceholder
          : context.l10n.messageSearchPostsPlaceholder,
    SearchTab.actors => context.l10n.messageSearchPeoplePlaceholder,
    SearchTab.feeds => context.l10n.messageSearchFeedsPlaceholder,
    SearchTab.starterPacks => context.l10n.messageStarterPackSearchUnavailablePlaceholder,
  };

  Widget _buildStarterPacksUnavailableState(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 52, color: context.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            context.l10n.messageStarterPackSearchUnavailableTitle,
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.messageStarterPackSearchUnavailableBody,
            style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _openStarterPackIssue,
            icon: const Icon(Icons.open_in_new),
            label: Text(context.l10n.messageTrackApiProgress),
          ),
        ],
      ),
    ),
  );

  Future<void> _openStarterPackIssue() async {
    final launched = await launchUrl(_starterPackSearchIssueUri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      showAppSnackBar(context, context.l10n.messageCouldNotOpenIssueLink);
    }
  }

  String _tabLabel(BuildContext context, SearchTab tab) => switch (tab) {
    SearchTab.posts => context.l10n.labelPosts,
    SearchTab.actors => context.l10n.labelPeople,
    SearchTab.feeds => context.l10n.labelFeeds,
    SearchTab.starterPacks => context.l10n.labelStarterPacks,
  };

  String _sortLabel(BuildContext context, SearchSort sort) => switch (sort) {
    SearchSort.top => context.l10n.labelTop,
    SearchSort.latest => context.l10n.labelLatest,
  };
}

class _ActorResultTile extends StatelessWidget {
  const _ActorResultTile({required this.actor});

  final ProfileView actor;

  @override
  Widget build(BuildContext context) {
    final moderationService = maybeModerationService(context);
    final profileUi =
        moderationService?.profileUi(actor, bsky_moderation.ModerationBehaviorContext.profileList) ??
        const bsky_moderation.ModerationUI();
    final avatarUi =
        moderationService?.profileUi(actor, bsky_moderation.ModerationBehaviorContext.avatar) ??
        const bsky_moderation.ModerationUI();

    return InkWell(
      onTap: () => navigateToProfile(context, actor.did),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            ProfileAvatar(
              size: 48,
              moderationUi: avatarUi,
              imageUrl: actor.avatar,
              fallbackText: actor.displayName ?? actor.handle,
              shape: BoxShape.circle,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actor.displayName ?? actor.handle,
                    style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '@${actor.handle}',
                    style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                  if (profileUi.alert || profileUi.inform) ...[
                    const SizedBox(height: 8),
                    ModerationBadgeRow(ui: profileUi),
                  ],
                  if (actor.description != null && actor.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      actor.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            FollowButton(actor: actor),
          ],
        ),
      ),
    );
  }
}

class _FeedResultTile extends StatelessWidget {
  const _FeedResultTile({required this.feed, required this.onAdded});

  final GeneratorView feed;
  final ValueChanged<String> onAdded;

  @override
  Widget build(BuildContext context) {
    final displayName = feedDisplayName(feed);
    final avatarUrl = feed.avatar ?? feed.creator.avatar;
    final isAdded = context.select<FeedPreferencesCubit, bool>(
      (cubit) => cubit.state.containsFeedValue(feed.uri.toString()),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(colors: [Color(0xFF08BDBA), Color(0xFF3DDBD9)]),
            ),
            child: avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.rss_feed, color: Colors.white),
                    ),
                  )
                : const Icon(Icons.rss_feed, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'by @${feed.creator.handle}',
                  style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
                if (feed.description != null && feed.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    feed.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: isAdded
                ? null
                : () async {
                    await context.read<FeedPreferencesCubit>().addFeed(
                      type: const SavedFeedType.knownValue(data: KnownSavedFeedType.feed),
                      value: feed.uri.toString(),
                      pinned: false,
                    );
                    if (!context.mounted) return;
                    onAdded(displayName);
                  },
            child: Text(isAdded ? 'Added' : '+ Add'),
          ),
        ],
      ),
    );
  }
}
