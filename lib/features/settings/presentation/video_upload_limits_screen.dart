import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/settings/cubit/video_upload_limits_cubit.dart';
import 'package:lazurite/features/settings/data/video_repository.dart';

class VideoUploadLimitsScreen extends StatefulWidget {
  const VideoUploadLimitsScreen({super.key});

  @override
  State<VideoUploadLimitsScreen> createState() => _VideoUploadLimitsScreenState();
}

class _VideoUploadLimitsScreenState extends State<VideoUploadLimitsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VideoUploadLimitsCubit>().fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Upload Limits')),
      body: BlocBuilder<VideoUploadLimitsCubit, VideoUploadLimitsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_outlined, size: 48, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'Failed to load video upload limits',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ),
              ),
            );
          }

          final limits = state.limits;
          if (limits == null) {
            return const SizedBox.shrink();
          }

          return _VideoUploadLimitsBody(limits: limits);
        },
      ),
    );
  }
}

class _VideoUploadLimitsBody extends StatelessWidget {
  const _VideoUploadLimitsBody({required this.limits});

  final VideoUploadLimits limits;

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      final gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(2)} GB';
    }
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canUploadColor = limits.canUpload ? theme.colorScheme.primary : theme.colorScheme.error;
    final canUploadLabel = limits.canUpload ? 'Uploads enabled' : 'Uploads disabled';
    final canUploadIcon = limits.canUpload ? Icons.check_circle_outline : Icons.cancel_outlined;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(canUploadIcon, color: canUploadColor),
            const SizedBox(width: 8),
            Text(canUploadLabel, style: theme.textTheme.titleMedium?.copyWith(color: canUploadColor)),
          ],
        ),
        const SizedBox(height: 24),
        if (limits.remainingDailyVideos != null) ...[
          _LimitRow(label: 'Remaining videos today', value: '${limits.remainingDailyVideos}'),
          const Divider(),
        ],
        if (limits.remainingDailyBytes != null) ...[
          _LimitRow(label: 'Remaining storage today', value: _formatBytes(limits.remainingDailyBytes!)),
          const Divider(),
        ],
        if (limits.message != null) ...[
          const SizedBox(height: 8),
          Text(limits.message!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
        ],
        if (limits.error != null) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_outlined, color: theme.colorScheme.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(limits.error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
