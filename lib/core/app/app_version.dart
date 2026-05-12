import 'package:package_info_plus/package_info_plus.dart';

final class AppVersion {
  const AppVersion._();

  static Future<String> displayLabel() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return displayLabelFor(packageInfo);
  }

  static String displayLabelFor(PackageInfo packageInfo) {
    final rawVersion = packageInfo.version.trim();
    final version = rawVersion.isEmpty ? '1.0.0' : rawVersion;
    final buildNumber = packageInfo.buildNumber.trim();
    final parsedVersion = _ParsedVersion.parse(version);
    final channel = parsedVersion.releaseChannel;
    final hasBuildNumber = buildNumber.isNotEmpty && buildNumber != version;

    if (channel != null && channel.isNotEmpty) {
      final suffix = hasBuildNumber ? ' $buildNumber' : '';
      return 'Lazurite v${parsedVersion.baseVersion} $channel$suffix';
    }

    final buildSuffix = hasBuildNumber ? ' (build $buildNumber)' : '';
    return 'Lazurite v$version$buildSuffix';
  }
}

final class _ParsedVersion {
  const _ParsedVersion({required this.baseVersion, required this.releaseChannel});

  final String baseVersion;
  final String? releaseChannel;

  static _ParsedVersion parse(String version) {
    final separatorIndex = version.indexOf('-');
    if (separatorIndex <= 0 || separatorIndex == version.length - 1) {
      return _ParsedVersion(baseVersion: version, releaseChannel: null);
    }

    final baseVersion = version.substring(0, separatorIndex);
    final releaseChannel = version.substring(separatorIndex + 1).replaceAll(RegExp(r'[-_]+'), ' ').trim();
    return _ParsedVersion(baseVersion: baseVersion, releaseChannel: releaseChannel.isEmpty ? null : releaseChannel);
  }
}
