// lib/utils/date_utils.dart
import 'package:intl/intl.dart';

class DateUtilsHelper {
  // Main display format used in UI
  static final DateFormat _displayFormat = DateFormat('d MMMM yyyy');

  /// Format a DateTime into the main display string, e.g. "18 December 2025"
  static String formatDate(DateTime date) => _displayFormat.format(date);

  /// Try to parse various date string formats into a DateTime.
  /// Returns null if it can't parse.
  static DateTime? tryParse(String? input) {
    if (input == null) return null;

    var raw = input
        .replaceAll('\u00A0', ' ') // NBSP
        .replaceAll('\u202F', ' ')
        .replaceAll('\u2007', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (raw.isEmpty) return null;

    // Try ISO formats first
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    // Supported patterns (includes your old formats)
    final patterns = <String>[
      'd MMMM yyyy',
      'dd MMMM yyyy',
      'dd/MM/yyyy',
      'd/M/yyyy',
      'MM/dd/yyyy',
      'M/d/yyyy',
      'dd-MM-yyyy',
      'd-M-yyyy',
      'yyyy-MM-dd',
      'yyyy/MM/dd',
      'MMM d, yyyy',
      'MMMM d, yyyy',
    ];

    for (final p in patterns) {
      try {
        return DateFormat(p).parseStrict(raw);
      } catch (_) {
        // ignore and try next
      }
    }

    return null;
  }
}
