import 'dart:async';

import 'package:flutter/material.dart';

class OptionsSheetItem {
  const OptionsSheetItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.isDestructive = false,
    this.enabled = true,
    this.dismissOnTap = true,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool isDestructive;
  final bool enabled;
  final bool dismissOnTap;
  final FutureOr<void> Function()? onTap;
}

class OptionsSheet extends StatelessWidget {
  const OptionsSheet({super.key, required this.items, this.header});

  final Widget? header;
  final List<OptionsSheetItem> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?header,
          for (final item in items)
            ListTile(
              enabled: item.enabled,
              leading: item.leading,
              trailing: item.trailing,
              title: Text(item.title, style: item.isDestructive ? TextStyle(color: colorScheme.error) : null),
              subtitle: item.subtitle == null ? null : Text(item.subtitle!),
              onTap: item.onTap == null
                  ? null
                  : () {
                      if (item.dismissOnTap) {
                        Navigator.of(context).pop();
                      }
                      final result = item.onTap!.call();
                      if (result is Future) {
                        unawaited(result.then((_) {}));
                      }
                    },
            ),
        ],
      ),
    );
  }
}

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(context: context, isScrollControlled: isScrollControlled, builder: builder);
}

Future<T?> showOptionsSheet<T>({
  required BuildContext context,
  required List<OptionsSheetItem> items,
  Widget? header,
  bool isScrollControlled = false,
}) {
  return showAppBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    builder: (_) => OptionsSheet(items: items, header: header),
  );
}
