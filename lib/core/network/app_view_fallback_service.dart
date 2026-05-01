import 'dart:async';
import 'dart:io';

import 'package:atproto_core/atproto_core.dart' as atp_core show XRPCException;
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';

class AppViewFallbackService {
  AppViewFallbackService({
    DateTime Function()? nowProvider,
    Duration openWindow = const Duration(minutes: 2),
    int failureThreshold = 2,
  }) : _nowProvider = nowProvider ?? DateTime.now,
       _openWindow = openWindow,
       _failureThreshold = failureThreshold;

  final DateTime Function() _nowProvider;
  final Duration _openWindow;
  final int _failureThreshold;
  final Map<String, _CircuitState> _states = {};
  final StreamController<AppViewRoutingEvent> _events = StreamController<AppViewRoutingEvent>.broadcast();

  Stream<AppViewRoutingEvent> get events => _events.stream;

  void dispose() {
    _events.close();
  }

  Future<T> run<T>({
    required String endpointId,
    required String primaryProviderKey,
    required bool fallbackEnabled,
    required int routingEpoch,
    required int Function() routingEpochResolver,
    Map<String, String>? baseHeaders,
    required Future<T> Function(
      AppViewRequestContext context,
      Map<String, String> headers, {
      required bool fallbackUsed,
    })
    request,
  }) async {
    final fallbackProvider = fallbackEnabled ? AppViewProviders.alternateBuiltIn(primaryProviderKey) : null;
    final candidates = [
      primaryProviderKey,
      if (fallbackProvider != null && fallbackProvider != primaryProviderKey) fallbackProvider,
    ];

    Object? lastError;
    StackTrace? lastStackTrace;

    for (var index = 0; index < candidates.length; index++) {
      if (routingEpochResolver() != routingEpoch) {
        throw StaleRoutingEpochException(expected: routingEpoch, actual: routingEpochResolver());
      }
      final provider = candidates[index];
      final fallbackUsed = index > 0;
      final now = _nowProvider();
      if (_isOpen(endpointId, provider, now)) {
        log.w(
          'appview.public_read endpoint=$endpointId provider=$provider '
          'fallbackUsed=$fallbackUsed action=skip reason=circuit_open',
        );
        continue;
      }

      final context = AppViewRequestContext(appViewProvider: provider);
      final headers = context.appBskyHeaders(baseHeaders);
      log.i(
        'appview.public_read endpoint=$endpointId provider=$provider '
        'fallbackUsed=$fallbackUsed fallbackEnabled=$fallbackEnabled action=attempt',
      );

      try {
        final result = await request(context, headers, fallbackUsed: fallbackUsed);
        if (routingEpochResolver() != routingEpoch) {
          throw StaleRoutingEpochException(expected: routingEpoch, actual: routingEpochResolver());
        }
        _recordSuccess(endpointId, provider);
        if (fallbackUsed) {
          _events.add(
            AppViewFallbackUsedEvent(
              endpointId: endpointId,
              fromProvider: candidates.first,
              toProvider: provider,
              occurredAt: now,
            ),
          );
        }
        log.i('appview.public_read endpoint=$endpointId provider=$provider fallbackUsed=$fallbackUsed action=success');
        return result;
      } catch (error, stackTrace) {
        if (error is StaleRoutingEpochException) {
          rethrow;
        }
        final failure = _PublicReadFailure.classify(error);
        _events.add(
          AppViewProviderErrorEvent(
            endpointId: endpointId,
            provider: provider,
            reason: failure.reason,
            transient: failure.isTransient,
            occurredAt: now,
          ),
        );
        final circuitOpened = _recordFailure(endpointId, provider, now, failure.isTransient);
        log.w(
          'appview.public_read endpoint=$endpointId provider=$provider '
          'fallbackUsed=$fallbackUsed action=error transient=${failure.isTransient} '
          'reason=${failure.reason} circuitOpened=$circuitOpened',
          error: error,
          stackTrace: stackTrace,
        );
        lastError = error;
        lastStackTrace = stackTrace;
        if (!failure.isTransient) {
          Error.throwWithStackTrace(error, stackTrace);
        }
      }
    }

    if (lastError != null && lastStackTrace != null) {
      Error.throwWithStackTrace(lastError, lastStackTrace);
    }

    throw StateError('No providers available for $endpointId (all candidates blocked by circuit breaker).');
  }

