import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/note.dart';
import '../widgets/calendar_picker.dart';
import '../services/study_service.dart';

class AddEditNotePage extends StatefulWidget {
  final bool isEditing;
  final Note? note;

  const AddEditNotePage({
    super.key,
    required this.isEditing,
    this.note,
  });

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _descCtrl;

  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final note = widget.note;
    _titleCtrl = TextEditingController(text: widget.isEditing && note != null ? note.title : '');
    _dateCtrl  = TextEditingController(text: widget.isEditing && note != null ? note.date  : '');
    _descCtrl  = TextEditingController(text: widget.isEditing && note != null ? note.description : '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _dateCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ---------- UI helpers ----------

  void _showDialog(String title, String msg) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: scheme.surface,
        title: Text(title, style: GoogleFonts.inter(color: scheme.onSurface)),
        content: Text(msg, style: GoogleFonts.inter(color: scheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.inter(color: scheme.primary)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required ColorScheme scheme,
    Widget? suffixIcon,
    bool isTextArea = false,
    String? hintText,
  }) {
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
    );
  }

  // ---------- Date parsing (robust) ----------

  DateTime? _parseDate(String input) {
    // Normalize whitespace & remove weird unicode spaces
    var raw = input
        .replaceAll('\u00A0', ' ') // NBSP
        .replaceAll('\u202F', ' ') // narrow NBSP
        .replaceAll('\u2007', ' ') // figure space
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (raw.isEmpty) return null;

    // 1) Try built-in ISO parsing first
    //    e.g. "2025-12-11 00:00:00.000", "2025-12-11"
    final direct = DateTime.tryParse(raw);
    if (direct != null) {
      // keep only Y/M/D
      return DateTime(direct.year, direct.month, direct.day);
    }

    // 2) Fallback to formats like: "11 December 2025", "11 Dec 2025",
    //    "11 Desember 2025", etc.
    final match = RegExp(r'(\d{1,2})\s+([A-Za-z]+)\s*,?\s*(\d{4})')
        .firstMatch(raw);

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
  // ---------- Save logic ----------

  bool _validateInputs() {
    if (_titleCtrl.text.trim().isEmpty || _dateCtrl.text.trim().isEmpty) {
      _showDialog('Validation', 'Please fill title and date.');
      return false;
    }

    final parsed = _parseDate(_dateCtrl.text);
    if (parsed == null) {
      _showDialog('Validation', 'Invalid date. Please pick a valid date.');
      return false;
    }

    return true;
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;
    if (!_validateInputs()) return;

    final title = _titleCtrl.text.trim();
    final dateStr = _dateCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final dateObj = _parseDate(dateStr)!;

    setState(() => _isSaving = true);

    try {
      final service = StudyService();

      if (widget.isEditing && widget.note != null) {
        await service.updateNote(
          uid: _uid,
          noteId: widget.note!.id,
          title: title,
          date: dateObj,          // ✅ DateTime to Firestore
          description: desc,
        );

        final updated = widget.note!.copyWith(
          title: title,
          date: dateStr,          // keep UI string
          description: desc,
        );

        if (mounted) Navigator.pop(context, updated);
      } else {
        await service.addNote(
          uid: _uid,
          title: title,
          date: dateObj,          // ✅ DateTime to Firestore
          description: desc,
        );

        final created = Note(
          id: '',
          title: title,
          date: dateStr,          // keep UI string
          description: desc,
        );

        if (mounted) Navigator.pop(context, created);
      }
    } catch (e) {
      _showDialog('Error', 'Failed to save note.\n$e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------- Build ----------

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
          widget.isEditing ? 'Edit Note' : 'Add Note',
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
                controller: _titleCtrl,
                decoration: _inputDecoration(
                  scheme: scheme,
                  hintText: 'Enter note title',
                ),
                style: GoogleFonts.inter(color: scheme.onSurface),
              ),
              const SizedBox(height: 20),

              Text('Date', style: GoogleFonts.inter(color: scheme.onBackground)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: _inputDecoration(
                  scheme: scheme,
                  hintText: 'Select date',
                  suffixIcon: CalendarPickerButton(
                    initialDateString: _dateCtrl.text.isEmpty ? null : _dateCtrl.text,
                    onDateSelected: (formatted) {
                      setState(() => _dateCtrl.text = formatted);
                    },
                    size: 36,
                    filled: false,
                  ),
                ),
                style: GoogleFonts.inter(color: scheme.onSurface),
              ),
              const SizedBox(height: 20),

              Text('Description', style: GoogleFonts.inter(color: scheme.onBackground)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: _inputDecoration(
                  scheme: scheme, 
                  isTextArea: true,
                  hintText: 'Enter note description (optional)',
                ),
                style: GoogleFonts.inter(color: scheme.onSurface),
              ),
              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 110,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveNote,
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
}