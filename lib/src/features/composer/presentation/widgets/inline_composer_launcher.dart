import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/avatar.dart';

class InlineComposerLauncher extends StatelessWidget {
  const InlineComposerLauncher({super.key, required this.avatarUrl, this.onTap});

  final String avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Avatar(imageUrl: avatarUrl, radius: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "What's up?",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
