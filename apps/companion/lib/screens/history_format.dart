import 'package:intl/intl.dart';

/// Formatting for the phone's history screens.
///
/// The car has its own copies of these in `lib/core/telemetry_format.dart`.
/// They are not shared yet on purpose: the car formats for a 1920-wide head
/// unit read at arm's length, and this formats for a phone in one hand. Share
/// them the day the two agree on a string, not before.
///
/// Every one of them prints `--` for a value the car never reported. A missing
/// reading is not a zero.
const kNoValue = '--';

/// Formats [at] with [pattern] in Russian, falling back to the default locale
/// when the Russian date data is not loaded, so a screen never fails on a date.
String _formatDate(String pattern, DateTime at) {
  try {
    return DateFormat(pattern, 'ru').format(at);
  } catch (_) {
    return DateFormat(pattern).format(at);
  }
}

String formatDateTime(int? millis) {
  if (millis == null || millis <= 0) return kNoValue;
  final at = DateTime.fromMillisecondsSinceEpoch(millis);
  return _formatDate('d MMM, HH:mm', at);
}

String formatClock(int? millis) {
  if (millis == null || millis <= 0) return kNoValue;
  return DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(millis));
}

String formatDuration(int? millis) {
  if (millis == null || millis <= 0) return kNoValue;
  final total = Duration(milliseconds: millis);
  final hours = total.inHours;
  final minutes = total.inMinutes % 60;
  if (hours == 0) return '$minutes мин';
  return '$hours ч $minutes мин';
}

String formatDistance(double? km) {
  if (km == null || km <= 0) return kNoValue;
  return km.toStringAsFixed(km >= 100 ? 0 : 1);
}

String formatEnergy(double? kwh) {
  if (kwh == null) return kNoValue;
  return kwh.toStringAsFixed(2);
}

String formatSocRange(double? start, double? end) {
  if (start == null && end == null) return kNoValue;
  final from = start == null ? kNoValue : start.round().toString();
  final to = end == null ? kNoValue : end.round().toString();
  return '$from → $to%';
}

String formatWhPerKm(double? whPerKm) {
  if (whPerKm == null || whPerKm <= 0) return kNoValue;
  return whPerKm.round().toString();
}

String formatTemperature(double? celsius) {
  if (celsius == null) return kNoValue;
  return celsius.toStringAsFixed(1);
}

String formatAltitudeGain(double? metres) {
  if (metres == null || metres <= 0) return kNoValue;
  return metres.round().toString();
}

/// Watt-hours, whole. The magnitude bars compare figures in the hundreds and
/// the thousands, and a decimal there is a digit nobody reads.
String formatWh(double? wh) {
  if (wh == null || !wh.isFinite) return kNoValue;
  return wh.round().toString();
}

/// A human-readable range between two moments in time.
String formatDateRange(int? startMillis, int? endMillis) {
  if (startMillis == null || endMillis == null) return kNoValue;
  final start = DateTime.fromMillisecondsSinceEpoch(startMillis);
  final end = DateTime.fromMillisecondsSinceEpoch(endMillis);
  final startStr = _formatDate('d MMM, HH:mm', start);
  final endStr =
      (start.year == end.year &&
          start.month == end.month &&
          start.day == end.day)
      ? DateFormat('HH:mm').format(end)
      : _formatDate('d MMM, HH:mm', end);
  return '$startStr – $endStr';
}
