import 'package:bluesky/chat_bsky_convo_defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';

part 'convo_list_event.dart';
part 'convo_list_state.dart';

class ConvoListBloc extends Bloc<ConvoListEvent, ConvoListState> {
  ConvoListBloc({required ConvoRepository convoRepository})
    : _convoRepository = convoRepository,
      super(const ConvoListState.initial()) {
    on<ConvosRequested>(_onConvosRequested);
    on<ConvosRefreshed>(_onConvosRefreshed);
    on<ConvoMuted>(_onConvoMuted);
    on<ConvoUnmuted>(_onConvoUnmuted);
    on<ConvoTabChanged>(_onConvoTabChanged);
  }

  final ConvoRepository _convoRepository;

  Future<void> _onConvosRequested(ConvosRequested event, Emitter<ConvoListState> emit) async {
    emit(const ConvoListState.loading());

    try {
      final result = await _convoRepository.listConvos(limit: event.limit);

      emit(ConvoListState.loaded(convos: result.convos, cursor: result.cursor, hasMore: result.cursor != null));
    } catch (error) {
      emit(ConvoListState.error('Failed to load conversations: $error'));
    }
  }

  Future<void> _onConvosRefreshed(ConvosRefreshed event, Emitter<ConvoListState> emit) async {
    if (state.status != ConvoListStatus.loaded) {
      return;
    }

    emit(state.copyWith(isRefreshing: true));

    try {
      final result = await _convoRepository.listConvos(limit: 20);

      emit(
        state.copyWith(
          convos: result.convos,
          cursor: result.cursor,
          hasMore: result.cursor != null,
          isRefreshing: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<void> _onConvoMuted(ConvoMuted event, Emitter<ConvoListState> emit) async {
    try {
      final updatedConvo = await _convoRepository.muteConvo(event.convoId);
      final updatedConvos = state.convos.map((c) => c.id == event.convoId ? updatedConvo : c).toList();
      emit(state.copyWith(convos: updatedConvos));
    } catch (error) {
      log.w('Failed to mute conversation ${event.convoId}: $error');
    }
  }

  Future<void> _onConvoUnmuted(ConvoUnmuted event, Emitter<ConvoListState> emit) async {
    try {
      final updatedConvo = await _convoRepository.unmuteConvo(event.convoId);
      final updatedConvos = state.convos.map((c) => c.id == event.convoId ? updatedConvo : c).toList();
      emit(state.copyWith(convos: updatedConvos));
    } catch (error) {
      log.w('Failed to unmute conversation ${event.convoId}: $error');
    }
  }

  void _onConvoTabChanged(ConvoTabChanged event, Emitter<ConvoListState> emit) {
    emit(state.copyWith(activeTab: event.tab));
  }
}
