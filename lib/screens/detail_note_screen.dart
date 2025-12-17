import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';

class DetailNotePage extends StatelessWidget {
  final Note note;

  final Future<dynamic> Function()? onEdit;
  final Future<bool> Function()? onDelete;

  const DetailNotePage({
    super.key,
    required this.note,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: scheme.primary),
        title: Text(
          'Note',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem(context, 'Title', note.title),
              const SizedBox(height: 20),
              _buildDetailItem(context, 'Date', note.date),
              const SizedBox(height: 20),
              _buildDetailItem(context, 'Description', note.description),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    context,
                    Icons.edit,
                    scheme.primary,
                    scheme.onPrimary,
                    () async {
                      if (onEdit != null) {
                        final res = await onEdit!.call();
                        if (res != null) Navigator.pop(context, res);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildActionButton(
                    context,
                    Icons.delete,
                    scheme.error,
                    scheme.onError,
                    () async {
                      if (onDelete != null) {
                        final bool? deleted = await onDelete!.call();
                        if (deleted == true) {
                          Navigator.pop(context, {'deleted': true});
                        }
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
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

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: scheme.onBackground, 
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scheme.outline),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    Color bgColor,
    Color fgColor,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: fgColor, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}
