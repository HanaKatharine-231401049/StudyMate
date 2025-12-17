import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/assignment.dart';
import '../utils/colors.dart';

class AssignmentTab extends StatelessWidget {
  final List<Assignment> assignments;

  /// 0 = Unfinished, 1 = Finished
  final int selectedSubTabIndex;
  final ValueChanged<int> onSubTabChanged;

  final void Function(Assignment) onTapAssignment;
  final void Function(Assignment) onToggleStatus;

  const AssignmentTab({
    super.key,
    required this.assignments,
    required this.selectedSubTabIndex,
    required this.onSubTabChanged,
    required this.onTapAssignment,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bool showUnfinished = selectedSubTabIndex == 0;
    final filtered = assignments.where((a) {
      return showUnfinished ? !a.isFinished : a.isFinished;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            children: [
              _buildSubTabButton(context, label: 'Unfinished', index: 0),
              const SizedBox(width: 8),
              _buildSubTabButton(context, label: 'Finished', index: 1),
            ],
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    showUnfinished
                        ? 'No unfinished assignments 🎉'
                        : 'No finished assignments yet',
                    style: GoogleFonts.inter(
                      color: scheme.onBackground.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final a = filtered[index];
                    return _buildAssignmentCard(context, a);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSubTabButton(
    BuildContext context, {
    required String label,
    required int index,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final bool isSelected = selectedSubTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSubTabChanged(index),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.primary),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: isSelected ? scheme.onPrimary : scheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Assignment a) {
    final scheme = Theme.of(context).colorScheme;

    final dateText = DateFormat('d MMM yyyy').format(a.dueDate);
    final timeText = DateFormat('HH:mm').format(a.dueDate);
    final dateTimeText = '$dateText, $timeText';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onTapAssignment(a),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outline.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(
                Icons.access_time,
                color: kAccentColor,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateTimeText,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (a.description.isNotEmpty)
                    Text(
                      a.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: scheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            GestureDetector(
              onTap: () => onToggleStatus(a),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white, 
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  color: a.isFinished
                      ? const Color(0xFF22C55E) 
                      : scheme.outline.withOpacity(0.4),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
