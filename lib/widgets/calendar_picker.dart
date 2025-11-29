// lib/widgets/calendar_picker.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

class CalendarPickerButton extends StatelessWidget {
  /// Tanggal awal (format "D Month YYYY"), jika null fallback ke DateTime.now()
  final String? initialDateString;

  /// Callback ketika user memilih tanggal (format "D Month YYYY")
  final ValueChanged<String> onDateSelected;

  /// Opsi: ukuran kontainer
  final double size;

  /// Opsi: apakah memberi background filled (default true)
  final bool filled;

  const CalendarPickerButton({
    super.key,
    required this.onDateSelected,
    this.initialDateString,
    this.size = 40,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDatePicker(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        width: size,
        height: size,
        child: const Icon(Icons.calendar_today, size: 20, color: kInkTone),
      ),
    );
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final initial = _parseSelectedDate(initialDateString) ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formatted = '${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
      onDateSelected(formatted);
    }
  }

  // ---- helper parsing & formatting ----
  DateTime? _parseSelectedDate(String? sel) {
    if (sel == null) return null;
    try {
      final parts = sel.trim().split(' ');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = _monthFromName(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  int _monthFromName(String name) {
    switch (name.toLowerCase()) {
      case 'january':
        return 1;
      case 'february':
        return 2;
      case 'march':
        return 3;
      case 'april':
        return 4;
      case 'may':
        return 5;
      case 'june':
        return 6;
      case 'july':
        return 7;
      case 'august':
        return 8;
      case 'september':
        return 9;
      case 'october':
        return 10;
      case 'november':
        return 11;
      case 'december':
        return 12;
      default:
        return 1;
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}
