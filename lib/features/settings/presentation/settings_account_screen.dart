import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/settings/bloc/account_settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/presentation/widgets/account_feed_display_preferences.dart';

class SettingsAccountScreen extends StatelessWidget {
  const SettingsAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providerKey = context.watch<SettingsCubit>().state.appViewProvider;
    final providerName = AppViewProviders.providerDisplayName(providerKey);
    return BlocProvider(
      create: (context) => AccountSettingsCubit(
        feedRepository: context.read<FeedRepository>(),
        feed: homeFeedPreferenceId,
        feedDisplayName: 'Following',
        supportsBlackskyAiPreferences: providerKey == AppViewProviders.blackskyKey,
      )..loadPreferences(),
      child: Scaffold(
        appBar: AppBar(title: Text('$providerName settings')),
        body: AccountFeedDisplayPreferences(providerDisplayName: providerName),
      ),
    );
  }
}
