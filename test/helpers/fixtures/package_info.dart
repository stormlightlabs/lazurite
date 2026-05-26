import 'package:package_info_plus/package_info_plus.dart';

PackageInfo testPackageInfo({
  String appName = 'Lazurite',
  String packageName = 'org.stormlightlabs.lazurite',
  String version = '1.0.0',
  String buildNumber = '6',
  String buildSignature = '',
  String? installerStore,
}) => PackageInfo(
  appName: appName,
  packageName: packageName,
  version: version,
  buildNumber: buildNumber,
  buildSignature: buildSignature,
  installerStore: installerStore,
);
