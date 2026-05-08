import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_router.dart';
import 'package:lazurite/core/widgets/lazurite_app_bar.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/data/trending_join.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';
import 'package:url_launcher/url_launcher.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  TrendingScreenData? _data;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await context.read<FeedRepository>().getTrendingScreenData(limit: 10);
      if (!mounted) {
        return;
      }

      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _onTapTopic(EnrichedTrendingTopic topic) async {
    final providerSetting = context.read<SettingsCubit>().state.appViewProvider;
    final provider = AppViewProviders.descriptorForSetting(providerSetting);
    final router = AppViewRouter(provider: provider);
    final resolution = router.resolveTrendLink(topic.topic.link);

    if (resolution.inAppRoute != null) {
      await context.push(resolution.inAppRoute!);
      return;
    }

    await launchUrl(resolution.externalUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LazuriteAppBar(sectionLabel: context.l10n.labelTrending),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return LoadingState(message: context.l10n.messageLoadingTrendingTopics);
    }

    final error = _error;
    if (error != null) {
      return ErrorState(
        title: context.l10n.errorFailedToLoadTrending,
        message: context.l10n.errorFailedToLoadTrendingTopics(error),
        onRetry: _load,
      );
    }

    final data = _data;
    if (data == null || data.isEmpty) {
      return EmptyState(icon: Icons.trending_up_outlined, message: context.l10n.messageNoTrendingTopicsRightNow);
    }

    final rows = <Widget>[
      if (data.metadataUnavailable)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(context.l10n.messageMetadataTemporarilyUnavailable),
          ),
        ),
      _SectionHeader(title: context.l10n.labelTopics),
      ...data.topics.map((item) => _TrendTile(item: item, onTap: () => _onTapTopic(item))),
      if (data.suggested.isNotEmpty) _SectionHeader(title: context.l10n.labelSuggested),
      ...data.suggested.map((item) => _TrendTile(item: item, onTap: () => _onTapTopic(item))),
      const SizedBox(height: 16),
    ];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(children: rows),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

class _TrendTile extends StatelessWidget {
  const _TrendTile({required this.item, required this.onTap});

  final EnrichedTrendingTopic item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final trend = item.trend;
    final subtitleLines = <String>[];
    final description = item.topic.description?.trim();
    if (description != null && description.isNotEmpty) {
      subtitleLines.add(description);
    }
    if (trend != null) {
      subtitleLines.add(context.l10n.formatTrendingPostCount(trend.postCount));
      if (trend.category != null && trend.category!.trim().isNotEmpty) {
        subtitleLines.add(context.l10n.formatTrendingCategory(trend.category!));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        child: ListTile(
          onTap: onTap,
          title: Text(item.topic.displayName?.trim().isNotEmpty == true ? item.topic.displayName! : item.topic.topic),
          subtitle: subtitleLines.isEmpty ? null : Text(subtitleLines.join(' · ')),
          trailing: const Icon(Icons.open_in_new),
        ),
      ),
    );
  }
}
