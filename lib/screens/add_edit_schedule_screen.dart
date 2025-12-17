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
  bool _isTimeValid = true;

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

    if (widget.isEditing && widget.schedule != null && widget.schedule!.time.isNotEmpty) {
      _validateTimeRange(widget.schedule!.time);
    }
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
          'Validation',
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

  /// Validasi format waktu range 
  void _validateTimeRange(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      setState(() => _isTimeValid = true);
      return;
    }

    final pattern = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]\s*[-–]\s*([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    
    bool isValid = pattern.hasMatch(trimmed);
    
    if (isValid) {
      final cleanTime = trimmed.replaceAll(RegExp(r'\s+'), '');
      final separator = cleanTime.contains('–') ? '–' : '-';
      final parts = cleanTime.split(separator);
      
      if (parts.length == 2) {
        final startParts = parts[0].split(':');
        final endParts = parts[1].split(':');
        
        if (startParts.length == 2 && endParts.length == 2) {
          final startHour = int.tryParse(startParts[0]);
          final startMinute = int.tryParse(startParts[1]);
          final endHour = int.tryParse(endParts[0]);
          final endMinute = int.tryParse(endParts[1]);
          
          if (startHour == null || startMinute == null || 
              endHour == null || endMinute == null) {
            isValid = false;
          } else if (startHour < 0 || startHour > 23 || 
                     startMinute < 0 || startMinute > 59 ||
                     endHour < 0 || endHour > 23 || 
                     endMinute < 0 || endMinute > 59) {
            isValid = false;
          }
        } else {
          isValid = false;
        }
      } else {
        isValid = false;
      }
    }
    
    setState(() => _isTimeValid = isValid);
  }

  DateTime? _parseDate(String input) {
    var raw = input
        .replaceAll('\u00A0', ' ')
        .replaceAll('\u202F', ' ')
        .replaceAll('\u2007', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (raw.isEmpty) return null;

    final direct = DateTime.tryParse(raw);
    if (direct != null) {
      return DateTime(direct.year, direct.month, direct.day);
    }

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

    if (!_isTimeValid) {
      _showDialog('Invalid time format. Please use format HH:mm - HH:mm (e.g., 10:30 - 11:20)');
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: scheme.primary),
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
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title', style: GoogleFonts.inter(color: scheme.onBackground)),
              const SizedBox(height: 5),
              TextFormField(
                controller: titleController,
                decoration: _inputDecoration(
                  context,
                  hintText: 'Enter schedule title',
                ),
                style: GoogleFonts.inter(color: scheme.onSurface),
              ),
              const SizedBox(height: 20),

              Text('Date', style: GoogleFonts.inter(color: scheme.onBackground)),
              const SizedBox(height: 5),
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: _inputDecoration(
                  context,
                  hintText: 'Select date',
                  suffixIcon: CalendarPickerButton(
                    initialDateString:
                        dateController.text.isEmpty ? null : dateController.text,
                    onDateSelected: (formatted) {
                      setState(() {
                        dateController.text = formatted;
                      });
                    },
                    size: 44,
                    filled: true,
                  ),
                ),
                style: GoogleFonts.inter(color: scheme.onSurface),
              ),
              const SizedBox(height: 20),

              Text('Time', style: GoogleFonts.inter(color: scheme.onBackground)),
              const SizedBox(height: 5),
              TextFormField(
                controller: timeController,
                decoration: _inputDecoration(
                  context,
                  hintText: 'HH:mm - HH:mm (e.g., 10:30 - 11:20)',
                  errorText: _isTimeValid ? null : 'Format harus HH:mm - HH:mm',
                ),
                style: GoogleFonts.inter(color: scheme.onSurface),
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  _validateTimeRange(value);
                },
              ),
              const SizedBox(height: 20),

              Text('Description',
                  style: GoogleFonts.inter(color: scheme.onBackground)),
              const SizedBox(height: 5),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: _inputDecoration(
                  context,
                  isTextArea: true,
                  hintText: 'Enter schedule description (optional)',
                ),
                style: GoogleFonts.inter(color: scheme.onSurface),
              ),
              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 110,
                  child: ElevatedButton(
                    onPressed: (_isSaving || !_isTimeValid) ? null : _saveSchedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Save',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
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

  InputDecoration _inputDecoration(
    BuildContext context, {
    Widget? suffixIcon,
    bool isTextArea = false,
    String? hintText,
    String? errorText,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return InputDecoration(
      filled: true,
      fillColor: scheme.surface,
      contentPadding: isTextArea
          ? const EdgeInsets.all(15)
          : const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      suffixIcon: suffixIcon,
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        color: scheme.onSurface.withOpacity(0.6),
        fontSize: 14,
      ),
      errorText: errorText,
      errorStyle: GoogleFonts.inter(
        color: scheme.error,
        fontSize: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outline, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outline, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.error, width: 2.0),
      ),
    );
  }
}