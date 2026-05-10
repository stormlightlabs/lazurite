import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/connectivity/connectivity_helpers.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';

class FollowButton extends StatefulWidget {
  const FollowButton({super.key, required this.actor});

  final ProfileView actor;

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.actor.viewer?.following != null;
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);
    if (_isFollowing) {
      final button = OutlinedButton(
        onPressed: isOffline ? null : _toggleFollow,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: const Text('Following'),
      );

      return isOffline ? Tooltip(message: offlineActionMessage('change your follow state'), child: button) : button;
    }

    final button = FilledButton.tonal(
      onPressed: isOffline ? null : _toggleFollow,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: const Text('Follow'),
    );

    return isOffline ? Tooltip(message: offlineActionMessage('follow this account'), child: button) : button;
  }

  void _toggleFollow() {
    setState(() => _isFollowing = !_isFollowing);
  }
}
