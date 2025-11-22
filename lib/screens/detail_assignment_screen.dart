import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../models/assignment.dart';

class DetailAssignmentPage extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const DetailAssignmentPage({
    super.key,
    required this.assignment,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assignment',
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
              _buildDetailItem('Title', assignment.title),
              const SizedBox(height: 20),
              _buildDetailItem('Date', assignment.date),
              const SizedBox(height: 20),
              _buildDetailItem('Time', assignment.time),
              const SizedBox(height: 20),
              _buildDetailItem('Description', assignment.description),
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

  Widget _buildStatusItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, fontSize: 16, color: kAccentColor)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: assignment.isFinished ? kSuccessColor : Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                assignment.isFinished ? 'Finished' : 'Unfinished',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onToggleStatus,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: assignment.isFinished ? Colors.white : kSuccessColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: assignment.isFinished ? kSuccessColor : Colors.transparent),
                ),
                child: Icon(
                  assignment.isFinished ? Icons.refresh : Icons.check,
                  color: assignment.isFinished ? kSuccessColor : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // helper action button (sama gaya dengan AddEditAssignmentPage)
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
