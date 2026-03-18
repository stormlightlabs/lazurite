import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppShellMenuButton(),
        title: _title(context),
        actions: [
          IconButton(
            tooltip: 'Log Out',
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
      body: ListView(
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final tokens = state.tokens;
              if (!state.isAuthenticated || tokens == null) {
                return const SizedBox.shrink();
              }

              return ListTile(
                leading: CircleAvatar(child: Text((tokens.displayName ?? tokens.handle).substring(0, 1).toUpperCase())),
                title: Text(tokens.displayName ?? tokens.handle),
                subtitle: Text('@${tokens.handle}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/profile'),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeSelector(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Account'),
          _SettingsTile(
            icon: Icons.dynamic_feed_outlined,
            title: 'Feeds',
            subtitle: 'Manage pinned and saved feeds',
            onTap: () => context.push('/feeds'),
          ),
          _SettingsTile(
            icon: Icons.bookmark_outline,
            title: 'Saved Posts',
            subtitle: 'View your saved posts',
            onTap: () => context.push('/saved'),
          ),
          _SettingsTile(icon: Icons.person_outline, title: 'Edit Profile', subtitle: 'Name, bio, avatar', onTap: () {}),
          _SettingsTile(icon: Icons.lock_outline, title: 'Privacy', subtitle: 'Visibility settings', onTap: () {}),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Notifications'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          _SettingsTile(
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          _SettingsTile(
            icon: Icons.code_outlined,
            title: 'Dev Tools',
            subtitle: 'PDS Explorer',
            onTap: () => context.push('/settings/devtools'),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Logs',
            subtitle: 'View app log files',
            onTap: () => context.push('/settings/logs'),
          ),
          _SettingsTile(icon: Icons.help_outline, title: 'Help & Support', onTap: () {}),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Stormlight Labs',
            onTap: () => context.push('/settings/about'),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Danger Zone'),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Log Out',
            isDestructive: true,
            onTap: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          ),
          const SizedBox(height: 24),
          Center(child: Text('Lazurite v1.0.0', style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  Widget _title(BuildContext context) => Text('Settings', style: Theme.of(context).textTheme.titleLarge);

  Widget _buildThemeSelector(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<_AppearanceMode>(
                      segments: const [
                        ButtonSegment(value: _AppearanceMode.system, label: Text('System')),
                        ButtonSegment(value: _AppearanceMode.light, label: Text('Light')),
                        ButtonSegment(value: _AppearanceMode.dark, label: Text('Dark')),
                      ],
                      selected: {_AppearanceMode.fromState(state)},
                      onSelectionChanged: (selected) {
                        final mode = selected.first;
                        switch (mode) {
                          case _AppearanceMode.system:
                            settingsCubit.setUseSystemTheme(true);
                          case _AppearanceMode.light:
                            settingsCubit.setUseSystemTheme(false);
                            settingsCubit.setThemeVariant(AppThemeVariant.light);
                          case _AppearanceMode.dark:
                            settingsCubit.setUseSystemTheme(false);
                            settingsCubit.setThemeVariant(AppThemeVariant.dark);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'THEME',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                ),
              ),
              for (final palette in AppThemePalette.values)
                _ThemePaletteRow(
                  palette: palette,
                  isSelected: state.themePalette == palette,
                  onTap: () => settingsCubit.setThemePalette(palette),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

enum _AppearanceMode {
  system,
  light,
  dark;

  static _AppearanceMode fromState(SettingsState state) {
    if (state.useSystemTheme) return system;
    return state.themeVariant == AppThemeVariant.light ? light : dark;
  }
}

class _ThemePaletteRow extends StatelessWidget {
  const _ThemePaletteRow({required this.palette, required this.isSelected, required this.onTap});

  final AppThemePalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final swatches = AppTheme.getSwatchColors(palette);

    return ListTile(
      onTap: onTap,
      title: Text(AppTheme.getPaletteName(palette)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final color in swatches)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
              ),
            ),
          if (isSelected) ...[
            const SizedBox(width: 12),
            Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 20),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.isDestructive = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Theme.of(context).colorScheme.error : null;

    return ListTile(
      leading: icon != null ? Icon(icon, color: color) : null,
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
