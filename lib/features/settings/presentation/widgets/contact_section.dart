import 'package:flutter/material.dart';

class _ContactLink extends StatelessWidget {
  const _ContactLink({required this.pre, required this.label, required this.onTap});

  final String pre;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Text(pre, style: textTheme.bodyMedium),
        const SizedBox(width: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({super.key, required this.onStormlightLabsTap, required this.onEmailTap});

  final VoidCallback onStormlightLabsTap;
  final VoidCallback onEmailTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.primary),
          ),
          const SizedBox(height: 6),
          _ContactLink(pre: 'Visit our website:', label: 'Stormlight Labs', onTap: onStormlightLabsTap),
          const SizedBox(height: 6),
          _ContactLink(pre: 'Email us at', label: 'info@stormlightlabs.org', onTap: onEmailTap),
        ],
      ),
    );
  }
}
