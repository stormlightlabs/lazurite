import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/settings/bloc/account_settings_cubit.dart';
import 'package:lazurite/features/settings/presentation/widgets/account_feed_display_preferences.dart';

class SettingsAccountScreen extends StatelessWidget {
  const SettingsAccountScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => AccountSettingsCubit(
      feedRepository: context.read<FeedRepository>(),
      feed: homeFeedPreferenceId,
      feedDisplayName: 'Following',
    )..loadPreferences(),
    child: Scaffold(
      appBar: AppBar(title: const Text('Account settings')),
      body: const AccountFeedDisplayPreferences(),
    ),
  );
}
