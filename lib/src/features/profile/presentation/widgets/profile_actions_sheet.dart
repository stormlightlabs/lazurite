import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/app/theme_controller.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/report_dialog.dart';

/// Bottom sheet that exposes profile-level actions such as logout and theming.
class ProfileActionsSheet extends ConsumerWidget {
  const ProfileActionsSheet({required this.did, required this.isCurrentUser, super.key});

  final String did;

  /// Whether the viewer is looking at their own profile.
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final isDarkMode = themeState.themeMode == ThemeMode.dark;
    final profileState = ref.watch(profileProvider(did));
    final profile = profileState.value;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: isDarkMode,
            onChanged: (enabled) {
              ref
                  .read(themeControllerProvider.notifier)
                  .setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          if (isCurrentUser)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () async {
                await Navigator.of(context).maybePop();
                await ref.read(authProvider.notifier).logout();
              },
            )
          else if (profile != null) ...[
            ListTile(
              leading: Icon(profile.viewerMuted ? Icons.volume_up : Icons.volume_off),
              title: Text(profile.viewerMuted ? 'Unmute account' : 'Mute account'),
              onTap: () async {
                await Navigator.of(context).maybePop();
                await ref.read(profileProvider(did).notifier).toggleMute();
              },
            ),
            ListTile(
              leading: Icon(
                profile.viewerBlockingUri != null ? Icons.block : Icons.block_outlined,
              ),
              title: Text(profile.viewerBlockingUri != null ? 'Unblock account' : 'Block account'),
              onTap: () async {
                await Navigator.of(context).maybePop();
                await ref.read(profileProvider(did).notifier).toggleBlock();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Report account'),
              onTap: () async {
                final result = await showDialog<ReportRequest>(
                  context: context,
                  builder: (_) => ReportDialog(actorDid: did),
                );

                if (result != null && context.mounted) {
                  await ref
                      .read(profileProvider(did).notifier)
                      .report(reasonType: result.reasonType, reason: result.reason);

                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Report submitted successfully')));
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
