import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';

class MessageUnreadCountCubit extends Cubit<MessageUnreadCountState> {
  MessageUnreadCountCubit({required ConvoRepository convoRepository})
    : _convoRepository = convoRepository,
      super(const MessageUnreadCountState(0)) {
    _startPolling();
  }

  final ConvoRepository _convoRepository;
  Timer? _pollingTimer;

  static const _pollingInterval = Duration(seconds: 30);

  void _startPolling() {
    _pollUnreadCount();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _pollUnreadCount());
  }

  Future<void> _pollUnreadCount() async {
    try {
      final count = await _convoRepository.getUnreadCount();
      emit(MessageUnreadCountState(count));
    } catch (_) {
      log.w('Failed to poll message unread count');
    }
  }

  Future<void> refresh() async {
    await _pollUnreadCount();
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}

class MessageUnreadCountState extends Equatable {
  const MessageUnreadCountState(this.count);

  final int count;

  bool get hasUnread => count > 0;

  @override
  List<Object?> get props => [count];
}
