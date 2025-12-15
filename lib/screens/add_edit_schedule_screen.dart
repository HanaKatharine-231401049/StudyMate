// lib/screens/add_edit_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/schedule.dart';
import '../widgets/calendar_picker.dart';
import '../services/study_service.dart';

class AddEditSchedulePage extends StatefulWidget {
  final bool isEditing;
  final Schedule? schedule;

  const AddEditSchedulePage({
    super.key,
    required this.isEditing,
    this.schedule,
  });

  @override
  State<AddEditSchedulePage> createState() => _AddEditSchedulePageState();
}

class _AddEditSchedulePageState extends State<AddEditSchedulePage> {
  late final TextEditingController titleController;
  late final TextEditingController dateController;
  late final TextEditingController timeController;
  late final TextEditingController descriptionController;

  final uid = FirebaseAuth.instance.currentUser!.uid;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.isEditing && widget.schedule != null
          ? widget.schedule!.title
          : '',
    );

    dateController = TextEditingController(
      text: widget.isEditing && widget.schedule != null
          ? widget.schedule!.date
          : '',
    );

    timeController = TextEditingController(
      text: widget.isEditing && widget.schedule != null
          ? widget.schedule!.time
          : '',
    );

    descriptionController = TextEditingController(
      text: widget.isEditing && widget.schedule != null
          ? widget.schedule!.description
          : '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    dateController.dispose();
    timeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _showDialog(String msg) {
    final scheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: scheme.surface,
        title: Text(
          'Validation Error',
          style: GoogleFonts.inter(color: scheme.onSurface),
        ),
        content: Text(
          msg,
          style: GoogleFonts.inter(color: scheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(color: scheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseDate(String input) {
    // normalize weird spaces
    var raw = input
        .replaceAll('\u00A0', ' ')
        .replaceAll('\u202F', ' ')
        .replaceAll('\u2007', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (raw.isEmpty) return null;

    // 1) Try built-in ISO parsing first (e.g. "2025-12-11 00:00:00.000")
    final direct = DateTime.tryParse(raw);
    if (direct != null) {
      return DateTime(direct.year, direct.month, direct.day);
    }

    // 2) Fallback: "11 December 2025", "11 Dec 2025", "11 Desember 2025", etc.
    final match =
        RegExp(r'(\d{1,2})\s+([A-Za-z]+)\s*,?\s*(\d{4})').firstMatch(raw);

    if (match == null) return null;

    final day = int.tryParse(match.group(1)!);
    final monthName = match.group(2)!.toLowerCase();
    final year = int.tryParse(match.group(3)!);

    if (day == null || year == null) return null;

    const monthMap = {
      'january': 1,
      'jan': 1,
      'february': 2,
      'feb': 2,
      'march': 3,
      'mar': 3,
      'april': 4,
      'apr': 4,
      'may': 5,
      'june': 6,
      'jun': 6,
      'july': 7,
      'jul': 7,
      'august': 8,
      'aug': 8,
      'september': 9,
      'sep': 9,
      'sept': 9,
      'october': 10,
      'oct': 10,
      'november': 11,
      'nov': 11,
      'december': 12,
      'dec': 12,
      // Indonesian variants
      'januari': 1,
      'februari': 2,
      'maret': 3,
      'mei': 5,
      'juni': 6,
      'juli': 7,
      'agustus': 8,
      'oktober': 10,
      'desember': 12,
    };

    final month = monthMap[monthName];
    if (month == null) return null;

    return DateTime(year, month, day);
  }

  Future<void> _saveSchedule() async {
    if (_isSaving) return;

    final title = titleController.text.trim();
    final dateStr = dateController.text.trim();
    final timeRange = timeController.text.trim();
    final desc = descriptionController.text.trim();

    if (title.isEmpty || dateStr.isEmpty || timeRange.isEmpty) {
      _showDialog('Please fill title, date and time.');
      return;
    }

    final dateObj = _parseDate(dateStr);
    if (dateObj == null) {
      _showDialog('Invalid date. Please pick a valid date.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = StudyService();

      if (widget.isEditing && widget.schedule != null) {
        await service.updateSchedule(
          uid: uid,
          scheduleId: widget.schedule!.id,
          title: title,
          date: dateObj,
          timeRange: timeRange,
          description: desc,
        );

        Navigator.pop(
          context,
          widget.schedule!.copyWith(
            title: title,
            date: dateStr,
            time: timeRange,
            description: desc,
          ),
        );
      } else {
        await service.addSchedule(
          uid: uid,
          title: title,
          date: dateObj,
          timeRange: timeRange,
          description: desc,
        );

        Navigator.pop(
          context,
          Schedule(
            id: '',
            title: title,
            date: dateStr,
            time: timeRange,
            description: desc,
          ),
        );
      }
    } catch (e) {
      _showDialog('Failed to save schedule.\n$e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        backgroundColor: scheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? 'Edit Schedule' : 'Add Schedule',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Title', scheme),
              _field(
                context,
                controller: titleController,
                hint: 'Enter schedule title',
              ),
              const SizedBox(height: 20),

              _label('Date', scheme),
              _field(
                context,
                controller: dateController,
                readOnly: true,
                hint: 'Select date',
                suffix: CalendarPickerButton(
                  initialDateString:
                      dateController.text.isEmpty ? null : dateController.text,
                  onDateSelected: (v) => setState(() {
                    dateController.text = v;
                  }),
                  size: 36,
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),

              _label('Time', scheme),
              _field(
                context,
                controller: timeController,
                hint: 'Enter time (e.g., 10:30 - 11:20)',
              ),
              const SizedBox(height: 20),

              _label('Description', scheme),
              _field(
                context,
                controller: descriptionController,
                hint: 'Enter schedule description (optional)',
                maxLines: 4,
              ),
              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSchedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Save',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: scheme.onBackground,
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context, {
    required TextEditingController controller,
    String? hint,
    bool readOnly = false,
    int maxLines = 1,
    Widget? suffix,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: scheme.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: scheme.surface,
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(color: scheme.onSurface.withOpacity(0.6)),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
    );
  }
}