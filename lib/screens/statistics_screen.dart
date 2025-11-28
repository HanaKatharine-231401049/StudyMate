// statistics_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/assignment.dart';
import '../utils/colors.dart';

class StatisticsScreen extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    final assignments = widget.assignments;
    final int finishedCount = assignments.where((a) => a.isFinished).length;
    final int unfinishedCount = assignments.length - finishedCount;
    final int total = assignments.length;
    final double finishedPercent =
        total == 0 ? 0 : (finishedCount / total) * 100;
    final double unfinishedPercent =
        total == 0 ? 0 : (unfinishedCount / total) * 100;

    return Scaffold(
      // -> Hapus AppBar atau set ke null supaya kita kontrol panah di body
      appBar: null,
      backgroundColor: Colors.white,
      body: SafeArea(
        // Kita gunakan SingleChildScrollView, dan di paling atas kita tempatkan
        // bar kecil yang hanya berisi back arrow (menggunakan MediaQuery padding).
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.only(right: 20), // ganti dengan nilai responsif
                      icon: const Icon(Icons.arrow_back, color: kAccentColor),
                      onPressed: () => Navigator.of(context).pop()
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Here's your",
                                style: GoogleFonts.montserratAlternates(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "Progress",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.montserratAlternates(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF03045E),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const 
                            Icon(Icons.person,
                                color: kInkTone,
                                size: 30),
                          ),
                        ]),
              ]),

              SizedBox(height: 8), // ganti dengan nilai yang responsif

              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  setState(() {
                    _selectedMonth = value;
                  });
                },
                itemBuilder: (context) {
                  return _months.map((m) {
                    return PopupMenuItem<String>(
                      value: m,
                      child: Text(m, style: GoogleFonts.inter(fontSize: 13)),
                    );
                  }).toList();
                },
                child: Container(
                  height: 40,
                  width: 140,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kAccentColor),
                    color: kBackgroundColor,
                  ),
                  child: Row(
                    mainAxisAlignment
                    : MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedMonth,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              color: kAccentColor,
                              fontWeight: FontWeight.w600)
                              ),
                              Icon(Icons.arrow_drop_down, color: kAccentColor),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Total Assignment Card ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kAccentColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Assignment',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF03045E),)),
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
                                          alignment: Alignment.center,
                                          children: [
                                            PieChart(
                                              PieChartData(
                                                sectionsSpace: 2,
                                                centerSpaceRadius: 60,
                                                startDegreeOffset: -90,
                                                sections: [
                                                  PieChartSectionData(
                                                    value: unfinishedCount
                                                        .toDouble(),
                                                    title: '',
                                                    radius: 20,
                                                    color: const Color.fromARGB(255, 162, 134, 227),
                                                  ),
                                                  PieChartSectionData(
                                                    value: finishedCount
                                                        .toDouble(),
                                                    title: '',
                                                    radius: 20,
                                                    color: const Color.fromARGB(255, 85, 166, 238),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Total Value',
                                                    style: GoogleFonts.inter(
                                                        fontSize: 12, )),
                                                const SizedBox(height: 6),
                                                Text('$total',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
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
                                            const Color.fromARGB(255, 162, 134, 227),
                                            'Unfinished',
                                            '$unfinishedCount • ${unfinishedPercent.toStringAsFixed(0)}%'),
                                        const SizedBox(height: 8),
                                        _legendRowItem(
                                            const Color.fromARGB(255, 85, 166, 238),
                                            'Finished',
                                            '$finishedCount • ${finishedPercent.toStringAsFixed(0)}%'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- Line chart (Total Study Hours) ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kAccentColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Study Hours',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold, 
                                    color: const Color(0xFF03045E),)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 180,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                      show: true, drawVerticalLine: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 36)),
                                    bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              final idx = value.toInt();
                                              final labels = [
                                                'WEEK 1',
                                                'WEEK 2',
                                                'WEEK 3',
                                                'WEEK 4'
                                              ];
                                              if (idx >= 0 &&
                                                  idx < labels.length)
                                                return Text(labels[idx],
                                                    style: GoogleFonts.inter(
                                                        fontSize: 10));
                                              return const Text('');
                                            },
                                            interval: 1)),
                                  ),
                                  minX: 0,
                                  maxX: (widget.weeklyStudyHours.isEmpty
                                      ? 0
                                      : (widget.weeklyStudyHours.length - 1)
                                          .toDouble()),
                                  minY: 0,
                                  maxY: (widget.weeklyStudyHours.isNotEmpty
                                      ? (widget.weeklyStudyHours
                                              .reduce((a, b) => a > b ? a : b) +
                                          10)
                                      : 50),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(
                                          widget.weeklyStudyHours.length,
                                          (i) => FlSpot(i.toDouble(),
                                              widget.weeklyStudyHours[i])),
                                      isCurved: true,
                                      barWidth: 3,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(colors: [
                                            kAccentColor.withOpacity(0.25),
                                            kAccentColor.withOpacity(0.05)
                                          ])),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Summary
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: kBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kAccentColor)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Finished Assignment : $finishedCount',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: kAccentColor)),
                            const SizedBox(height: 8),
                            Text(
                                'Total Study Hours : ${_sumHours(widget.weeklyStudyHours)} hours',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: kAccentColor)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendRowItem(Color c, String label, String value) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: c, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12)),
          Text(value,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
        ])),
      ],
    );
  }

  int _sumHours(List<double> hours) {
    double s = 0;
    for (var h in hours) s += h;
    return s.round();
  }
}
