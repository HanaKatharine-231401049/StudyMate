import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../models/note.dart';

class DetailNotePage extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DetailNotePage({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Note',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, color: kAccentColor),
        ),
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
              _buildDetailItem('Title', note.title),
              const SizedBox(height: 20),
              _buildDetailItem('Date', note.date),
              const SizedBox(height: 20),
              _buildDetailItem('Description', note.description),
              const SizedBox(height: 20),
              // tombol edit & delete dalam Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(Icons.edit, kAccentColor, onEdit),
                  const SizedBox(width: 20),
                  _buildActionButton(Icons.delete, kDeleteColor, onDelete),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, fontSize: 16, color: kAccentColor)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kAccentColor.withOpacity(0.3)),
          ),
          child: Text(value, style: GoogleFonts.inter(fontSize: 16)),
        ),
      ],
    );
  }

  // helper action button (sama gaya dengan AddEditNotePage)
  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 30),
        onPressed: onPressed,
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