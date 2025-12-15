// lib/widgets/schedule_tab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/schedule.dart';

class ScheduleTab extends StatefulWidget {
  final List<Schedule> schedules;
  final String selectedDate;
  final void Function(String dateString) onSelectDate;
  final void Function(Schedule schedule) onTapSchedule;

  const ScheduleTab({
    super.key,
    required this.schedules,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onTapSchedule,
  });

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  late DateTime _selectedDay;
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _selectedDay = _parse(widget.selectedDate) ?? DateTime.now();
    _weekStart = _weekStartOf(_selectedDay);
  }

  @override
  void didUpdateWidget(covariant ScheduleTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      final parsed = _parse(widget.selectedDate);
      if (parsed != null) {
        setState(() {
          _selectedDay = parsed;
          _weekStart = _weekStartOf(parsed);
        });
      }
    }
  }

  DateTime? _parse(String raw) {
    raw = raw.trim();
    if (raw.isEmpty) return null;

    // ISO
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    const formats = [
      'd MMMM yyyy',
      'dd MMMM yyyy',
      'dd MMM yyyy',
      'd MMM yyyy',
      'dd/MM/yyyy',
      'd/M/yyyy',
      'dd-MM-yyyy',
      'd-M-yyyy',
      'yyyy-MM-dd',
      'yyyy/MM/dd',
      'MMM d, yyyy',
      'MMMM d, yyyy',
    ];

    for (final f in formats) {
      try {
        return DateFormat(f).parseStrict(raw);
      } catch (_) {}
    }
    return null;
  }

  DateTime _weekStartOf(DateTime day) {
    return day.subtract(Duration(days: day.weekday - 1));
  }

  List<DateTime> _weekDays(DateTime start) =>
      List.generate(7, (i) => start.add(Duration(days: i)));

  // ---------------- PICKER ----------------
  Future<void> _openPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        // force picker to follow theme
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    final formatted = DateFormat('d MMMM yyyy').format(picked);
    setState(() {
      _selectedDay = picked;
      _weekStart = _weekStartOf(picked);
    });
    widget.onSelectDate(formatted);
  }

  void _selectDay(DateTime day) {
    final formatted = DateFormat('d MMMM yyyy').format(day);
    setState(() {
      _selectedDay = day;
      _weekStart = _weekStartOf(day);
    });
    widget.onSelectDate(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final week = _weekDays(_weekStart);
    final monthTitle = DateFormat('MMMM').format(_selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------- TOP BAR ----------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              Text(
                monthTitle,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: scheme.onBackground,
                ),
              ),
              const Spacer(),

              // Calendar button
              InkWell(
                onTap: _openPicker,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: scheme.outline),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: scheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ---------------- WEEK STRIP ----------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week.map((day) {
              final isSelected = day.year == _selectedDay.year &&
                  day.month == _selectedDay.month &&
                  day.day == _selectedDay.day;

              final dow = DateFormat('E').format(day); // Mon, Tue...

              return GestureDetector(
                onTap: () => _selectDay(day),
                child: Column(
                  children: [
                    Text(
                      dow,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: scheme.onBackground.withOpacity(0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? scheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? scheme.primary
                              : scheme.outline.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        '${day.day}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected ? scheme.onPrimary : scheme.onBackground,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // ---------------- SCHEDULE LIST ----------------
        Expanded(
          child: widget.schedules.isEmpty
              ? Center(
                  child: Text(
                    'No schedules for this day.',
                    style: GoogleFonts.inter(
                      color: scheme.onBackground.withOpacity(0.55),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.schedules.length,
                  itemBuilder: (context, i) {
                    final s = widget.schedules[i];
                    return _ScheduleItem(
                      schedule: s,
                      scheme: scheme,
                      onTap: () => widget.onTapSchedule(s),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------- CARD ITEM ----------------
class _ScheduleItem extends StatelessWidget {
  final Schedule schedule;
  final ColorScheme scheme;
  final VoidCallback onTap;

  const _ScheduleItem({
    required this.schedule,
    required this.scheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left time column
            Container(
              width: 80,
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                schedule.time,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Right details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (schedule.description.isNotEmpty)
                    Text(
                      schedule.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: scheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}