// lib/screens/pomodoro_screen.dart
import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/focus_log_service.dart';
import 'full_screen_pomodoro.dart';
import 'set_timer_screen.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FocusLogService _focusLogService = FocusLogService();

  // Focus timer
  Duration _duration = const Duration(minutes: 25); // focus duration
  Duration _current = Duration.zero;
  bool _running = false;
  bool _isFocusPhase = true; // true = focus, false = break
  Timer? _timer;

  // Strict mode flags (in-app only)
  bool _strictBlockNotifications = false;
  bool _strictBlockCalls = false;

  // Config
  int _shortBreakMinutes = 5;
  int _sessions = 4;

  // Focus Today state (loaded only on open + after focus completed)
  int _focusTodayMinutes = 0;
  bool _focusTodayLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayFocusFromDb();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helper: themed SnackBar (works for light/dark)
  // ---------------------------------------------------------------------------
  void _showThemedSnackBar(
    String message, {
    Duration duration = const Duration(milliseconds: 900),
  }) {
    final scheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOAD TODAY'S FOCUS (ONE-SHOT)
  // ---------------------------------------------------------------------------
  Future<void> _loadTodayFocusFromDb() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _focusTodayMinutes = 0;
        _focusTodayLoading = false;
      });
      return;
    }

    setState(() {
      _focusTodayLoading = true;
    });

    try {
      final minutes =
          await _focusLogService.totalFocusMinutesForDay(user.uid, DateTime.now());

      if (!mounted) return;
      setState(() {
        _focusTodayMinutes = minutes;
        _focusTodayLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _focusTodayMinutes = 0;
        _focusTodayLoading = false;
      });

      _showThemedSnackBar(
        'Failed to load today\'s focus stats.',
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // TIMER LOGIC
  // ---------------------------------------------------------------------------

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _current += const Duration(seconds: 1);

        final phaseTotal =
            _isFocusPhase ? _duration : Duration(minutes: _shortBreakMinutes);

        if (_current >= phaseTotal) {
          _current = phaseTotal;
          _timer?.cancel();

          if (_isFocusPhase) {
            _onFocusCompleted();
          } else {
            _onBreakCompleted();
          }
        }
      });
    });
  }

  void _toggleStartPause() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _startTimer();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _current = Duration.zero;
      _running = false;
      _isFocusPhase = true;
    });
  }

  void _cycleDuration() {
    setState(() {
      if (_duration.inMinutes == 25) {
        _duration = const Duration(minutes: 50);
      } else if (_duration.inMinutes == 50) {
        _duration = const Duration(minutes: 5);
      } else {
        _duration = const Duration(minutes: 25);
      }
    });
    _resetTimer();
  }

  // Remaining time for current phase (focus/break)
  String _formatDuration() {
    final phaseTotal =
        _isFocusPhase ? _duration : Duration(minutes: _shortBreakMinutes);
    final remaining = phaseTotal - _current;
    final totalSeconds = remaining.inSeconds;
    final clamped = totalSeconds < 0 ? 0 : totalSeconds;

    final mm = (clamped ~/ 60).toString().padLeft(2, '0');
    final ss = (clamped % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  String _minutesToHourMinute(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  // Called when a focus session finishes
  void _onFocusCompleted() {
    _logFocusSession(); // Log to Firestore (and refresh today's total)

    // Auto switch to break
    _isFocusPhase = false;
    _current = Duration.zero;
    _running = true;

    if (mounted) {
      _showThemedSnackBar(
        'Focus session completed! Time for a $_shortBreakMinutes min break.',
        duration: const Duration(seconds: 2),
      );
    }

    // Start break timer
    _startTimer();
  }

  // Called when a break finishes
  void _onBreakCompleted() {
    _isFocusPhase = true;
    _current = Duration.zero;
    _running = false;

    if (mounted) {
      _showThemedSnackBar(
        'Break finished! Ready for the next focus session?',
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Firestore logging: users/{uid}/focus_logs
  Future<void> _logFocusSession() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _focusLogService.addFocusLog(
        uid: user.uid,
        durationSeconds: _duration.inSeconds,
        source: 'pomodoro',
      );

      // After logging, refresh today's total once
      await _loadTodayFocusFromDb();
    } catch (e) {
      if (!mounted) return;
      _showThemedSnackBar(
        'Error logging focus session: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ===== UI building blocks =====

  Widget _buildTopHeader() {
    final scheme = Theme.of(context).colorScheme;
    final phaseText = _isFocusPhase ? "focus time" : "break time";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: scheme.onBackground,
            ),
            children: [
              const TextSpan(text: "It's "),
              TextSpan(
                text: phaseText,
                style: TextStyle(
                  color: scheme.primary,
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
              color: scheme.onBackground,
            ),
            children: [
              const TextSpan(text: "Let's get those "),
              TextSpan(
                text: "goals",
                style: TextStyle(
                  color: scheme.primary,
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

  Widget _buildTimerCard({
    required double cardWidth,
    required double circleBase,
    required double cardHeight,
  }) {
    final scheme = Theme.of(context).colorScheme;

    final double innerCircle = max(0.0, circleBase - 30);
    final double controlBtnSize = max(44.0, cardWidth * 0.13);
    final double playBtnPadding = max(16.0, cardWidth * 0.05);

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline, width: 1),
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
                    color: scheme.primary,
                    width: 12,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.18),
                      blurRadius: 8,
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
                  color: scheme.background.withOpacity(0.95),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDuration(),
                      style: GoogleFonts.montserratAlternates(
                        fontSize: max(18.0, innerCircle * 0.16),
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isFocusPhase ? 'FOCUS' : 'BREAK',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _smallRoundIconButton(
                Icons.refresh,
                _resetTimer,
                size: controlBtnSize,
              ),
              SizedBox(width: cardWidth * 0.06),
              ElevatedButton(
                onPressed: _toggleStartPause,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: EdgeInsets.all(playBtnPadding + 4),
                  elevation: 4,
                ),
                child: Icon(
                  _running ? Icons.pause : Icons.play_arrow,
                  size: max(28.0, cardWidth * 0.10),
                ),
              ),
              SizedBox(width: cardWidth * 0.06),
              _smallRoundIconButton(
                Icons.repeat,
                _cycleDuration,
                size: controlBtnSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallRoundIconButton(
    IconData icon,
    VoidCallback onPressed, {
    double size = 46,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: scheme.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(
            color: scheme.outline.withOpacity(0.5),
          ),
        ),
        child: Icon(
          icon,
          color: scheme.primary,
          size: max(18.0, size * 0.44),
        ),
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

  Widget _buildOptionCardSized(
    IconData icon,
    String title, {
    required double width,
    VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outline, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Focus Today card – using cached state, refreshed only on screen open
  /// and after focus session completes.
  Widget _buildFocusToday({required double cardWidth}) {
    return _focusTodayCard(
      cardWidth: cardWidth,
      minutes: _focusTodayMinutes,
      loading: _focusTodayLoading,
    );
  }

  Widget _focusTodayCard({
    required double cardWidth,
    required int minutes,
    required bool loading,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: cardWidth,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scheme.background,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.primary.withOpacity(0.2)),
              ),
              child: Icon(
                Icons.lightbulb,
                color: scheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus Today',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  loading
                      ? Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Loading...',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _minutesToHourMinute(minutes),
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                        ),
                  const SizedBox(height: 6),
                  Text(
                    'Small sessions add up — keep going!',
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: scheme.onSurface.withOpacity(0.8),
                    ),
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
    final baseTheme = Theme.of(context);
    final scheme = baseTheme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final bottomTheme = baseTheme.copyWith(
          scaffoldBackgroundColor: scheme.surface,
          canvasColor: scheme.surface,
          iconTheme: baseTheme.iconTheme.copyWith(color: scheme.onSurface),
          textTheme: baseTheme.textTheme.apply(
            bodyColor: scheme.onSurface,
            displayColor: scheme.onSurface,
          ),
        );

        return Theme(
          data: bottomTheme,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final bottomScheme = Theme.of(context).colorScheme;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: bottomScheme.outline.withOpacity(0.4),
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
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: bottomScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.clear,
                                size: 20,
                                color: bottomScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      height: 1,
                      color: bottomScheme.outline.withOpacity(0.3),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Block All Notification',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: bottomScheme.onSurface,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _strictBlockNotifications,
                                onChanged: (v) {
                                  setModalState(
                                      () => _strictBlockNotifications = v);
                                  setState(
                                      () => _strictBlockNotifications = v);

                                  _showThemedSnackBar(
                                    v
                                        ? 'Strict Mode: notifications blocked (in-app)'
                                        : 'Strict Mode: notifications allowed',
                                    duration:
                                        const Duration(milliseconds: 700),
                                  );
                                },
                              ),
                            ],
                          ),
                          Divider(
                            height: 1,
                            color: bottomScheme.outline.withOpacity(0.3),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Block Phone Calls',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: bottomScheme.onSurface,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _strictBlockCalls,
                                onChanged: (v) {
                                  setModalState(() => _strictBlockCalls = v);
                                  setState(() => _strictBlockCalls = v);

                                  _showThemedSnackBar(
                                    v
                                        ? 'Strict Mode: phone calls blocked (in-app)'
                                        : 'Strict Mode: phone calls allowed',
                                    duration:
                                        const Duration(milliseconds: 700),
                                  );
                                },
                              ),
                            ],
                          ),
                          Divider(
                            height: 1,
                            color: bottomScheme.outline.withOpacity(0.3),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
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

    if (result != null) {
      _timer?.cancel();
      setState(() {
        _current = result['current'] as Duration? ?? _current;
        _running = result['running'] as bool? ?? _running;
        _duration = result['duration'] as Duration? ?? _duration;
      });
    } else {
      setState(() {});
    }

    if (_running) {
      _startTimer();
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

    Duration? newFocusDuration;
    int? newBreakSeconds;
    int? newSessions;

    if (result['focus_total_seconds'] is int) {
      newFocusDuration =
          Duration(seconds: result['focus_total_seconds'] as int);
    }

    if (result['break_total_seconds'] is int) {
      newBreakSeconds = result['break_total_seconds'] as int;
    }

    if (result['sessions'] is int) {
      newSessions = (result['sessions'] as int).clamp(1, 10);
    }

    setState(() {
      if (newFocusDuration != null) _duration = newFocusDuration!;
      if (newBreakSeconds != null) {
        _shortBreakMinutes = (newBreakSeconds! / 60).round().clamp(0, 45);
      }
      if (newSessions != null) _sessions = newSessions!;
    });

    _resetTimer();

    if (!mounted) return;
    _showThemedSnackBar(
      'Timer updated — focus ${_duration.inMinutes}m • short $_shortBreakMinutes m • sessions $_sessions',
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const double horizontalPadding = 16.0;

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double cardWidth = screenWidth - (horizontalPadding * 2);
            final double maxCardHeight = constraints.maxHeight * 0.55;
            final double cardHeight =
                max(260.0, min(420.0, maxCardHeight));
            final double circleBase = min(220.0, cardWidth * 0.68);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(0, 12.0, 0, 14.0),
                    child: _buildTopHeader(),
                  ),
                  _buildTimerCard(
                    cardWidth: cardWidth,
                    circleBase: circleBase,
                    cardHeight: cardHeight,
                  ),
                  const SizedBox(height: 12),
                  _buildThreeOptionRow(cardWidth: cardWidth),
                  const SizedBox(height: 12),
                  _buildFocusToday(cardWidth: cardWidth),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: max(32.0, constraints.maxHeight * 0.05),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}