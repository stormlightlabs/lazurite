import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/ads/cubit/ad_cubit.dart';
import 'package:lazurite/features/ads/cubit/ad_state.dart';
import 'package:lazurite/features/ads/presentation/ad_post_card.dart';

class AdSlot extends StatefulWidget {
  const AdSlot({required this.slotIndex, this.isLinear = false, super.key});

  final int slotIndex;
  final bool isLinear;

  @override
  State<AdSlot> createState() => _AdSlotState();
}

class _AdSlotState extends State<AdSlot> {
  late final AdCubit _adCubit;

  @override
  void initState() {
    super.initState();
    _adCubit = context.read<AdCubit>();
    _requestAd();
  }

  @override
  void didUpdateWidget(covariant AdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slotIndex != widget.slotIndex) {
      _requestAd();
    }
  }

  @override
  void dispose() {
    _adCubit.disposeAd(widget.slotIndex);
    super.dispose();
  }

  void _requestAd() {
    if (_adCubit.state.adsRemoved) {
      return;
    }
    unawaited(_adCubit.loadAdSlot(widget.slotIndex));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdCubit, AdState>(
      buildWhen: (previous, current) =>
          previous.adsRemoved != current.adsRemoved ||
          previous.loadedAds[widget.slotIndex] != current.loadedAds[widget.slotIndex],
      builder: (context, state) {
        if (state.adsRemoved) {
          return const SizedBox.shrink();
        }

        final ad = state.loadedAds[widget.slotIndex];
        if (ad == null) {
          return const SizedBox.shrink();
        }

        return AdPostCard(isLinear: widget.isLinear, child: ad.buildWidget());
      },
    );
  }
}
