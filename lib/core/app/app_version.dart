import 'package:package_info_plus/package_info_plus.dart';

final class AppVersion {
  const AppVersion._();

  static const prereleaseLabel = 'alpha';

  static Future<String> displayLabel() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return displayLabelFor(packageInfo);
  }

  static String displayLabelFor(PackageInfo packageInfo, {String? prereleaseLabel = AppVersion.prereleaseLabel}) {
    final rawAppName = packageInfo.appName.trim();
    final appName = rawAppName.isEmpty ? 'Lazurite' : rawAppName;
    final rawVersion = packageInfo.version.trim();
    final version = rawVersion.isEmpty ? '1.0.0' : rawVersion;
    final buildNumber = packageInfo.buildNumber.trim();
    final parsedVersion = _ParsedVersion.parse(version);
    final hasBuildNumber = buildNumber.isNotEmpty && buildNumber != version;
    final channel =
        parsedVersion.releaseChannel ??
        (hasBuildNumber ? _prereleaseChannelFromBuild(buildNumber, prereleaseLabel) : null);

    if (channel != null && channel.isNotEmpty) {
      final channelIncludesBuildNumber = hasBuildNumber && channel.endsWith(' $buildNumber');
      final channelHasNumber = RegExp(r'(^| )\d+$').hasMatch(channel);
      final suffix = !hasBuildNumber || channelIncludesBuildNumber
          ? ''
          : channelHasNumber
          ? ' (build $buildNumber)'
          : ' $buildNumber';
      return '$appName v${parsedVersion.baseVersion} $channel$suffix';
    }

    final buildSuffix = hasBuildNumber ? ' (build $buildNumber)' : '';
    return '$appName v$version$buildSuffix';
  }

  static String? _prereleaseChannelFromBuild(String buildNumber, String? prereleaseLabel) {
    final label = prereleaseLabel?.trim();
    if (label == null || label.isEmpty || buildNumber.isEmpty) {
      return null;
    }
    return '$label $buildNumber';
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
    final releaseChannel = version.substring(separatorIndex + 1).replaceAll(RegExp(r'[-_.]+'), ' ').trim();
    return _ParsedVersion(baseVersion: baseVersion, releaseChannel: releaseChannel.isEmpty ? null : releaseChannel);
  }
}
