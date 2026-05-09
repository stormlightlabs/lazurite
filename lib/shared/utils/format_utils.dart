import 'package:poptart_lex/app/bsky/feed/defs.dart';
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
String formatCount(int count, {String? locale}) {
  final numberFormat = NumberFormat.decimalPattern(locale ?? Intl.getCurrentLocale());
  final absoluteCount = count.abs();
  final sign = count < 0 ? '-' : '';
  if (absoluteCount >= 1000000) {
    return '$sign${(absoluteCount / 1000000).toStringAsFixed(1)}M';
  }
  if (absoluteCount >= 1000) {
    return '$sign${(absoluteCount / 1000).toStringAsFixed(1)}K';
  }
  return numberFormat.format(count);
}

/// Formats a relative timestamp using short units with optional suffix/casing.
String formatRelativeTime(
  DateTime time, {
  DateTime? now,
  String nowLabel = 'now',
  bool includeAgo = false,
  bool uppercase = false,
  String? locale,
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
    _ => DateFormat('MMM d', locale ?? Intl.getCurrentLocale()).format(time),
  };

  return uppercase ? formatted.toUpperCase() : formatted;
}

String formatTimestamp(DateTime time, {String? locale}) {
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '${time.year}-$month-$day $hour:$minute';
}

String feedDisplayName(GeneratorView value) {
  final displayName = value.displayName.trim();
  if (displayName.isNotEmpty) {
    return displayName;
  }
  return value.uri.rkey;
}

String formatBytes(int bytes) {
  if (bytes >= 1024 * 1024 * 1024) {
    final gb = bytes / (1024 * 1024 * 1024);
    return '${gb.toStringAsFixed(2)} GB';
  }
  final mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(2)} MB';
}
