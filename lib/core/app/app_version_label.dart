import 'package:flutter/material.dart';
import 'package:lazurite/core/app/app_version.dart';

class AppVersionLabel extends StatefulWidget {
  const AppVersionLabel({super.key, this.textAlign});

  final TextAlign? textAlign;

  @override
  State<AppVersionLabel> createState() => _AppVersionLabelState();
}

class _AppVersionLabelState extends State<AppVersionLabel> {
  late final Future<String> _displayLabel = AppVersion.displayLabel();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _displayLabel,
      builder: (context, snapshot) {
        final label = snapshot.data;
        if (label == null) {
          return const SizedBox.shrink();
        }
        return Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: widget.textAlign);
      },
    );
  }
}
