class DidDocument {
  const DidDocument({required this.id, required this.alsoKnownAs, required this.service});

  factory DidDocument.fromJson(Map<String, dynamic> json) {
    return DidDocument(
      id: json['id'] as String,
      alsoKnownAs: (json['alsoKnownAs'] as List<dynamic>?)?.cast<String>() ?? [],
      service:
          (json['service'] as List<dynamic>?)
              ?.map((e) => DidService.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final String id;
  final List<String> alsoKnownAs;
  final List<DidService> service;

  Map<String, dynamic> toJson() => {
    'id': id,
    'alsoKnownAs': alsoKnownAs,
    'service': service.map((e) => e.toJson()).toList(),
  };

  String? get pdsEndpoint {
    try {
      return service
          .firstWhere((s) => s.id == '#atproto_pds' || s.type == 'AtprotoPersonalDataServer')
          .serviceEndpoint;
    } catch (_) {
      return null;
    }
  }
}

class DidService {
  const DidService({required this.id, required this.type, required this.serviceEndpoint});

  factory DidService.fromJson(Map<String, dynamic> json) {
    return DidService(
      id: json['id'] as String,
      type: json['type'] as String,
      serviceEndpoint: json['serviceEndpoint'] as String,
    );
  }

  final String id;
  final String type;
  final String serviceEndpoint;

  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'serviceEndpoint': serviceEndpoint};
}