  bool _isOpen(String endpointId, String providerKey, DateTime now) {
    final state = _states[_key(endpointId, providerKey)];
    if (state == null || state.openUntil == null) {
      return false;
    }
    final openUntil = state.openUntil!;
    if (now.isBefore(openUntil)) {
      return true;
    }
    state.openUntil = null;
    state.transientFailureCount = 0;
    return false;
  }

  void _recordSuccess(String endpointId, String providerKey) {
    final state = _states[_key(endpointId, providerKey)];
    if (state == null) {
      return;
    }
    state.transientFailureCount = 0;
    state.openUntil = null;
  }

  bool _recordFailure(String endpointId, String providerKey, DateTime now, bool isTransient) {
    final state = _states.putIfAbsent(_key(endpointId, providerKey), _CircuitState.new);
    if (!isTransient) {
      state.transientFailureCount = 0;
      state.openUntil = null;
      return false;
    }

    state.transientFailureCount += 1;
    if (state.transientFailureCount >= _failureThreshold) {
      state.openUntil = now.add(_openWindow);
      state.transientFailureCount = 0;
      return true;
    }
    return false;
  }

  String _key(String endpointId, String providerKey) => '$endpointId::$providerKey';
}

sealed class AppViewRoutingEvent {
  const AppViewRoutingEvent({required this.endpointId, required this.occurredAt});

  final String endpointId;
  final DateTime occurredAt;
}

class AppViewFallbackUsedEvent extends AppViewRoutingEvent {
  const AppViewFallbackUsedEvent({
    required super.endpointId,
    required this.fromProvider,
    required this.toProvider,
    required super.occurredAt,
  });

  final String fromProvider;
  final String toProvider;
}

class AppViewProviderErrorEvent extends AppViewRoutingEvent {
  const AppViewProviderErrorEvent({
    required super.endpointId,
    required this.provider,
    required this.reason,
    required this.transient,
    required super.occurredAt,
  });

  final String provider;
  final String reason;
  final bool transient;
}

class StaleRoutingEpochException implements Exception {
  const StaleRoutingEpochException({required this.expected, required this.actual});

  final int expected;
  final int actual;

  @override
  String toString() => 'StaleRoutingEpochException(expected: $expected, actual: $actual)';
}

class _CircuitState {
  int transientFailureCount = 0;
  DateTime? openUntil;
}

class _PublicReadFailure {
  const _PublicReadFailure._({required this.reason, required this.isTransient});

  final String reason;
  final bool isTransient;

  static _PublicReadFailure classify(Object error) {
    if (error is TimeoutException) {
      return const _PublicReadFailure._(reason: 'timeout', isTransient: true);
    }
    if (error is SocketException) {
      return const _PublicReadFailure._(reason: 'dns', isTransient: true);
    }
    if (error is atp_core.XRPCException) {
      final statusCode = error.response.status.code;
      if (statusCode == 429) {
        return const _PublicReadFailure._(reason: '429', isTransient: true);
      }
      if (statusCode >= 500 && statusCode < 600) {
        return const _PublicReadFailure._(reason: '5xx', isTransient: true);
      }
      return _PublicReadFailure._(reason: 'http_$statusCode', isTransient: false);
    }

    final message = error.toString().toLowerCase();
    if (message.contains('timeout')) {
      return const _PublicReadFailure._(reason: 'timeout', isTransient: true);
    }
    if (RegExp(r'(^|[^0-9])429([^0-9]|$)').hasMatch(message)) {
      return const _PublicReadFailure._(reason: '429', isTransient: true);
    }
    if (RegExp(r'(^|[^0-9])5[0-9][0-9]([^0-9]|$)').hasMatch(message)) {
      return const _PublicReadFailure._(reason: '5xx', isTransient: true);
    }
    if (message.contains('failed host lookup') || message.contains('socketexception')) {
      return const _PublicReadFailure._(reason: 'dns', isTransient: true);
    }
    return const _PublicReadFailure._(reason: 'non_transient', isTransient: false);
  }
}
