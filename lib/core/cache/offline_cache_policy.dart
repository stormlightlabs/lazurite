/// Includes balanced profile defaults.
class OfflineCachePolicy {
  const OfflineCachePolicy._();

  static const int feedPostLimit = 250;
  static const int threadRootLimit = 100;
  static const int imageObjectLimit = 300;
  static const Duration imageStalePeriod = Duration(days: 7);
  static const int imageMemoryEntryLimit = 300;
  static const int imageMemoryByteLimit = 60 * 1024 * 1024;
}
