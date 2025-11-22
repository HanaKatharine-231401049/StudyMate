import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart'; 
import '../models/note.dart'; 
import '../utils/dialog_components.dart'; 

class AddEditNotePage extends StatefulWidget {
  final bool isEditing;
  final Note? note;

  const AddEditNotePage({super.key, required this.isEditing, this.note});

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Hanya isi controller jika sedang edit dan note tidak null
    if (widget.isEditing && widget.note != null) {
      _titleController.text = widget.note!.title;
      _dateController.text = widget.note!.date;
      _descriptionController.text = widget.note!.description;
    }
  }

  void _saveNote(BuildContext context) {
    Navigator.pop(context); 
    showDialog(
      context: context,
      builder: (_) => SuccessDialog(
        title: 'Note ${widget.isEditing ? 'updated' : 'saved'} successfully',
        onConfirm: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDeleteNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Are you sure want to delete note?',
        icon: Icons.delete_forever,
        onConfirm: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (innerCtx) => SuccessDialog(
                title: 'Note deleted successfully',
                onConfirm: () {
                  Navigator.pop(innerCtx);
                },
              ),
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: kAccentColor)),
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
                controller: _titleController,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 20),

              Text('Date', style: GoogleFonts.inter()),
              const SizedBox(height: 5),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: _inputDecoration(suffixIcon: const Icon(Icons.calendar_today, color: kAccentColor)),
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

              // Untuk mode editing dan add, sekarang hanya menampilkan tombol Save
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