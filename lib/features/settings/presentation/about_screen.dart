import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lazurite/core/app/app_version.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _linkedInUrl = 'https://linkedin.com/in/owais-jamil';
  static const _githubUrl = 'https://github.com/stormlightlabs/lazurite';
  static const _tangledUrl = 'https://tangled.org/desertthunder.dev/lazurite';
  static const _emailUrl = 'mailto:info@stormlightlabs.org';

  Future<void> _launch(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/logo.svg',
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Lazurite',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Text('Lazurite is made at Stormlight Labs, which is just me:', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _launch(_linkedInUrl),
            child: Text(
              'Owais',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Stormlight Labs makes high quality, free and open source software. '
            'Check out our other projects on GitHub.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'You can view or contribute to this project on Tangled or GitHub. '
            'Feature requests and bug reports are welcome!',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LinkIcon(
                onTap: () => _launch(_githubUrl),
                child: SvgPicture.asset(
                  'assets/gh.svg',
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(theme.colorScheme.onSurface, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 24),
              _LinkIcon(
                onTap: () => _launch(_tangledUrl),
                child: SvgPicture.asset(
                  'assets/tangled.svg',
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(theme.colorScheme.onSurface, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 24),
              _LinkIcon(
                onTap: () => _launch(_emailUrl),
                child: Icon(Icons.email_outlined, size: 28, color: theme.colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Center(child: _AppVersionLabel()),
        ],
      ),
    );
  }
}

class _AppVersionLabel extends StatefulWidget {
  const _AppVersionLabel();

  @override
  State<_AppVersionLabel> createState() => _AppVersionLabelState();
}

class _AppVersionLabelState extends State<_AppVersionLabel> {
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
        return Text(label, style: Theme.of(context).textTheme.bodySmall);
      },
    );
  }
}

class _LinkIcon extends StatelessWidget {
  const _LinkIcon({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.all(8), child: child),
    );
  }
}
