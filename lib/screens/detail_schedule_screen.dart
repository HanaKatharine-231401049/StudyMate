// lib/screens/detail_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../models/schedule.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';

class DetailSchedulePage extends StatelessWidget {
  final Schedule schedule;

  /// onEdit should return a Future that resolves to the result from edit page (or null).
  final Future<dynamic> Function()? onEdit;

  /// onDelete should return Future<bool> -> true jika item benar-benar dihapus.
  final Future<bool> Function()? onDelete;

  const DetailSchedulePage({
    super.key,
    required this.schedule,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Schedule',
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
              _buildDetailItem('Title', schedule.title),
              const SizedBox(height: 20),
              _buildDetailItem('Date', schedule.date),
              const SizedBox(height: 20),
              _buildDetailItem('Time', schedule.time),
              const SizedBox(height: 20),
              _buildDetailItem('Description', schedule.description),
              const SizedBox(height: 40),

              // tombol edit & delete dalam Row - POSISI DIUBAH MENJADI END (KANAN)
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // Tetap di end (kanan)
                children: [
                  _buildActionButton(Icons.edit, kAccentColor, () async {
                    if (onEdit != null) {
                      final res = await onEdit!.call();
                      if (res != null) Navigator.pop(context, res);
                    } else {
                      Navigator.pop(context);
                    }
                  }),
                  const SizedBox(width: 20), // Spacing normal
                  _buildActionButton(Icons.delete, kDeleteColor, () async {
                    // tunggu hasil dari onDelete (true kalau dihapus)
                    if (onDelete != null) {
                      final bool? deleted = await onDelete!.call();
                      if (deleted == true) {
                        // beri tahu pemanggil bahwa item terhapus
                        Navigator.pop(context, {'deleted': true});
                      } else {
                        // jika batal, jangan pop atau lakukan apa-apa
                      }
                    } else {
                      // fallback: langsung pop
                      Navigator.pop(context);
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0, // Schedule tab index
        onTapIndex: (index) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => HomePage(initialIndex: index),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: kAccentColor,
          ),
        ),
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

  // helper action button - UKURAN DISAMAKAN
  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: 60, // Lebar ditambahkan untuk konsistensi
      height: 60, // Tinggi ditambahkan untuk konsistensi
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
}