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
        title: Text('Note Details', 
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: kAccentColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kAccentColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: kAccentColor),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: kDeleteColor),
            onPressed: onDelete,
          ),
        ],
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
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: kAccentColor)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kAccentColor.withOpacity(0.3)),
          ),
          child: Text(value, 
              style: GoogleFonts.inter(fontSize: 16)),
        ),
      ],
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