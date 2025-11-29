// lib/widgets/header_tabs.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

class HeaderTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const HeaderTabs({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildHeaderTabButton(0, 'Schedule'),
        const SizedBox(width: 10),
        _buildHeaderTabButton(1, 'Notes'),
        const SizedBox(width: 10),
        _buildHeaderTabButton(2, 'Assignment'),
      ],
    );
  }

  Widget _buildHeaderTabButton(int index, String title) {
    bool isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? kInkTone : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kInkTone.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : kInkTone,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
