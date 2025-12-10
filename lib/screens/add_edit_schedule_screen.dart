// lib/screens/add_edit_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../models/schedule.dart';
import '../widgets/calendar_picker.dart';

class AddEditSchedulePage extends StatefulWidget {
  final bool isEditing;
  final Schedule? schedule;

  const AddEditSchedulePage({super.key, required this.isEditing, this.schedule});

  @override
  State<AddEditSchedulePage> createState() => _AddEditSchedulePageState();
}

class _AddEditSchedulePageState extends State<AddEditSchedulePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _dateController.text = widget.schedule!.date;
      _timeController.text = widget.schedule!.time;
      _descriptionController.text = widget.schedule!.description;
    }
  }

  // Dalam method _saveSchedule, ganti dengan:

Future<void> _saveSchedule(BuildContext context) async {
  if (_titleController.text.trim().isEmpty ||
      _dateController.text.trim().isEmpty ||
      _timeController.text.trim().isEmpty) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Validation Error'),
        content: const Text('Please fill title, date and time.'),
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

  if (widget.isEditing && widget.schedule != null) {
    final updated = widget.schedule!.copyWith(
      title: _titleController.text.trim(),
      date: _dateController.text.trim(),
      time: _timeController.text.trim(),
      description: _descriptionController.text.trim(),
      updatedAt: DateTime.now(),
    );
    Navigator.pop(context, updated);
  } else {
    final created = Schedule(
      userId: '', // Akan diisi oleh HomeScreen
      title: _titleController.text.trim(),
      date: _dateController.text.trim(),
      time: _timeController.text.trim(),
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
          widget.isEditing ? 'Edit Schedule' : 'Add Schedule',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: kAccentColor,
          ),
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
              // Title Field
              Text('Title',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  )),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration(hintText: 'Enter schedule title'),
              ),
              const SizedBox(height: 20),

              // Date Field (gunakan CalendarPickerButton sebagai suffixIcon)
              Text('Date',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  )),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                // onTap left empty so only icon triggers picker; if you want tapping field to open picker too, enable onTap.
                decoration: _inputDecoration(
                  hintText: 'Select date',
                  suffixIcon: CalendarPickerButton(
                    initialDateString:
                        _dateController.text.isEmpty ? null : _dateController.text,
                    onDateSelected: (formatted) {
                      setState(() {
                        _dateController.text = formatted;
                      });
                    },
                    size: 36,
                    filled: false, // tanpa kotak biru di belakang ikon
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Time Field (diubah menjadi text field biasa)
              Text('Time',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  )),
              const SizedBox(height: 8),
              TextFormField(
                controller: _timeController,
                decoration: _inputDecoration(
                  hintText: 'Enter time (e.g., 10:30 - 11:20)',
                ),
              ),
              const SizedBox(height: 20),

              // Description Field
              Text('Description',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  )),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration:
                    _inputDecoration(hintText: 'Enter schedule description (optional)', isTextArea: true),
              ),
              const SizedBox(height: 40),

              // Save Button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () => _saveSchedule(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
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

  InputDecoration _inputDecoration({
    String? hintText,
    Widget? suffixIcon,
    bool isTextArea = false,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: kBackgroundColor,
      hintText: hintText,
      hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
      contentPadding:
          isTextArea ? const EdgeInsets.all(15) : const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
