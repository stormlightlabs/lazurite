import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lazurite/core/app/app_version_label.dart';
import 'package:lazurite/features/settings/presentation/widgets/contact_section.dart';
import 'package:lazurite/shared/utils/url_utils.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const _effectiveDate = 'April 15, 2026';
  static const _websiteUrl = 'https://stormlightlabs.org';
  static const _emailUrl = 'mailto:info@stormlightlabs.org';
  static const _blueskyPrivacyUrl = 'https://bsky.social/about/support/privacy-policy';
  static const _blueskyTermsUrl = 'https://bsky.social/about/support/tos';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Lazurite\'s Terms of Service')),
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
            'Terms of Service',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Effective $_effectiveDate',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Text(
            'These Terms govern your use of Lazurite, a Bluesky client built by Stormlight Labs. '
            'By installing or using Lazurite, you agree to these Terms.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          const _TermsSection(
            title: 'What Lazurite is',
            paragraphs: [
              'Lazurite is client software that helps you access Bluesky from your device.',
              'Lazurite does not provide the Bluesky network itself.',
            ],
          ),
          const _TermsSection(
            title: 'Eligibility',
            paragraphs: [
              'You must be legally able to agree to these Terms and meet the minimum age requirement in your jurisdiction.',
            ],
          ),
          const _TermsSection(
            title: 'License',
            paragraphs: [
              'We grant you a limited, non-exclusive, non-transferable, revocable license to use Lazurite on devices you control.',
              'You may not misuse the app, break applicable law, or attempt unauthorized access to systems or accounts.',
            ],
          ),
          const _TermsSection(
            title: 'Bluesky terms and policies',
            paragraphs: [
              'Lazurite depends on Bluesky services, and your use of Bluesky is governed by Bluesky\'s own legal terms.',
            ],
          ),
          _PolicyLinks(
            onPrivacyTap: () => openExternalUrl(_blueskyPrivacyUrl),
            onTermsTap: () => openExternalUrl(_blueskyTermsUrl),
          ),
          const _TermsSection(
            title: 'Your account and activity',
            paragraphs: [
              'You are responsible for your Bluesky account, credentials, and activity taken through Lazurite.',
              'You retain rights to your content, subject to Bluesky policies and any third-party rights.',
            ],
          ),
          const _TermsSection(
            title: 'Acceptable use',
            paragraphs: [
              'Do not use Lazurite to harass others, violate rights, distribute unlawful content, or abuse platform infrastructure.',
              'You are responsible for complying with Bluesky rules and applicable law.',
            ],
          ),
          const _TermsSection(
            title: 'Third-party dependencies',
            paragraphs: [
              'Lazurite depends on Bluesky and related third-party services.',
              'If those services change, restrict, or discontinue access, features may degrade or stop working.',
            ],
          ),
          const _TermsSection(
            title: 'No warranty',
            paragraphs: [
              'Lazurite is provided "as is" and "as available." We do not guarantee uninterrupted, secure, or error-free operation.',
            ],
          ),
          const _TermsSection(
            title: 'Liability',
            paragraphs: [
              'To the maximum extent permitted by law, Stormlight Labs is not liable for indirect, incidental, or consequential damages arising from your use of Lazurite.',
            ],
          ),
          const _TermsSection(
            title: 'Changes and termination',
            paragraphs: [
              'We may update, suspend, or discontinue parts of Lazurite.',
              'We may update these Terms. Continued use after updates means you accept the revised Terms.',
            ],
          ),
          ContactSection(
            onStormlightLabsTap: () => openExternalUrl(_websiteUrl),
            onEmailTap: () => openExternalUrl(_emailUrl),
          ),
          const SizedBox(height: 12),
          const Center(child: AppVersionLabel()),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;

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
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.primary),
          ),
          const SizedBox(height: 6),
          ...paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(paragraph, style: textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyLinks extends StatelessWidget {
  const _PolicyLinks({required this.onPrivacyTap, required this.onTermsTap});

  final VoidCallback onPrivacyTap;
  final VoidCallback onTermsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: onPrivacyTap,
            icon: const Icon(Icons.privacy_tip_outlined),
            label: const Text('Bluesky Privacy Policy'),
          ),
          OutlinedButton.icon(
            onPressed: onTermsTap,
            icon: const Icon(Icons.description_outlined),
            label: const Text('Bluesky Terms of Service'),
          ),
        ],
      ),
    );
  }
}
