import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final VoidCallback? onConfirm;
  const SuccessDialog({super.key, required this.title, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: kDialogColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 80, color: kAccentColor),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kAccentColor),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('OK',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: kDialogColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: kAccentColor),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kAccentColor),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kAccentColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('NO',
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDeleteColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('YES',
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}