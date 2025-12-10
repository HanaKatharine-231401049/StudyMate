// lib/screens/add_edit_note_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../models/note.dart';
import '../widgets/calendar_picker.dart';

class AddEditNotePage extends StatelessWidget {
  final bool isEditing;
  final Note? note;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  AddEditNotePage({super.key, required this.isEditing, this.note}) {
    if (isEditing && note != null) {
      _titleController.text = note!.title;
      _dateController.text = note!.date;
      _descriptionController.text = note!.description;
    }
  }

  // Dalam method _saveNote, ganti dengan:

Future<void> _saveNote(BuildContext context) async {
  if (_titleController.text.trim().isEmpty || _dateController.text.trim().isEmpty) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Validation'),
        content: const Text('Please fill title and date.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  if (isEditing && note != null) {
    final updated = note!.copyWith(
      title: _titleController.text.trim(),
      date: _dateController.text.trim(),
      description: _descriptionController.text.trim(),
      updatedAt: DateTime.now(),
    );
    Navigator.pop(context, updated);
  } else {
    final created = Note(
      userId: '', // Akan diisi oleh HomeScreen
      title: _titleController.text.trim(),
      date: _dateController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    Navigator.pop(context, created);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Note' : 'Add Note',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: kAccentColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kAccentColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kAccentColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title', style: GoogleFonts.inter()),
              const SizedBox(height: 5),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 20),

              Text('Date', style: GoogleFonts.inter()),
              const SizedBox(height: 5),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                // gunakan CalendarPickerButton sebagai suffixIcon tanpa background
                decoration: _inputDecoration(
                  suffixIcon: CalendarPickerButton(
                    initialDateString: _dateController.text.isEmpty ? null : _dateController.text,
                    onDateSelected: (formatted) {
                      _dateController.text = formatted;
                    },
                    size: 36,
                    filled: false, // tanpa kotak biru di belakang ikon
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text('Description', style: GoogleFonts.inter()),
              const SizedBox(height: 5),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration(isTextArea: true),
              ),
              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () => _saveNote(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Save', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({Widget? suffixIcon, bool isTextArea = false}) {
    return InputDecoration(
      filled: true,
      fillColor: kBackgroundColor,
      contentPadding: isTextArea ? const EdgeInsets.all(15) : const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: kAccentColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: kAccentColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: kAccentColor, width: 2.0),
      ),
    );
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
