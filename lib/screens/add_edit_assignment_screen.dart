// lib/screens/add_edit_assignment_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../models/assignment.dart';
import '../widgets/calendar_picker.dart';

class AddEditAssignmentPage extends StatelessWidget {
  final bool isEditing;
  final Assignment? assignment;

  const AddEditAssignmentPage({
    super.key,
    required this.isEditing,
    this.assignment,
  });

  @override
  Widget build(BuildContext context) {
    final titleController =
        TextEditingController(text: isEditing && assignment != null ? assignment!.title : '');
    final dateController =
        TextEditingController(text: isEditing && assignment != null ? assignment!.date : '');
    final timeController =
        TextEditingController(text: isEditing && assignment != null ? assignment!.time : '');
    final descriptionController = TextEditingController(
        text: isEditing && assignment != null ? assignment!.description : '');

    Future<void> _saveAssignment() async {
      // sederhana: cek required
      if (titleController.text.trim().isEmpty ||
          dateController.text.trim().isEmpty ||
          timeController.text.trim().isEmpty) {
        // show simple error
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Validation'),
            content: const Text('Please fill title, date and time.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
        return;
      }

      if (isEditing && assignment != null) {
        // buat object baru dengan perubahan -> kembalikan updated Assignment
        final updated = assignment!.copyWith(
          title: titleController.text.trim(),
          date: dateController.text.trim(),
          time: timeController.text.trim(),
          description: descriptionController.text.trim(),
        );
        Navigator.pop(context, updated);
      } else {
        final created = Assignment(
          titleController.text.trim(),
          dateController.text.trim(),
          timeController.text.trim(),
          descriptionController.text.trim(),
          isFinished: false,
        );
        Navigator.pop(context, created);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Assignment' : 'Add Assignment',
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
              TextFormField(controller: titleController, decoration: _inputDecoration()),
              const SizedBox(height: 20),

              Text('Date', style: GoogleFonts.inter()),
              const SizedBox(height: 5),
              // Gunakan CalendarPickerButton sebagai suffixIcon
              TextFormField(
                controller: dateController,
                readOnly: true,
                // jangan set onTap di sini: gunakan widget calendar sebagai trigger
                decoration: _inputDecoration(
                  suffixIcon: CalendarPickerButton(
                    initialDateString: dateController.text.isEmpty ? null : dateController.text,
                    onDateSelected: (formatted) {
                      dateController.text = formatted;
                    },
                    size: 44,
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text('Time', style: GoogleFonts.inter()),
              const SizedBox(height: 5),
              TextFormField(controller: timeController, decoration: _inputDecoration()),
              const SizedBox(height: 20),

              Text('Description', style: GoogleFonts.inter()),
              const SizedBox(height: 5),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: _inputDecoration(isTextArea: true),
              ),
              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: _saveAssignment,
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kAccentColor, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kAccentColor, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kAccentColor, width: 2.0)),
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
