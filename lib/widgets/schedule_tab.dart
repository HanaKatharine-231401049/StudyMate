// lib/widgets/schedule_tab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/schedule.dart';
import '../utils/colors.dart';
import '../widgets/calendar_picker.dart';


typedef ScheduleTapCallback = void Function(Schedule schedule);
typedef DateSelectCallback = void Function(String date);

class ScheduleTab extends StatelessWidget {
  final List<Schedule> schedules;
  final String selectedDate;
  final DateSelectCallback onSelectDate;
  final ScheduleTapCallback onTapSchedule;

  const ScheduleTab({
    super.key,
    required this.schedules,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onTapSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('January',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CalendarPickerButton(
                  initialDateString: selectedDate,
                  onDateSelected: (formatted) {
                    onSelectDate(formatted);
                  },
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        // tanggal horizontal
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _buildDateItem('Mon', '14', '14 January 2025'),
              _buildDateItem('Tue', '15', '15 January 2025'),
              _buildDateItem('Wed', '16', '16 January 2025'),
              _buildDateItem('Thu', '17', '17 January 2025'),
              _buildDateItem('Fri', '18', '18 January 2025'),
              _buildDateItem('Sat', '19', '19 January 2025'),
              _buildDateItem('Sun', '20', '20 January 2025'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // list jadwal
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount:
                schedules.where((s) => s.date.contains(selectedDate)).length,
            itemBuilder: (context, index) {
              final filtered =
                  schedules.where((s) => s.date.contains(selectedDate)).toList();
              final schedule = filtered[index];
              return _buildScheduleItem(context, schedule);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem(String day, String date, String fullDate) {
    bool isSelected = selectedDate == fullDate;
    return GestureDetector(
      onTap: () => onSelectDate(fullDate),
      child: Container(
        width: 50,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? kInkTone.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(day,
                style: GoogleFonts.inter(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 12,
                    color: isSelected ? kInkTone : Colors.grey[700])),
            Text(date,
                style: GoogleFonts.inter(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    decoration:
                        isSelected ? TextDecoration.underline : TextDecoration.none,
                    decorationColor: kInkTone)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, Schedule schedule) {
    return GestureDetector(
      onTap: () => onTapSchedule(schedule),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: kInkTone.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.access_time, size: 20, color: kInkTone),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(schedule.time,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(schedule.title,
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(schedule.description,
                      style: GoogleFonts.inter(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // GANTI: gunakan showDatePicker (native popup) sama seperti Add/Edit page
  void _showCalendarDialog(BuildContext context) async {
    // parse selectedDate jadi initial DateTime, fallback ke now
    DateTime initial = _parseSelectedDate(selectedDate) ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      String formatted = '${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
      onSelectDate(formatted);
    }
  }

  DateTime? _parseSelectedDate(String sel) {
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
