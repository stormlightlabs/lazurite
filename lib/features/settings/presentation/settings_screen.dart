import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              context.go('/login');
            },
            child: Text('Log Out', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
          _SettingsTile(icon: Icons.code_outlined, title: 'Dev Tools', subtitle: 'PDS Explorer', onTap: () {}),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Logs',
            subtitle: 'View app log files',
            onTap: () => context.push('/settings/logs'),
          ),
          _SettingsTile(icon: Icons.help_outline, title: 'Help & Support', onTap: () {}),
          _SettingsTile(icon: Icons.security_outlined, title: 'Privacy Policy', onTap: () {}),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Danger Zone'),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Log Out',
            isDestructive: true,
            onTap: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              context.go('/login');
            },
          ),
          const SizedBox(height: 24),
          Center(child: Text('Lazurite v1.0.0 (Phase 2)', style: Theme.of(context).textTheme.bodySmall)),
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

  Widget _buildThemeSelector(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();

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
          Padding(padding: const EdgeInsets.all(16), child: _buildThemeGrid(context, settingsCubit)),
          const Divider(height: 1),
          BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (prev, curr) => prev.useSystemTheme != curr.useSystemTheme,
            builder: (context, state) {
              return _SettingsTile(
                title: 'Auto',
                subtitle: 'Follow system theme',
                trailing: Switch(
                  value: state.useSystemTheme,
                  onChanged: (value) => settingsCubit.setUseSystemTheme(value),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeGrid(BuildContext context, SettingsCubit settingsCubit) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildThemeRow(context, settingsCubit, 'Oxocarbon', AppThemePalette.oxocarbon, state),
            const SizedBox(height: 16),
            _buildThemeRow(context, settingsCubit, 'Catppuccin', AppThemePalette.catppuccin, state),
            const SizedBox(height: 16),
            _buildThemeRow(context, settingsCubit, 'Nord', AppThemePalette.nord, state),
            const SizedBox(height: 16),
            _buildThemeRow(context, settingsCubit, 'Rosé Pine', AppThemePalette.rosePine, state),
          ],
        );
      },
    );
  }

  Widget _buildThemeRow(
    BuildContext context,
    SettingsCubit settingsCubit,
    String label,
    AppThemePalette palette,
    SettingsState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ThemeOption(
                palette: palette,
                variant: AppThemeVariant.light,
                label: 'Light',
                isSelected: state.themePalette == palette && state.themeVariant == AppThemeVariant.light,
                onTap: () => settingsCubit.setTheme(palette, AppThemeVariant.light),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ThemeOption(
                palette: palette,
                variant: AppThemeVariant.dark,
                label: 'Dark',
                isSelected: state.themePalette == palette && state.themeVariant == AppThemeVariant.dark,
                onTap: () => settingsCubit.setTheme(palette, AppThemeVariant.dark),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.palette,
    required this.variant,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemePalette palette;
  final AppThemeVariant variant;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(palette, variant);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
                color: theme.scaffoldBackgroundColor,
              ),
              child: Stack(
                children: [
                  if (isSelected)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                        child: Icon(Icons.check, size: 12, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
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
