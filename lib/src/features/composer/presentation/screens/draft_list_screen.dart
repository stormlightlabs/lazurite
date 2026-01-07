import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/draft_preview_card.dart';

class DraftListScreen extends ConsumerWidget {
  const DraftListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftsAsync = ref.watch(draftsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Drafts'),
            pinned: true,
            actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.delete_sweep_outlined))],
          ),
          draftsAsync.when(
            data: (drafts) {
              if (drafts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.drafts_outlined,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No drafts yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final sortedDrafts = [...drafts]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

              return SliverList.builder(
                itemCount: sortedDrafts.length,
                itemBuilder: (context, index) {
                  final draft = sortedDrafts[index];
                  return Dismissible(
                    key: ValueKey(draft.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: colorScheme.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
                    ),
                    confirmDismiss: (direction) async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Draft?'),
                          content: const Text(
                            'This action cannot be undone. Are you sure you want to delete this draft?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      return confirm ?? false;
                    },
                    onDismissed: (direction) {
                      ref.read(draftRepositoryProvider).deleteDraft(draft.id);
                    },
                    child: DraftPreviewCard(
                      draft: draft,
                      onTap: () {
                        context.push('/compose?draftId=${draft.id}');
                      },
                    ),
                  );
                },
              );
            },
            loading: () =>
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (error, stack) =>
                SliverFillRemaining(child: Center(child: Text('Error: $error'))),
          ),
        ],
      ),
    );
  }
}
