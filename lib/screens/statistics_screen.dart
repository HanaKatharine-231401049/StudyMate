import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/assignment.dart';
import '../models/focus_log.dart';

class StatisticsScreen extends StatefulWidget {
  /// Kept for compatibility, but the screen now reads data from Firestore directly.
  final List<Assignment> assignments;
  final List<double> weeklyStudyHours;

  const StatisticsScreen({
    super.key,
    required this.assignments,
    required this.weeklyStudyHours,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _selectedMonth = 'Month';
  final List<String> _months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  // ----------------- USER STREAM -----------------

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userDocStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _db.collection('users').doc(user.uid).snapshots();
  }

  // ----------------- MONTH RANGE HELPER -----------------

  /// Given _selectedMonth and current year, return [start, end) range.
  /// If _selectedMonth == 'Month', we use current month.
  (DateTime start, DateTime end) _getMonthRange() {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonthIndex = now.month - 1; // 0-based

    final String monthNameForFilter =
        _selectedMonth == 'Month' ? _months[currentMonthIndex] : _selectedMonth;

    int monthIdx = _months.indexOf(monthNameForFilter);
    if (monthIdx < 0) {
      // fallback: current month
      monthIdx = currentMonthIndex;
    }

    final int monthNumber = monthIdx + 1; // 1..12
    final start = DateTime(currentYear, monthNumber, 1);
    final end = (monthNumber == 12)
        ? DateTime(currentYear + 1, 1, 1)
        : DateTime(currentYear, monthNumber + 1, 1);

    return (start, end);
  }

  // ----------------- FIRESTORE STREAMS -----------------

  Stream<List<Assignment>> _assignmentsStreamForMonth(
      DateTime start, DateTime end) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('assignments')
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dueDate', isLessThan: Timestamp.fromDate(end))
        .orderBy('dueDate')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Assignment.fromDoc(d)).toList());
  }

  Stream<List<FocusLog>> _focusLogsStreamForMonth(
      DateTime start, DateTime end) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('focus_logs')
        .where('completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('completedAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('completedAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => FocusLog.fromDoc(d)).toList());
  }

  /// Bucket logs into 4 weeks based on **day of month**:
  /// 0 -> days 1–7, 1 -> 8–14, 2 -> 15–21, 3 -> 22–end.
  /// Returns hours [week1, week2, week3, week4].
  List<double> _computeWeeklyHoursForMonth(
      List<FocusLog> logs, DateTime monthStart, DateTime monthEnd) {
    final buckets = List<double>.filled(4, 0.0);

    for (final log in logs) {
      final t = log.completedAt;
      if (t.isBefore(monthStart) || !t.isBefore(monthEnd)) continue;
      if (t.month != monthStart.month || t.year != monthStart.year) continue;

      final int day = t.day;
      int index;
      if (day <= 7) {
        index = 0;
      } else if (day <= 14) {
        index = 1;
      } else if (day <= 21) {
        index = 2;
      } else {
        index = 3;
      }

      buckets[index] += log.durationSeconds / 3600.0; // seconds -> hours
    }

    return buckets;
  }

  int _sumHours(List<double> hours) {
    double s = 0;
    for (final h in hours) {
      s += h;
    }
    return s.round();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (monthStart, monthEnd) = _getMonthRange();

    // If somehow no user => simple fallback
    if (_auth.currentUser == null) {
      return Scaffold(
        backgroundColor: scheme.background,
        body: Center(
          child: Text(
            'No user logged in.',
            style: GoogleFonts.inter(color: scheme.onBackground),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: null,
      backgroundColor: scheme.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _userDocStream(),
          builder: (context, userSnap) {
            // --- USER DATA ---
            String username = '';
            String fullName = '';
            String displayName = '';
            ImageProvider? avatarImage;

            if (userSnap.hasData && userSnap.data?.data() != null) {
              final data = userSnap.data!.data()!;
              username = (data['username'] ?? '') as String;
              fullName = (data['fullName'] ?? '') as String;

              if (username.isNotEmpty) {
                displayName = username;
              } else if (fullName.isNotEmpty) {
                displayName = fullName;
              } else {
                displayName = 'Student';
              }

              final photoBase64 = data['photoBase64'] as String?;
              if (photoBase64 != null && photoBase64.isNotEmpty) {
                try {
                  final bytes = base64Decode(photoBase64);
                  avatarImage = MemoryImage(bytes);
                } catch (_) {
                  avatarImage = null;
                }
              }
            } else {
              displayName = 'Student';
            }

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top area (back + title + avatar + username)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        padding: const EdgeInsets.only(right: 20),
                        icon: Icon(Icons.arrow_back, color: scheme.primary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Texts on the left
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Here's your",
                                style: GoogleFonts.montserratAlternates(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onBackground,
                                ),
                              ),
                              Text(
                                "Progress",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.montserratAlternates(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (displayName.isNotEmpty)
                                Text(
                                  displayName,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        scheme.onBackground.withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),

                          // Avatar on the right
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: scheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: scheme.outline),
                              image: avatarImage != null
                                  ? DecorationImage(
                                      image: avatarImage,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: avatarImage == null
                                ? Icon(
                                    Icons.person,
                                    color: scheme.onSurface.withOpacity(0.8),
                                    size: 30,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Month selector (affects queries)
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      setState(() => _selectedMonth = value);
                    },
                    itemBuilder: (context) {
                      return _months.map((m) {
                        return PopupMenuItem<String>(
                          value: m,
                          child: Text(
                            m,
                            style: GoogleFonts.inter(fontSize: 13),
                          ),
                        );
                      }).toList();
                    },
                    child: Container(
                      height: 40,
                      width: 140,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: scheme.primary),
                        color: scheme.surface,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedMonth,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: scheme.primary),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // === Total Assignment Card (filtered by month) ===
                          StreamBuilder<List<Assignment>>(
                            stream: _assignmentsStreamForMonth(
                                monthStart, monthEnd),
                            builder: (context, snapshot) {
                              final assignments =
                                  snapshot.data ?? <Assignment>[];

                              final int finishedCount = assignments
                                  .where((a) => a.isFinished)
                                  .length;
                              final int total = assignments.length;
                              final int unfinishedCount =
                                  total - finishedCount;

                              final double finishedPercent =
                                  total == 0 ? 0 : (finishedCount / total) * 100;
                              final double unfinishedPercent = total == 0
                                  ? 0
                                  : (unfinishedCount / total) * 100;

                              // theme-aware colors for pie + legend
                              final bool isDark =
                                  Theme.of(context).brightness ==
                                      Brightness.dark;

                              final Color unfinishedColor = isDark
                                  ? const Color(0xFF9F7AEA) // soft purple (dark)
                                  : const Color(0xFF7C3AED); // purple (light)

                              final Color finishedColor = isDark
                                  ? const Color(0xFF4FD1C5) // teal (dark)
                                  : const Color(0xFF0EA5E9); // cyan/blue (light)

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: scheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: scheme.outline),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Assignment',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 180,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: SizedBox(
                                                width: 160,
                                                height: 160,
                                                child: Stack(
                                                  alignment:
                                                      Alignment.center,
                                                  children: [
                                                    PieChart(
                                                      PieChartData(
                                                        sectionsSpace: 2,
                                                        centerSpaceRadius: 60,
                                                        startDegreeOffset:
                                                            -90,
                                                        sections: [
                                                          PieChartSectionData(
                                                            value:
                                                                unfinishedCount
                                                                    .toDouble(),
                                                            title: '',
                                                            radius: 20,
                                                            color:
                                                                unfinishedColor,
                                                          ),
                                                          PieChartSectionData(
                                                            value:
                                                                finishedCount
                                                                    .toDouble(),
                                                            title: '',
                                                            radius: 20,
                                                            color:
                                                                finishedColor,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Total Value',
                                                          style: GoogleFonts
                                                              .inter(
                                                            fontSize: 12,
                                                            color: scheme
                                                                .onSurface
                                                                .withOpacity(
                                                                    0.7),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        Text(
                                                          '$total',
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            color: scheme
                                                                .onSurface,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 120,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _legendRowItem(
                                                  context,
                                                  unfinishedColor,
                                                  'Unfinished',
                                                  '$unfinishedCount • ${unfinishedPercent.toStringAsFixed(0)}%',
                                                ),
                                                const SizedBox(height: 8),
                                                _legendRowItem(
                                                  context,
                                                  finishedColor,
                                                  'Finished',
                                                  '$finishedCount • ${finishedPercent.toStringAsFixed(0)}%',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // === Study Hours & Summary (based on month) ===
                          StreamBuilder<List<FocusLog>>(
                            stream: _focusLogsStreamForMonth(
                                monthStart, monthEnd),
                            builder: (context, snapLogs) {
                              final logs = snapLogs.data ?? <FocusLog>[];
                              final weeklyHours =
                                  _computeWeeklyHoursForMonth(
                                      logs, monthStart, monthEnd);
                              final totalHours = _sumHours(weeklyHours);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Line chart for 4 calendar weeks of selected month
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: scheme.surface,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border:
                                          Border.all(color: scheme.outline),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Study Hours',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            color: scheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: 180,
                                          child: LineChart(
                                            LineChartData(
                                              gridData: FlGridData(
                                                show: true,
                                                drawVerticalLine: false,
                                                horizontalInterval: 1,
                                                getDrawingHorizontalLine:
                                                    (value) => FlLine(
                                                  color: scheme.outline
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                              titlesData: FlTitlesData(
                                                leftTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize: 32,
                                                    getTitlesWidget:
                                                        (value, meta) {
                                                      return Text(
                                                        value
                                                            .toInt()
                                                            .toString(),
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 10,
                                                          color: scheme
                                                              .onSurface
                                                              .withOpacity(
                                                                  0.7),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    interval: 1,
                                                    getTitlesWidget:
                                                        (value, meta) {
                                                      final idx =
                                                          value.toInt();
                                                      final labels = [
                                                        '1-7',
                                                        '8-14',
                                                        '15-21',
                                                        '22-End'
                                                      ];
                                                      if (idx >= 0 &&
                                                          idx <
                                                              labels.length) {
                                                        return Text(
                                                          labels[idx],
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 10,
                                                            color: scheme
                                                                .onSurface
                                                                .withOpacity(
                                                                    0.7),
                                                          ),
                                                        );
                                                      }
                                                      return const Text('');
                                                    },
                                                  ),
                                                ),
                                                topTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false),
                                                ),
                                                rightTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false),
                                                ),
                                              ),
                                              borderData: FlBorderData(
                                                show: false,
                                              ),
                                              minX: 0,
                                              maxX: 3,
                                              minY: 0,
                                              maxY: weeklyHours
                                                      .where((h) => h > 0)
                                                      .isNotEmpty
                                                  ? (weeklyHours.reduce(
                                                          (a, b) =>
                                                              a > b ? a : b) +
                                                      1)
                                                  : 1,
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots: List.generate(
                                                    4,
                                                    (i) => FlSpot(
                                                      i.toDouble(),
                                                      i < weeklyHours.length
                                                          ? weeklyHours[i]
                                                          : 0.0,
                                                    ),
                                                  ),
                                                  isCurved: true,
                                                  barWidth: 3,
                                                  color: scheme.primary,
                                                  dotData: FlDotData(
                                                    show: true,
                                                    getDotPainter: (spot,
                                                            percent,
                                                            barData,
                                                            index) =>
                                                        FlDotCirclePainter(
                                                      radius: 3,
                                                      color: scheme.primary,
                                                      strokeWidth: 1,
                                                      strokeColor:
                                                          scheme.background,
                                                    ),
                                                  ),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        scheme.primary
                                                            .withOpacity(
                                                                0.25),
                                                        scheme.primary
                                                            .withOpacity(
                                                                0.05),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Summary (Finished assignments + total hours in month)
                                  StreamBuilder<List<Assignment>>(
                                    stream: _assignmentsStreamForMonth(
                                        monthStart, monthEnd),
                                    builder:
                                        (context, snapAssignments) {
                                      final assignments =
                                          snapAssignments.data ??
                                              <Assignment>[];
                                      final finishedCount = assignments
                                          .where((a) => a.isFinished)
                                          .length;

                                      return Container(
                                        width: double.infinity,
                                        padding:
                                            const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: scheme.surface,
                                          borderRadius:
                                              BorderRadius.circular(
                                                  12),
                                          border: Border.all(
                                              color: scheme.outline),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Finished Assignment : $finishedCount',
                                              style: GoogleFonts.inter(
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 14,
                                                color: scheme.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Total Study Hours : $totalHours hours',
                                              style: GoogleFonts.inter(
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 14,
                                                color: scheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _legendRowItem(
    BuildContext context,
    Color c,
    String label,
    String value,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: scheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}