import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/assignment.dart';
import '../utils/colors.dart';

class StatisticsContent extends StatefulWidget {
  final List<Assignment> assignments;
  final List<double> weeklyStudyHours;

  const StatisticsContent({
    Key? key,
    required this.assignments,
    required this.weeklyStudyHours,
  }) : super(key: key);

  @override
  State<StatisticsContent> createState() => _StatisticsContentState();
}

class _StatisticsContentState extends State<StatisticsContent> {
  String _selectedMonth = 'January';
  final List<String> _months = const [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];

  int _sumHours(List<double> hours) {
    double s = 0;
    for (var h in hours) s += h;
    return s.round();
  }

  @override
  Widget build(BuildContext context) {
    final int finishedCount = widget.assignments.where((a) => a.isFinished).length;
    final int unfinishedCount = widget.assignments.length - finishedCount;
    final int total = widget.assignments.length;
    final double finishedPercent = total == 0 ? 0 : (finishedCount / total) * 100;
    final double unfinishedPercent = total == 0 ? 0 : (unfinishedCount / total) * 100;

    return CustomScrollView(
        slivers: [
          // --- STICKY HEADER ---
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 140.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Profile Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: kAccentColor),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        
                        // Title
                        Expanded(
                          child: Column(
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
                              const SizedBox(height: 4),
                              Text(
                                'Progress',
                                style: GoogleFonts.montserratAlternates(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: kAccentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Profile icon
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.person, color: kInkTone, size: 30),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PopupMenuButton<String>(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_selectedMonth,
                              style: GoogleFonts.inter(
                                  fontSize: 14, 
                                  color: kAccentColor, 
                                  fontWeight: FontWeight.w600)),
                          Icon(Icons.arrow_drop_down, color: kAccentColor),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- CONTENT ---
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Total Assignment Card
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
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 180,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Pie chart + center label
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
                                              sectionsSpace: 4,
                                              centerSpaceRadius: 40,
                                              startDegreeOffset: -90,
                                              sections: [
                                                PieChartSectionData(
                                                  value: unfinishedCount.toDouble(),
                                                  title: '',
                                                  radius: 36,
                                                  color: kAccentColor,
                                                ),
                                                PieChartSectionData(
                                                  value: finishedCount.toDouble(),
                                                  title: '',
                                                  radius: 36,
                                                  color: kSuccessColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Center label
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Total Value', 
                                                  style: GoogleFonts.inter(fontSize: 12)),
                                              const SizedBox(height: 6),
                                              Text('$total', 
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 20, 
                                                      fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Legend
                                Flexible(
                                  flex: 0,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 140),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _legendItem(kAccentColor, 'Unfinished', '$unfinishedCount • ${unfinishedPercent.toStringAsFixed(0)}%'),
                                        const SizedBox(height: 8),
                                        _legendItem(kSuccessColor, 'Finished', '$finishedCount • ${finishedPercent.toStringAsFixed(0)}%'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Line chart (Total Study Hours)
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
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 180,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true, drawVerticalLine: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                                    showTitles: true, 
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      final labels = ['WEEK 1', 'WEEK 2', 'WEEK 3', 'WEEK 4'];
                                      if (idx >= 0 && idx < labels.length) 
                                        return Text(labels[idx], style: GoogleFonts.inter(fontSize: 10));
                                      return const Text('');
                                    }, 
                                    interval: 1
                                  )),
                                ),
                                minX: 0,
                                maxX: (widget.weeklyStudyHours.isEmpty ? 0 : (widget.weeklyStudyHours.length - 1).toDouble()),
                                minY: 0,
                                maxY: (widget.weeklyStudyHours.isNotEmpty ? (widget.weeklyStudyHours.reduce((a, b) => a > b ? a : b) + 10) : 50),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: List.generate(widget.weeklyStudyHours.length, 
                                        (i) => FlSpot(i.toDouble(), widget.weeklyStudyHours[i])),
                                    isCurved: true,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true, 
                                      gradient: LinearGradient(colors: [
                                        kAccentColor.withOpacity(0.25), 
                                        kAccentColor.withOpacity(0.05)
                                      ])
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

                    // Summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kAccentColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Finished Assignment : $finishedCount',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, 
                                fontSize: 14, 
                                color: kAccentColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Study Hours : ${_sumHours(widget.weeklyStudyHours)} hours',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, 
                                fontSize: 14, 
                                color: kAccentColor),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ]),
          ),
        ],
    );
  }

  Widget _legendItem(Color c, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12, 
          height: 12, 
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 12)),
              Text(value, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
            ]
          ),
        ),
      ],
    );
  }
}