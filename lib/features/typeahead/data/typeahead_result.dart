import 'package:atproto/com_atproto_label_defs.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:equatable/equatable.dart';

class TypeaheadResult extends Equatable {
  const TypeaheadResult({
    required this.did,
    required this.handle,
    this.displayName,
    this.avatarUrl,
    this.labels = const [],
  });

  factory TypeaheadResult.fromProfileViewBasic(ProfileViewBasic profile) {
    return TypeaheadResult(
      did: profile.did,
      handle: profile.handle,
      displayName: profile.displayName,
      avatarUrl: profile.avatar,
      labels: List<Label>.unmodifiable(profile.labels ?? const []),
    );
  }

  factory TypeaheadResult.fromJson(Map<String, dynamic> json) {
    final rawLabels = json['labels'];
    final labels = <Label>[];

    if (rawLabels is List) {
      for (final rawLabel in rawLabels) {
        if (rawLabel is Map<String, dynamic>) {
          labels.add(Label.fromJson(rawLabel));
        }
      }
    }

    return TypeaheadResult(
      did: _requiredString(json, 'did'),
      handle: _requiredString(json, 'handle'),
      displayName: _optionalString(json, 'displayName'),
      avatarUrl: _optionalString(json, 'avatar'),
      labels: List<Label>.unmodifiable(labels),
    );
  }

  final String did;
  final String handle;
  final String? displayName;
  final String? avatarUrl;
  final List<Label> labels;

  ProfileViewBasic toProfileViewBasic() {
    return ProfileViewBasic(did: did, handle: handle, displayName: displayName, avatar: avatarUrl, labels: labels);
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }

    throw FormatException('Invalid or missing "$key" field in typeahead result payload.');
  }

  static String? _optionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  @override
  List<Object?> get props => [did, handle, displayName, avatarUrl, labels];
}
