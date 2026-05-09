// Copyright (c) 2023-2025, Shinya Kato.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Package imports:
import 'package:poptart_xrpc/poptart_xrpc.dart' as xrpc;

typedef DidResolver =
    Future<Map<String, dynamic>> Function({
      required String handle,
      String? service,
    });

DidResolver _resolver = _resolveDID;

Future<Map<String, dynamic>> findDID({
  required String handle,
  String? service,
}) async => _resolver(handle: handle, service: service);

void overrideDIDResolverForTesting(final DidResolver resolver) {
  _resolver = resolver;
}

void resetDIDResolverForTesting() {
  _resolver = _resolveDID;
}

Future<Map<String, dynamic>> _resolveDID({
  required String handle,
  String? service,
}) async {
  final response = await xrpc.query<Map<String, dynamic>>(
    xrpc.NSID.parse('com.atproto.identity.resolveHandle'),
    service: service,
    parameters: {'handle': handle},
  );

  return response.data;
}
