import 'package:intl/intl.dart';

/// Returns up to two initials from a display value.
String formatInitials(String value) {
  final parts = value.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
}

/// Formats counts using compact K/M suffixes.
String formatCount(int count) {
  final absoluteCount = count.abs();
  final sign = count < 0 ? '-' : '';
  if (absoluteCount >= 1000000) {
    return '$sign${(absoluteCount / 1000000).toStringAsFixed(1)}M';
  }
  if (absoluteCount >= 1000) {
    return '$sign${(absoluteCount / 1000).toStringAsFixed(1)}K';
  }
  return '$count';
}

/// Formats a relative timestamp using short units with optional suffix/casing.
String formatRelativeTime(
  DateTime time, {
  DateTime? now,
  String nowLabel = 'now',
  bool includeAgo = false,
  bool uppercase = false,
}) {
  final current = now ?? DateTime.now();
  var difference = current.difference(time);
  if (difference.isNegative) {
    difference = Duration.zero;
  }

  final agoSuffix = includeAgo ? ' ago' : '';
  final formatted = switch (difference) {
    final d when d.inMinutes < 1 => nowLabel,
    final d when d.inHours < 1 => '${d.inMinutes}m$agoSuffix',
    final d when d.inDays < 1 => '${d.inHours}h$agoSuffix',
    final d when d.inDays < 7 => '${d.inDays}d$agoSuffix',
    _ => DateFormat('MMM d').format(time),
  };

  return uppercase ? formatted.toUpperCase() : formatted;
}
