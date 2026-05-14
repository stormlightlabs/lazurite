String formatAtProtoDateTime(DateTime value) {
  final utc = value.toUtc();
  final year = utc.year.toString().padLeft(4, '0');
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  final hour = utc.hour.toString().padLeft(2, '0');
  final minute = utc.minute.toString().padLeft(2, '0');
  final second = utc.second.toString().padLeft(2, '0');
  final millisecond = utc.millisecond.toString().padLeft(3, '0');
  return '$year-$month-${day}T$hour:$minute:$second.${millisecond}Z';
}

String? formatAtProtoDateTimeString(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return formatAtProtoDateTime(parsed);
}

DateTime canonicalAtProtoDateTime(DateTime value) {
  final utc = value.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second, utc.millisecond);
}
