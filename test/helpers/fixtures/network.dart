import 'package:poptart_core/poptart_core.dart' as atcore;

atcore.UnauthorizedException testUnauthorizedException(
  String methodId, {
  atcore.HttpMethod method = atcore.HttpMethod.get,
}) => atcore.UnauthorizedException(
  atcore.XRPCResponse(
    headers: const {},
    status: atcore.HttpStatus.unauthorized,
    request: atcore.XRPCRequest(method: method, url: Uri.https('bsky.social', '/xrpc/$methodId')),
    rateLimit: atcore.RateLimit.unlimited(),
    data: const atcore.XRPCError(error: 'Unauthorized', message: 'exp claim timestamp check failed'),
  ),
);

Map<String, Object?> testPdsService({
  String id = '#atproto_pds',
  String type = 'AtprotoPersonalDataServer',
  String serviceEndpoint = 'https://pds.example.com',
}) => {'id': id, 'type': type, 'serviceEndpoint': serviceEndpoint};

Map<String, Object?> testDidDocument({
  String id = 'did:plc:alice',
  String serviceEndpoint = 'https://alice.us-east.host.bsky.network',
  List<Map<String, Object?>>? services,
}) => {
  'id': id,
  'service': services ?? [testPdsService(serviceEndpoint: serviceEndpoint)],
};
