// lib/widgets/add_options_fab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

typedef VoidCallbackNoArgs = void Function();

class AddOptionsFab extends StatelessWidget {
  final bool showAddOptions;
  final VoidCallback onToggle; // toggle show/hide
  final VoidCallbackNoArgs onAddSchedule;
  final VoidCallbackNoArgs onAddNote;
  final VoidCallbackNoArgs onAddAssignment;
  final bool disabled; // jika true, FAB tidak tampil (mis. di tab tertentu)

  const AddOptionsFab({
    super.key,
    required this.showAddOptions,
    required this.onToggle,
    required this.onAddSchedule,
    required this.onAddNote,
    required this.onAddAssignment,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (disabled) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // overlay sementara (tutup jika ketuk area di luar opsi)
        if (showAddOptions)
          Positioned.fill(
            child: GestureDetector(
              onTap: onToggle,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),

        // option buttons (posisi di atas FAB)
        if (showAddOptions)
          Positioned(
            right: 16,
            bottom: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildOptionButton(
                  title: 'Schedule',
                  icon: Icons.schedule,
                  onPressed: onAddSchedule,
                ),
                const SizedBox(height: 10),
                _buildOptionButton(
                  title: 'Note',
                  icon: Icons.note_add,
                  onPressed: onAddNote,
                ),
                const SizedBox(height: 10),
                _buildOptionButton(
                  title: 'Assignment',
                  icon: Icons.assignment,
                  onPressed: onAddAssignment,
                ),
              ],
            ),
          ),

        // main FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: onToggle,
            backgroundColor: kAccentColor,
            shape: const CircleBorder(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: child),
              child: showAddOptions
                  ? const Icon(Icons.close, color: Colors.white, size: 30, key: ValueKey('close'))
                  : const Icon(Icons.add, color: Colors.white, size: 30, key: ValueKey('add')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    const double buttonWidth = 170;
    const double buttonHeight = 48;
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: kAccentColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            fixedSize: const Size(buttonWidth, buttonHeight),
          ),
          icon: Icon(icon, size: 20),
          label: Text('+ $title',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }
}
