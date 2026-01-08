import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';

import '../../application/settings_providers.dart';
import '../../domain/bluesky_preferences.dart';
import '../widgets/settings_section.dart';

/// Muted words management screen.
///
/// Allows users to view, add, and remove muted words for content filtering.
/// Displays active and expired muted words separately, with the ability to
/// add new muted words via a dialog.
class MutedWordsScreen extends ConsumerStatefulWidget {
  const MutedWordsScreen({super.key});

  @override
  ConsumerState<MutedWordsScreen> createState() => _MutedWordsScreenState();
}

class _MutedWordsScreenState extends ConsumerState<MutedWordsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final mutedWordsAsync = ref.watch(mutedWordsPrefProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Muted Words'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
            tooltip: 'Add muted word',
          ),
        ],
      ),
      body: mutedWordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (pref) => _buildContent(context, pref),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MutedWordsPref pref) {
    final activeWords = pref.activeItems;
    final expiredWords = pref.items.where((w) => w.isExpired).toList();

    final filteredActive = _searchQuery.isEmpty
        ? activeWords
        : activeWords
              .where((w) => w.value.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

    final filteredExpired = _searchQuery.isEmpty
        ? expiredWords
        : expiredWords
              .where((w) => w.value.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

    if (activeWords.isEmpty && expiredWords.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        if (activeWords.length > 5) _buildSearchBar(context),
        Expanded(
          child: ListView(
            children: [
              if (filteredActive.isNotEmpty) ...[
                const SettingsSection(title: 'Active'),
                ...filteredActive.map((word) => _buildMutedWordTile(context, word, pref)),
              ],
              if (filteredExpired.isNotEmpty) ...[
                const SizedBox(height: 16),
                const SettingsSection(title: 'Expired'),
                ...filteredExpired.map(
                  (word) => _buildMutedWordTile(context, word, pref, isExpired: true),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volume_off_outlined,
              size: 64,
              color: theme.colorScheme.primary.withAlpha(127),
            ),
            const SizedBox(height: 16),
            Text('No Muted Words', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Add words or phrases to filter from your feeds',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Muted Word'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search muted words',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildMutedWordTile(
    BuildContext context,
    MutedWord word,
    MutedWordsPref pref, {
    bool isExpired = false,
  }) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return ListTile(
      title: Text(
        word.value,
        style: isExpired
            ? theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                decoration: TextDecoration.lineThrough,
              )
            : null,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (word.targets.isNotEmpty)
                Chip(
                  label: Text(
                    'Targets: ${word.targets.map((t) => t.name).join(', ')}',
                    style: theme.textTheme.bodySmall,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              Chip(
                label: Text(
                  word.actorTarget == MutedWordActorTarget.all
                      ? 'All accounts'
                      : 'Exclude following',
                  style: theme.textTheme.bodySmall,
                ),
                visualDensity: VisualDensity.compact,
              ),
              if (word.expiresAt != null)
                Chip(
                  label: Text(
                    isExpired
                        ? 'Expired: ${dateFormat.format(word.expiresAt!)}'
                        : 'Expires: ${dateFormat.format(word.expiresAt!)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _removeMutedWord(word, pref),
        tooltip: 'Remove',
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<MutedWord>(
      context: context,
      builder: (context) => const AddMutedWordDialog(),
    );

    if (result != null && mounted) {
      await _addMutedWord(result);
    }
  }

  Future<void> _addMutedWord(MutedWord word) async {
    final pref = await ref.read(mutedWordsPrefProvider.future);
    final updatedItems = [...pref.items, word];

    final repo = ref.read(blueskyPreferencesRepositoryProvider);
    final authState = ref.read(authProvider);
    if (authState is AuthStateAuthenticated) {
      await repo.updateMutedWordsPref(MutedWordsPref(items: updatedItems), authState.session.did);
    }
  }

  Future<void> _removeMutedWord(MutedWord word, MutedWordsPref pref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Muted Word'),
        content: Text('Remove "${word.value}" from muted words?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final updatedItems = pref.items.where((w) => w.id != word.id).toList();
      final repo = ref.read(blueskyPreferencesRepositoryProvider);
      final authState = ref.read(authProvider);
      if (authState is AuthStateAuthenticated) {
        await repo.updateMutedWordsPref(
          MutedWordsPref(items: updatedItems),
          authState.session.did,
        );
      }
    }
  }
}

/// Dialog for adding a new muted word.
///
/// Allows the user to specify the word/phrase, targets (content/tags),
/// actor target (all/exclude-following), and optional expiration date.
class AddMutedWordDialog extends StatefulWidget {
  const AddMutedWordDialog({super.key});

  @override
  State<AddMutedWordDialog> createState() => _AddMutedWordDialogState();
}

class _AddMutedWordDialogState extends State<AddMutedWordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _targets = <MutedWordTarget>{MutedWordTarget.content};
  var _actorTarget = MutedWordActorTarget.all;
  DateTime? _expiresAt;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add Muted Word'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Word or phrase',
                  hintText: 'Enter word or phrase to mute',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a word or phrase';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Text('Targets', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Content'),
                subtitle: const Text('Mute in post text'),
                value: _targets.contains(MutedWordTarget.content),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _targets.add(MutedWordTarget.content);
                    } else {
                      _targets.remove(MutedWordTarget.content);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
              CheckboxListTile(
                title: const Text('Tags'),
                subtitle: const Text('Mute in hashtags'),
                value: _targets.contains(MutedWordTarget.tags),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _targets.add(MutedWordTarget.tags);
                    } else {
                      _targets.remove(MutedWordTarget.tags);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
              if (_targets.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    'At least one target must be selected',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 16),
              Text('Actor Target', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              RadioGroup<MutedWordActorTarget>(
                groupValue: _actorTarget,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _actorTarget = value);
                  }
                },
                child: const Column(
                  children: [
                    RadioListTile<MutedWordActorTarget>(
                      title: Text('All accounts'),
                      subtitle: Text('Mute from everyone'),
                      value: MutedWordActorTarget.all,
                      dense: true,
                    ),
                    RadioListTile<MutedWordActorTarget>(
                      title: Text('Exclude following'),
                      subtitle: Text('Don\'t mute from accounts you follow'),
                      value: MutedWordActorTarget.excludeFollowing,
                      dense: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Expiration (optional)', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _expiresAt == null
                      ? 'No expiration'
                      : 'Expires: ${DateFormat.yMMMd().format(_expiresAt!)}',
                ),
                trailing: _expiresAt == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _expiresAt = null),
                      ),
                onTap: _pickExpirationDate,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }

  Future<void> _pickExpirationDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _expiresAt = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_targets.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select at least one target')));
      return;
    }

    final word = MutedWord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      value: _valueController.text.trim(),
      targets: _targets.toList(),
      actorTarget: _actorTarget,
      expiresAt: _expiresAt,
    );

    Navigator.of(context).pop(word);
  }
}
