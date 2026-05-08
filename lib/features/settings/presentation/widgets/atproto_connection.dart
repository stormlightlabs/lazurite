import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/network/atproto_host_resolver.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/settings/presentation/widgets/connection_detail.dart';

class AtProtoConnectionCard extends StatelessWidget {
  const AtProtoConnectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final tokens = authState.tokens;
        if (!authState.isAuthenticated || tokens == null) {
          return const SizedBox.shrink();
        }

        final pds = resolvePdsHost(tokens);
        final theme = Theme.of(context);
        final l10n = context.l10n;
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: theme.dividerColor),
              bottom: BorderSide(color: theme.dividerColor),
            ),
            color: theme.cardColor,
          ),
          child: SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Text(l10n.labelAtProtocolConnection, style: context.textTheme.titleMedium),
                ),
                const Divider(height: 1),
                ConnectionDetailRow(label: 'Handle', value: '@${tokens.handle}'),
                const Divider(height: 1),
                ConnectionDetailRow(
                  label: 'DID',
                  value: tokens.did,
                  onTap: () => context.push('/settings/devtools?query=${Uri.encodeQueryComponent(tokens.did)}'),
                ),
                const Divider(height: 1),
                ConnectionDetailRow(label: 'PDS', value: pds),
              ],
            ),
          ),
        );
      },
    );
  }
}
