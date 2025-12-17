import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/assignment.dart';
import '../widgets/calendar_picker.dart';
import '../services/study_service.dart';
import '../utils/date_utils.dart';

class AddEditAssignmentPage extends StatefulWidget {
  final bool isEditing;
  final Assignment? assignment;

  const AddEditAssignmentPage({
    super.key,
    required this.isEditing,
    this.assignment,
  });

  @override
  State<AddEditAssignmentPage> createState() => _AddEditAssignmentPageState();
}

class _AddEditAssignmentPageState extends State<AddEditAssignmentPage> {
  late final TextEditingController titleController;
  late final TextEditingController dateController; 
  late final TextEditingController timeController; 
  late final TextEditingController descriptionController;

  late final String uid;
  bool _isSaving = false;
  bool _isTimeValid = true;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User must be logged in to add/edit assignments.');
    }
    uid = user.uid;

    final a = widget.assignment;

    titleController = TextEditingController(
      text: widget.isEditing && a != null ? a.title : '',
    );

    dateController = TextEditingController(
      text: widget.isEditing && a != null ? a.dateString : '',
    );

    timeController = TextEditingController(
      text: widget.isEditing && a != null ? a.time : '',
    );

    descriptionController = TextEditingController(
      text: widget.isEditing && a != null ? a.description : '',
    );

    // Validasi awal untuk waktu
    if (widget.isEditing && a != null && a.time.isNotEmpty) {
      _validateTimeFormat(a.time);
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

  /// Validasi format waktu
  void _validateTimeFormat(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      setState(() => _isTimeValid = true);
      return;
    }

    final pattern = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    final pattern2 = RegExp(r'^[0-9]{1,2}:[0-9]{2}$');
    
    bool isValid = pattern.hasMatch(trimmed) || pattern2.hasMatch(trimmed);
    
    if (isValid) {
      final parts = trimmed.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        
        if (hour == null || minute == null) {
          isValid = false;
        } else if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
          isValid = false;
        }
      }
    }
    
    setState(() => _isTimeValid = isValid);
  }

  TimeOfDay? _parseTimeOfDay(String input) {
    final cleaned = input.trim();
    if (cleaned.isEmpty) return null;
    
    final parts = cleaned.split(':');
    if (parts.length != 2) return null;
    
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _saveAssignment() async {
    if (_isSaving) return;

    final title = titleController.text.trim();
    final dateStr = dateController.text.trim();
    final timeStr = timeController.text.trim();
    final desc = descriptionController.text.trim();

    if (title.isEmpty || dateStr.isEmpty || timeStr.isEmpty) {
      _showDialog('Please fill title, date and time.');
      return;
    }

    final dateOnly = DateUtilsHelper.tryParse(dateStr);
    if (dateOnly == null) {
      _showDialog('Invalid date. Please pick a valid date.');
      return;
    }

    final timeOfDay = _parseTimeOfDay(timeStr);
    if (timeOfDay == null) {
      _showDialog('Invalid time format. Please use format HH:mm (e.g., 18:00 or 9:30)');
      return;
    }

    final dueDate = DateTime(
      dateOnly.year,
      dateOnly.month,
      dateOnly.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    setState(() => _isSaving = true);

    try {
      final service = StudyService();

      if (widget.isEditing && widget.assignment != null) {
        await service.updateAssignment(
          uid: uid,
          assignmentId: widget.assignment!.id,
          title: title,
          dueDate: dueDate,     
          time: timeStr,        
          description: desc,
          isFinished: widget.assignment!.isFinished,
        );

        final updated = widget.assignment!.copyWith(
          title: title,
          dueDate: dueDate,
          time: timeStr,
          description: desc,
        );

        if (mounted) Navigator.pop(context, updated);
      } else {
        final newId = await service.addAssignment(
          uid: uid,
          title: title,
          dueDate: dueDate,     
          time: timeStr,
          description: desc,
        );

        final created = Assignment(
          id: newId,
          title: title,
          dueDate: dueDate,
          time: timeStr,
          description: desc,
          isFinished: false,
        );

        if (mounted) Navigator.pop(context, created);
      }
    } catch (e) {
      _showDialog('Failed to save assignment.\n$e');
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
          widget.isEditing ? 'Edit Assignment' : 'Add Assignment',
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
                  hintText: 'Enter assignment title',
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
                  hintText: 'HH:mm (e.g., 18:00 or 9:30)',
                  errorText: _isTimeValid ? null : 'Format harus HH:mm (0-23:0-59)',
                ),
                style: GoogleFonts.inter(color: scheme.onSurface),
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  _validateTimeFormat(value);
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
                  hintText: 'Enter assignment description (optional)',
                ),
                style: GoogleFonts.inter(color: scheme.onSurface),
              ),
              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 110,
                  child: ElevatedButton(
                    onPressed: (_isSaving || !_isTimeValid) ? null : _saveAssignment,
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