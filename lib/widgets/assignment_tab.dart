// lib/widgets/assignment_tab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/assignment.dart';
import '../utils/colors.dart';

typedef AssignmentTapCallback = void Function(Assignment assignment);
typedef AssignmentToggleCallback = void Function(Assignment assignment);
typedef SubTabChanged = void Function(int index);

class AssignmentTab extends StatelessWidget {
  final List<Assignment> assignments;
  final int selectedSubTabIndex;
  final SubTabChanged onSubTabChanged;
  final AssignmentTapCallback onTapAssignment;
  final AssignmentToggleCallback onToggleStatus;

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
    List<Assignment> filtered = selectedSubTabIndex == 0
        ? assignments.where((a) => !a.isFinished).toList()
        : assignments.where((a) => a.isFinished).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              _buildAssignmentTabButton(0, 'Unfinished'),
              const SizedBox(width: 10),
              _buildAssignmentTabButton(1, 'Finished'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final assignment = filtered[index];
              return _buildAssignmentItem(context, assignment);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentTabButton(int index, String title) {
    bool isSelected = selectedSubTabIndex == index;
    return GestureDetector(
      onTap: () => onSubTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kAccentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kAccentColor.withOpacity(0.5)),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : kAccentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentItem(BuildContext context, Assignment assignment) {
    bool isFinished = assignment.isFinished;
    return GestureDetector(
      onTap: () => onTapAssignment(assignment),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: kInkTone.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: kInkTone),
                      const SizedBox(width: 5),
                      Text('${assignment.date}, ${assignment.time}',
                          style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(assignment.title,
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(assignment.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => onToggleStatus(assignment),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFinished ? kSuccessColor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isFinished ? kSuccessColor : Colors.transparent),
                ),
                child: Icon(
                  Icons.check,
                  color: isFinished ? Colors.white : kSuccessColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
