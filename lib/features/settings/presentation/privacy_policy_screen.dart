import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lazurite/features/settings/presentation/widgets/contact_section.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _effectiveDate = 'April 15, 2026';
  static const _websiteUrl = 'https://stormlightlabs.org';
  static const _emailUrl = 'mailto:info@stormlightlabs.org';

  Future<void> _launch(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Lazurite\'s Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/logo.svg',
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Privacy Policy',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Effective $_effectiveDate',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Text(
            'Lazurite is a client for Bluesky. Core app behavior runs from your device, and we do not operate a '
            'developer backend for normal use.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          const _PolicySection(
            title: 'What the app stores on your device',
            paragraphs: [
              'Lazurite stores account session data, settings, cached content, and other app data locally so the app can work quickly and reliably.',
              'This local data can include profile metadata, viewed posts, follows, lists, likes, drafts, and media caches.',
            ],
          ),
          const _PolicySection(
            title: 'How your data is used',
            paragraphs: [
              'Local data is used to keep you signed in, remember your preferences, improve loading performance, and support offline-friendly behavior.',
              'Lazurite does not sell your personal information.',
            ],
          ),
          const _PolicySection(
            title: 'Network requests and third parties',
            paragraphs: [
              'When you use Lazurite, requests are sent directly from your device to Bluesky and related infrastructure.',
              'Your use of Bluesky remains subject to Bluesky policies, terms, and moderation systems.',
            ],
          ),
          const _PolicySection(
            title: 'Permissions',
            paragraphs: [
              'If you choose to save media, Lazurite requests photo or storage permissions required by your platform.',
              'Permissions are used only for the feature you invoke.',
            ],
          ),
          const _PolicySection(
            title: 'Diagnostics and logs',
            paragraphs: [
              'Lazurite keeps local app logs to help troubleshoot issues. These logs stay on your device unless you choose to share them.',
              'Lazurite does not include ad tracking SDKs.',
            ],
          ),
          const _PolicySection(
            title: 'Data retention and control',
            paragraphs: [
              'Data remains on your device until you remove it by signing out, clearing app storage, or uninstalling the app.',
              'Because Lazurite does not run a central app backend for normal use, most data-control actions happen on your device or through Bluesky account settings.',
            ],
          ),
          const _PolicySection(
            title: 'Children',
            paragraphs: [
              'Lazurite is not directed to children under 13, or under the minimum age required in your jurisdiction.',
            ],
          ),
          const _PolicySection(
            title: 'Policy updates',
            paragraphs: [
              'We may revise this policy from time to time. Material updates will be reflected by a new effective date and app release notes when appropriate.',
            ],
          ),
          ContactSection(onStormlightLabsTap: () => _launch(_websiteUrl), onEmailTap: () => _launch(_emailUrl)),
          const SizedBox(height: 12),
          Center(child: Text('Lazurite v1.0.0', style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.primary),
          ),
          const SizedBox(height: 6),
          for (final paragraph in paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(paragraph, style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}
