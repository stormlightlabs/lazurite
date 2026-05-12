import 'package:flutter/material.dart';
import 'package:lazurite/core/app/app_version.dart';

class AppVersionLabel extends StatefulWidget {
  const AppVersionLabel({super.key, this.textAlign, this.loadDisplayLabel});

  static const placeholderLabel = 'App version';
  static const errorLabel = 'Version unavailable';

  final TextAlign? textAlign;
  final Future<String> Function()? loadDisplayLabel;

  @override
  State<AppVersionLabel> createState() => _AppVersionLabelState();
}

class _AppVersionLabelState extends State<AppVersionLabel> {
  late final Future<String> _displayLabel = (widget.loadDisplayLabel ?? AppVersion.displayLabel)();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<String>(
      future: _displayLabel,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Tooltip(
            message: 'Unable to load app version',
            child: Text(
              AppVersionLabel.errorLabel,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              textAlign: widget.textAlign,
            ),
          );
        }

        final label = snapshot.data;
        return Text(
          label == null || label.isEmpty ? AppVersionLabel.placeholderLabel : label,
          style: theme.textTheme.bodySmall,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}
