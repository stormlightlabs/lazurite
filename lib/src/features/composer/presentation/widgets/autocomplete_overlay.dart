import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';
import 'package:lazurite/src/features/composer/application/autocomplete_provider.dart'
    show autocompleteProvider;
import 'package:lazurite/src/features/composer/application/autocomplete_provider.dart' as app;

const double kAutocompleteMaxHeight = 200;
const int kMaxSuggestions = 5;

class AutocompleteOverlay extends ConsumerWidget {
  const AutocompleteOverlay({
    required this.text,
    required this.onSuggestionSelected,
    required this.visible,
    this.offset,
    super.key,
  });

  final String text;
  final void Function(app.AutocompleteSuggestion suggestion) onSuggestionSelected;
  final bool visible;
  final Offset? offset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!visible) {
      return const SizedBox.shrink();
    }

    final suggestionsAsync = ref.watch(autocompleteProvider);

    return suggestionsAsync.when(
      data: (suggestions) {
        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        final displaySuggestions = suggestions.take(kMaxSuggestions).toList();

        return Positioned(
          left: offset?.dx ?? 0,
          top: offset?.dy ?? 0,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: kAutocompleteMaxHeight),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: displaySuggestions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 8,
                    color: colorScheme.outlineVariant,
                  ),
                  itemBuilder: (context, index) {
                    final suggestion = displaySuggestions[index];
                    return AutocompleteSuggestionTile(
                      suggestion: suggestion,
                      onTap: () => onSuggestionSelected(suggestion),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      loading: () {
        return Positioned(
          left: offset?.dx ?? 0,
          top: offset?.dy ?? 0,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline),
              ),
              padding: const EdgeInsets.all(16),
              child: const SizedBox(
                width: 200,
                height: 40,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
          ),
        );
      },
      error: (_, err) => const SizedBox.shrink(),
    );
  }
}

class AutocompleteSuggestionTile extends StatelessWidget {
  const AutocompleteSuggestionTile({required this.suggestion, required this.onTap, super.key});

  final app.AutocompleteSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (suggestion.type) {
      case app.AutocompleteType.mention:
        return _buildMentionTile(theme, colorScheme);
      case app.AutocompleteType.hashtag:
        return _buildHashtagTile(theme, colorScheme);
    }
  }

  Widget _buildMentionTile(ThemeData theme, ColorScheme colorScheme) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Avatar(imageUrl: suggestion.avatar, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    suggestion.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (suggestion.handle != null)
                    Text(
                      '@${suggestion.handle}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashtagTile(ThemeData theme, ColorScheme colorScheme) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.tag, size: 20, color: colorScheme.onSecondaryContainer),
            ),
            const SizedBox(width: 12),
            Text(
              '#${suggestion.label}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
