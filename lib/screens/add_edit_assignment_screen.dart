import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../models/assignment.dart';
import '../utils/dialog_components.dart';

class AddEditAssignmentPage extends StatelessWidget {
  final bool isEditing;
  final Assignment? assignment;

  const AddEditAssignmentPage({super.key, required this.isEditing, this.assignment});

  void _saveAssignment(BuildContext context) {
    Navigator.pop(context); 
    showDialog(
      context: context,
      builder: (_) =>
          const SuccessDialog(title: 'Assignment saved successfully'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleController =
        TextEditingController(text: isEditing ? assignment!.title : 'Pemrograman Mobile');
    final dateController =
        TextEditingController(text: isEditing ? assignment!.date : '12 January 2025');
    final timeController =
        TextEditingController(text: isEditing ? assignment!.time : '11.00');
    final descriptionController = TextEditingController(
        text: isEditing ? assignment!.description : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris quam orci, convallis nec enim eu, hendrerit imperdiet tortor. Nulla scelerisque posuere ullamcorper. Sit amet....');

    return Scaffold(
      appBar: AppBar(
        title: Text('Assignment', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: kAccentColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kAccentColor),
          onPressed: () => Navigator.pop(context),
        ),
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
                controller: titleController,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 20),

              Text('Date', style: GoogleFonts.inter()),
              const SizedBox(height: 5),
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: _inputDecoration(suffixIcon: const Icon(Icons.calendar_today, color: kAccentColor)),
              ),
              const SizedBox(height: 20),

              Text('Time', style: GoogleFonts.inter()),
              const SizedBox(height: 5),
              TextFormField(
                controller: timeController,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 20),

              Text('Description', style: GoogleFonts.inter()),
              const SizedBox(height: 5),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: _inputDecoration(isTextArea: true),
              ),
              const SizedBox(height: 40),

              // Untuk mode editing dan add, sekarang hanya menampilkan tombol Save
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () => _saveAssignment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Save',
                        style: GoogleFonts.montserrat(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  InputDecoration _inputDecoration({Icon? suffixIcon, bool isTextArea = false}) {
    return InputDecoration(
      filled: true,
      fillColor: kBackgroundColor,
      contentPadding: isTextArea ? const EdgeInsets.all(15) : const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kAccentColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kAccentColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kAccentColor, width: 2.0),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(color: kAccentColor),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home, color: Colors.white, size: 30),
          Icon(Icons.access_time, color: Colors.white, size: 30),
          Icon(Icons.bar_chart, color: Colors.white, size: 30),
          Icon(Icons.music_note, color: Colors.white, size: 30),
          Icon(Icons.person, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}