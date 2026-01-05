import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView screen for OAuth authorization flow on mobile platforms.
///
/// This screen opens the OAuth authorization URL in a WebView and monitors
/// navigation to capture the callback URL when the OAuth provider redirects
/// back to the app's loopback server.
class OAuthWebViewScreen extends StatefulWidget {
  const OAuthWebViewScreen({
    required this.authorizeUrl,
    required this.callbackUrlPrefix,
    super.key,
  });

  final String authorizeUrl;
  final String callbackUrlPrefix;

  @override
  State<OAuthWebViewScreen> createState() => _OAuthWebViewScreenState();
}

class _OAuthWebViewScreenState extends State<OAuthWebViewScreen> {
  late final WebViewController _controller;
  final Completer<Uri> _callbackCompleter = Completer<Uri>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (url.startsWith(widget.callbackUrlPrefix)) {
              final uri = Uri.parse(url);
              if (!_callbackCompleter.isCompleted) {
                _callbackCompleter.complete(uri);
                if (mounted) {
                  Navigator.of(context).pop(uri);
                }
              }
              return;
            }
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (error.url?.startsWith(widget.callbackUrlPrefix) == true) {
              final uri = Uri.parse(error.url!);
              if (!_callbackCompleter.isCompleted) {
                _callbackCompleter.complete(uri);
                if (mounted) {
                  Navigator.of(context).pop(uri);
                }
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(widget.callbackUrlPrefix)) {
              final uri = Uri.parse(request.url);
              if (!_callbackCompleter.isCompleted) {
                _callbackCompleter.complete(uri);
              }
              Future.microtask(() {
                if (mounted) {
                  Navigator.of(context).pop(uri);
                }
              });
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizeUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (!_callbackCompleter.isCompleted) {
              _callbackCompleter.completeError(Exception('User cancelled OAuth flow'));
            }
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
