// lib/widgets/header_tabs.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        _buildHeaderTabButton(context, 0, 'Schedule'),
        const SizedBox(width: 10),
        _buildHeaderTabButton(context, 1, 'Notes'),
        const SizedBox(width: 10),
        _buildHeaderTabButton(context, 2, 'Assignment'),
      ],
    );
  }

  Widget _buildHeaderTabButton(BuildContext context, int index, String title) {
    final scheme = Theme.of(context).colorScheme;
    final bool isSelected = selectedIndex == index;

    final Color bgColor =
        isSelected ? scheme.primary : scheme.surface;
    final Color textColor =
        isSelected ? scheme.onPrimary : scheme.onSurface;
    final Color borderColor = isSelected
        ? scheme.primary
        : scheme.outline.withOpacity(0.7);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.inter(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
