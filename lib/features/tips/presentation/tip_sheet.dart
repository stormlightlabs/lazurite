import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/tips/cubit/tip_cubit.dart';
import 'package:lazurite/features/tips/cubit/tip_state.dart';
import 'package:lazurite/features/tips/data/purchase_repository.dart';

/// Opens the [TipSheet] as a modal bottom sheet.
void showTipSheet(BuildContext context) {
  final purchaseRepo = context.read<PurchaseRepository>();
  final settingsCubit = context.read<SettingsCubit>();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider(
      create: (_) => TipCubit(purchaseRepository: purchaseRepo, settingsCubit: settingsCubit)..loadProducts(),
      child: const TipSheet(),
    ),
  );
}

/// Modal bottom sheet for in-app tip purchases.
class TipSheet extends StatelessWidget {
  const TipSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: BlocBuilder<TipCubit, TipState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                if (state.adsRemoved) _buildAdsRemovedBanner(context),
                _buildContent(context, state),
                if (!state.adsRemoved) ...[const SizedBox(height: 12), _buildAdsNote(context)],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.favorite, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Text('Support Lazurite', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _buildAdsRemovedBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ads removed — thanks for your support!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, TipState state) {
    return switch (state.storeStatus) {
      TipStoreStatus.loading => _buildSkeleton(),
      TipStoreStatus.unavailable => _buildUnavailable(context),
      TipStoreStatus.available => _buildProducts(context, state),
    };
  }

  Widget _buildSkeleton() {
    return const Column(
      children: [
        _SkeletonTile(key: Key('tip_skeleton_0')),
        SizedBox(height: 8),
        _SkeletonTile(key: Key('tip_skeleton_1')),
      ],
    );
  }

  Widget _buildUnavailable(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.store_outlined, size: 48),
        const SizedBox(height: 8),
        Text('Store unavailable', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Please check your connection and try again.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: () => context.read<TipCubit>().loadProducts(), child: const Text('Retry')),
      ],
    );
  }

  /// Builds the canonical list: coffee first, latte second.
  Widget _buildProducts(BuildContext context, TipState state) {
    final isPending = state.purchaseStatus == TipPurchaseStatus.pending;

    final ordered = <(String emoji, ProductDetails product)>[];
    ProductDetails? coffee;
    ProductDetails? latte;
    for (final p in state.products) {
      if (p.id == PurchaseRepository.coffeeProductId) coffee = p;
      if (p.id == PurchaseRepository.latteProductId) latte = p;
    }
    if (coffee != null) ordered.add(('☕', coffee));
    if (latte != null) ordered.add(('☕☕', latte));

    if (ordered.isEmpty) {
      return Center(child: Text('No products available', style: Theme.of(context).textTheme.bodyMedium));
    }

    return Column(
      children: [
        for (final (emoji, product) in ordered) ...[
          _TipProductTile(
            emoji: emoji,
            product: product,
            isPending: isPending,
            onTap: isPending ? null : () => context.read<TipCubit>().purchaseTip(product),
          ),
          const SizedBox(height: 8),
        ],
        if (state.purchaseStatus == TipPurchaseStatus.error && state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              state.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  Widget _buildAdsNote(BuildContext context) {
    return Text(
      'Your first tip removes ads forever.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class _TipProductTile extends StatelessWidget {
  const _TipProductTile({required this.emoji, required this.product, required this.isPending, required this.onTap});

  final String emoji;
  final ProductDetails product;
  final bool isPending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(product.title),
      subtitle: Text(product.description),
      trailing: isPending
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : FilledButton(onPressed: onTap, child: Text(product.price)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Row(
      children: [
        Container(width: 40, height: 40, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 120, height: 14, color: color),
              const SizedBox(height: 6),
              Container(width: 80, height: 12, color: color),
            ],
          ),
        ),
        Container(width: 60, height: 32, color: color),
      ],
    );
  }
}
