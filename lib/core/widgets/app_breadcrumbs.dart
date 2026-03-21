import 'package:flutter/material.dart';

class AppBreadcrumbItem {
  const AppBreadcrumbItem({required this.label, this.onTap, this.tooltip, this.key});

  final String label;
  final VoidCallback? onTap;
  final String? tooltip;
  final Key? key;

  bool get isCurrent => onTap == null;
}

class AppBreadcrumbs extends StatelessWidget {
  const AppBreadcrumbs({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.isLoading = false,
  });

  final List<AppBreadcrumbItem> items;
  final EdgeInsetsGeometry padding;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: padding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    children: [
                      for (var index = 0; index < items.length; index++) ...[
                        _BreadcrumbChip(item: items[index]),
                        if (index != items.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurfaceVariant),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isLoading
                ? const LinearProgressIndicator(key: ValueKey('app-breadcrumbs-loading'), minHeight: 2)
                : const SizedBox(key: ValueKey('app-breadcrumbs-idle'), height: 2),
          ),
        ],
      ),
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  const _BreadcrumbChip({required this.item});

  final AppBreadcrumbItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent = item.isCurrent;
    final backgroundColor = isCurrent ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest;
    final foregroundColor = isCurrent ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant;

    final chipChild = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          item.label,
          key: item.key,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(color: foregroundColor, fontWeight: FontWeight.w600),
        ),
      ),
    );

    final chip = Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(onTap: item.onTap, borderRadius: BorderRadius.circular(999), child: chipChild),
    );

    if ((item.tooltip ?? item.label).isEmpty) {
      return chip;
    }

    return Tooltip(message: item.tooltip ?? item.label, child: chip);
  }
}
