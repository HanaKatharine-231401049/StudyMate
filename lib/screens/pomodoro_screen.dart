// lib/screens/pomodoro_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import 'full_screen_pomodoro.dart';
import 'set_timer_screen.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // default focus duration
  Duration _duration = const Duration(minutes: 25);
  Duration _current = Duration.zero;
  bool _running = false;
  Timer? _timer;

  // Dummy stats (only to compute "Focus Today" value)
  final List<double> _weeklyMinutes = [40, 60, 30, 90, 50, 80, 20];

  // Strict mode 
  bool _strictBlockNotifications = false;
  bool _strictBlockCalls = false;

  // Set timer 
  int _shortBreakMinutes = 5;
  int _sessions = 4;

  // Logika Timer
  void _toggleStartPause() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          _current += const Duration(seconds: 1);
          if (_current >= _duration) {
            _current = _duration;
            _timer?.cancel();
            _running = false;
          }
        });
      });
      setState(() => _running = true);
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _current = Duration.zero;
      _running = false;
    });
  }

  void _cycleDuration() {
    if (_duration.inMinutes == 25) {
      setState(() => _duration = const Duration(minutes: 50));
    } else if (_duration.inMinutes == 50) {
      setState(() => _duration = const Duration(minutes: 5));
    } else {
      setState(() => _duration = const Duration(minutes: 25));
    }
    _resetTimer();
  }

  String _formatDuration(Duration d) {
    final remaining = _duration - _current;
    final seconds = remaining.inSeconds.clamp(0, remaining.inSeconds);
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  String _minutesToHourMinute(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ===== UI building blocks =====

  Widget _buildTopHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF000000),
            ),
            children: [
              const TextSpan(text: "It's "),
              TextSpan(
                text: "focus time",
                style: const TextStyle(
                  color: Color(0xFF046CA6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: "!"),
            ],
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF000000),
            ),
            children: [
              const TextSpan(text: "Let's get those "),
              TextSpan(
                text: "goals",
                style: const TextStyle(
                  color: Color(0xFF046CA6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: " done"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerCard({required double cardWidth, required double circleBase}) {
    final double innerCircle = max(0.0, circleBase - 30);
    final double controlBtnSize = max(44.0, cardWidth * 0.13);
    final double playBtnPadding = max(16.0, cardWidth * 0.05);

    // NOTE: cardHeight reduced to avoid overflow
    final double cardHeight = 340.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E9EC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF03045E), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // circle
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: circleBase,
                height: circleBase,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kAccentColor.withOpacity(0.95),
                    width: 12,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kAccentColor.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              Container(
                width: innerCircle,
                height: innerCircle,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.9),
                ),
                alignment: Alignment.center,
                child: Text(
                  _formatDuration(_current),
                  style: GoogleFonts.montserratAlternates(
                    fontSize: max(18.0, innerCircle * 0.16),
                    fontWeight: FontWeight.bold,
                    color: kInkTone,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _smallRoundIconButton(Icons.refresh, _resetTimer, size: controlBtnSize),
              SizedBox(width: cardWidth * 0.06),
              ElevatedButton(
                onPressed: _toggleStartPause,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: kAccentColor,
                  padding: EdgeInsets.all(playBtnPadding + 4),
                  elevation: 4,
                ),
                child: Icon(
                  _running ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: max(28.0, cardWidth * 0.10),
                ),
              ),
              SizedBox(width: cardWidth * 0.06),
              _smallRoundIconButton(Icons.repeat, _cycleDuration, size: controlBtnSize),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallRoundIconButton(IconData icon, VoidCallback onPressed, {double size = 46}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: kBackgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: kInkTone.withOpacity(0.18)),
        ),
        child: Icon(icon, color: kInkTone, size: max(18.0, size * 0.44)),
      ),
    );
  }

  Widget _buildThreeOptionRow({required double cardWidth}) {
    final double gap = 10.0;
    final double optionWidth = (cardWidth - (gap * 2)) / 3;

    return SizedBox(
      width: cardWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildOptionCardSized(
              Icons.info_outline,
              'Strict Mode',
              width: optionWidth,
              onTap: _showStrictModeSheet,
            ),
            SizedBox(width: gap),
            _buildOptionCardSized(
              Icons.fullscreen,
              'Full Screen',
              width: optionWidth,
              onTap: _openFullScreen,
            ),
            SizedBox(width: gap),
            _buildOptionCardSized(
              Icons.timer,
              'Set Timer',
              width: optionWidth,
              onTap: _showSetTimerDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCardSized(IconData icon, String title, {required double width, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF03045E), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kAccentColor),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kInkTone,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusToday({required double cardWidth}) {
    final int todayIndex = (DateTime.now().weekday - 1) % 7;
    final int todayMinutes = _weeklyMinutes[todayIndex].round();

    return SizedBox(
      width: cardWidth,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFD9E9EC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF03045E), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: kAccentColor.withOpacity(0.12)),
              ),
              child: const Icon(Icons.lightbulb, color: kAccentColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Focus Today', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: kInkTone)),
                  const SizedBox(height: 6),
                  Text(
                    _minutesToHourMinute(todayMinutes),
                    style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w700, color: kInkTone),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Small sessions add up — keep going!',
                    style: GoogleFonts.roboto(fontSize: 11, fontWeight: FontWeight.w400, color: kInkTone.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStrictModeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allow taller sheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 36),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Strict Mode',
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          child: const Icon(Icons.clear, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Block All Notification', style: GoogleFonts.inter(fontSize: 16)),
                          ),
                          Switch(
                            value: _strictBlockNotifications,
                            onChanged: (v) {
                              setModalState(() => _strictBlockNotifications = v);
                              setState(() => _strictBlockNotifications = v);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(milliseconds: 700),
                                  content: Text(v ? 'Notifications blocked' : 'Notifications allowed', style: GoogleFonts.inter()),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 1),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Block Phone Calls', style: GoogleFonts.inter(fontSize: 16)),
                          ),
                          Switch(
                            value: _strictBlockCalls,
                            onChanged: (v) {
                              setModalState(() => _strictBlockCalls = v);
                              setState(() => _strictBlockCalls = v);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(milliseconds: 700),
                                  content: Text(v ? 'Phone calls blocked' : 'Phone calls allowed', style: GoogleFonts.inter()),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _openFullScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenPomodoro(
          duration: _duration,
          current: _current,
          running: _running,
        ),
      ),
    );

    // selalu rebuild parent agar SafeArea dan bottom nav dire-evaluasi
    if (result != null) {
      _timer?.cancel();
      setState(() {
        _current = result['current'] as Duration? ?? _current;
        _running = result['running'] as bool? ?? _running;
        _duration = result['duration'] as Duration? ?? _duration;
      });
    } else {
      // user mungkin menekan back system; tetap rebuild
      setState(() {});
    }

    // jika sekarang running, pastikan timer berjalan
    if (_running) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          _current += const Duration(seconds: 1);
          if (_current >= _duration) {
            _current = _duration;
            _timer?.cancel();
            _running = false;
          }
        });
      });
    }
  }
  
  Future<void> _showSetTimerDialog() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => SetTimerScreen(
          initialSessions: _sessions,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      if (result.containsKey('focus_total_minutes')) {
        final int focusMinutes = result['focus_total_minutes'] as int? ?? _duration.inMinutes;
        _duration = Duration(minutes: focusMinutes);
      } else if (result.containsKey('focus_minutes')) {
        final int focusMinutes = result['focus_minutes'] as int? ?? _duration.inMinutes;
        _duration = Duration(minutes: focusMinutes);
      }

      if (result.containsKey('break_total_seconds')) {
        final int breakSecs = result['break_total_seconds'] as int? ?? (_shortBreakMinutes * 60);
        _shortBreakMinutes = (breakSecs / 60).round();
      } else if (result.containsKey('break_minutes')) {
        _shortBreakMinutes = result['break_minutes'] as int? ?? _shortBreakMinutes;
      }

      if (result.containsKey('sessions')) {
        _sessions = (result['sessions'] as int?)?.clamp(1, 10) ?? _sessions;
      }

      // reset timer display
      _resetTimer();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text(
          'Timer updated — focus ${_duration.inMinutes}m • short ${_shortBreakMinutes}m • sessions ${_sessions}',
          style: GoogleFonts.inter(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    const double horizontalPadding = 16.0;
    final double cardWidth = screenWidth - (horizontalPadding * 2);
    final double circleBase = min(220.0, cardWidth * 0.68);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 28.0, 16.0, 14.0),
            child: _buildTopHeader(),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimerCard(cardWidth: cardWidth, circleBase: circleBase),

                  const SizedBox(height: 12),

                  _buildThreeOptionRow(cardWidth: cardWidth),

                  const SizedBox(height: 12),

                  _buildFocusToday(cardWidth: cardWidth),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
