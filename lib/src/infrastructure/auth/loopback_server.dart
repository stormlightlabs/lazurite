import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../../core/utils/logger.dart';

/// Manages a temporary HTTP server on localhost for OAuth callbacks.
///
/// This implements the loopback redirect flow required by ATProto OAuth
/// for native mobile apps per RFC 8252.
class LoopbackServer {
  LoopbackServer({Logger? logger}) : _logger = logger ?? const Logger('LoopbackServer');

  final Logger _logger;
  HttpServer? _server;
  final Completer<Uri> _callbackCompleter = Completer<Uri>();

  /// Starts the loopback server and returns the redirect URI.
  ///
  /// The server listens on http://127.0.0.1 with a random available port.
  /// Returns the full redirect URI (e.g., http://127.0.0.1:12345/callback).
  ///
  /// Per RFC 8252, uses IP address 127.0.0.1 instead of 'localhost' hostname.
  Future<String> start() async {
    if (_server != null) {
      throw StateError('Server already started');
    }

    final handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(_handleRequest);

    _server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);

    final port = _server!.port;
    final redirectUri = 'http://127.0.0.1:$port/callback';

    _logger.info('Loopback server started on $redirectUri');
    return redirectUri;
  }

  /// Waits for the OAuth callback and returns the full callback URI.
  ///
  /// This future completes when the OAuth server redirects to the callback URL.
  /// The returned URI contains query parameters including the authorization code.
  Future<Uri> waitForCallback() async {
    return _callbackCompleter.future;
  }

  /// Stops the loopback server.
  Future<void> stop() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
      _logger.info('Loopback server stopped');
    }
  }

  /// Handles incoming HTTP requests.
  ///
  /// Captures the callback request and returns a success page to the browser.
  shelf.Response _handleRequest(shelf.Request request) {
    if (request.url.path == 'callback') {
      _logger.debug('Received OAuth callback: ${request.requestedUri}');

      if (!_callbackCompleter.isCompleted) {
        _callbackCompleter.complete(request.requestedUri);
      }

      return shelf.Response.ok(_successHtml, headers: {'Content-Type': 'text/html'});
    }

    return shelf.Response.notFound('Not found');
  }

  static const _successHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Login Successful</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }
    .container {
      text-align: center;
      background: white;
      padding: 3rem;
      border-radius: 1rem;
      margin: auto;
      box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    }
    .checkmark {
      width: 80px;
      height: 80px;
      border-radius: 50%;
      display: block;
      stroke-width: 3;
      stroke: #4caf50;
      stroke-miterlimit: 10;
      margin: 0 auto 1rem;
      box-shadow: inset 0 0 0 #4caf50;
      animation: fill .4s ease-in-out .4s forwards, scale .3s ease-in-out .9s both;
    }
    .checkmark__circle {
      stroke-dasharray: 166;
      stroke-dashoffset: 166;
      stroke-width: 3;
      stroke-miterlimit: 10;
      stroke: #4caf50;
      fill: none;
      animation: stroke 0.6s cubic-bezier(0.65, 0, 0.45, 1) forwards;
    }
    .checkmark__check {
      transform-origin: 50% 50%;
      stroke-dasharray: 48;
      stroke-dashoffset: 48;
      animation: stroke 0.3s cubic-bezier(0.65, 0, 0.45, 1) 0.8s forwards;
    }
    @keyframes stroke {
      100% { stroke-dashoffset: 0; }
    }
    @keyframes scale {
      0%, 100% { transform: none; }
      50% { transform: scale3d(1.1, 1.1, 1); }
    }
    h1 {
      color: #333;
      margin: 0 0 0.5rem;
    }
    p {
      color: #666;
      margin: 0;
    }
  </style>
</head>
<body>
  <div class="container">
    <svg class="checkmark" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
      <circle class="checkmark__circle" cx="26" cy="26" r="25" fill="none"/>
      <path class="checkmark__check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
    </svg>
    <h1>Login Successful!</h1>
    <p>You can close this window and return to the app.</p>
  </div>
</body>
</html>
''';
}
