// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import '../utils/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTapIndex;

  const BottomNavBar({
    super.key,
    this.selectedIndex = 0,
    required this.onTapIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        height: 60,
        color: kAccentColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => onTapIndex(0),
              child: const Icon(Icons.home, color: Colors.white, size: 30),
            ),
            GestureDetector(
              onTap: () => onTapIndex(5),
              child: const Icon(Icons.access_time, color: Colors.white, size: 30),
            ),
            GestureDetector(
              onTap: () => onTapIndex(3),
              child: const Icon(Icons.bar_chart, color: Colors.white, size: 30),
            ),
            GestureDetector(
              onTap: () => onTapIndex(4),
              child: const Icon(Icons.music_note, color: Colors.white, size: 30),
            ),
            GestureDetector(
              onTap: () => onTapIndex(6),
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
