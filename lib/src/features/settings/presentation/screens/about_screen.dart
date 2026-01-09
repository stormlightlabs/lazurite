import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/settings_section.dart';

/// About screen displaying app information, links, credits, and legal.
///
/// Shows app version with tap-to-copy functionality, external links to
/// project resources, credits for inspirations and frameworks, and stubs
/// for legal documents.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appName = 'Lazurite';
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildHeader(context),
          const Divider(),
          _buildLinksSection(context),
          const Divider(),
          _buildCreditsSection(context),
          const Divider(),
          _buildLegalSection(context),
          const Divider(),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    const versionText = '$version (Build $buildNumber)';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/logo.svg',
            width: 80,
            height: 80,
            colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
          ),
          const SizedBox(height: 16),
          Text(
            appName,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _copyVersionToClipboard(context, versionText),
            child: Text(
              versionText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap version to copy',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSection(title: 'Links'),
        _buildLinkTile(
          context,
          icon: Icons.language_outlined,
          title: 'Website',
          url: 'https://lazurite.stormlightlabs.org',
        ),
        _buildLinkTile(
          context,
          icon: Icons.code_outlined,
          title: 'GitHub Repository',
          url: 'https://github.com/stormlightlabs/lazurite',
        ),
        _buildLinkTile(
          context,
          icon: Icons.article_outlined,
          title: 'Tangled Project',
          url: 'https://tangled.org/desertthunder.dev/lazurite',
        ),
        _buildLinkTile(
          context,
          icon: Icons.bug_report_outlined,
          title: 'Report Issues',
          url: 'https://tangled.org/desertthunder.dev/lazurite/issues',
        ),
      ],
    );
  }

  Widget _buildCreditsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSection(title: 'Credits'),
        ListTile(
          leading: const Icon(Icons.cloud_outlined),
          title: const Text('Powered by Bluesky'),
          subtitle: const Text('AT Protocol social network'),
          onTap: () => _launchUrl(context, 'https://bsky.app'),
        ),
        ListTile(
          leading: const Icon(Icons.flutter_dash_outlined),
          title: const Text('Built with Flutter'),
          subtitle: const Text('Cross-platform UI framework'),
          onTap: () => _launchUrl(context, 'https://flutter.dev'),
        ),
        const ListTile(
          leading: Icon(Icons.palette_outlined),
          title: Text('Typography inspiration'),
          subtitle: Text('Anisota by Dame.is (@dame.is)'),
        ),
        const ListTile(
          leading: Icon(Icons.favorite_outline),
          title: Text('Community reference'),
          subtitle: Text('Witchsky by jollywhoppers.com'),
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSection(title: 'Legal'),
        ListTile(
          leading: const Icon(Icons.gavel_outlined),
          title: const Text('Open Source Licenses'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showComingSoon(context, 'Open Source Licenses'),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showComingSoon(context, 'Privacy Policy'),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showComingSoon(context, 'Terms of Service'),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            '© 2026 Stormlight Labs',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            'Material You Bluesky Client',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String url,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => _launchUrl(context, url),
    );
  }

  void _copyVersionToClipboard(BuildContext context, String versionText) {
    Clipboard.setData(ClipboardData(text: versionText));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Version copied to clipboard')));
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature - Coming soon')));
  }
}
