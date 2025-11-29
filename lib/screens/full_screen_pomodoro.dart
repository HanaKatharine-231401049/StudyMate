// lib/screens/full_screen_pomodoro.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

class FullScreenPomodoro extends StatefulWidget {
  final Duration duration;
  final Duration current;
  final bool running;

  const FullScreenPomodoro({
    Key? key,
    required this.duration,
    required this.current,
    required this.running,
  }) : super(key: key);

  @override
  State<FullScreenPomodoro> createState() => _FullScreenPomodoroState();
}

class _FullScreenPomodoroState extends State<FullScreenPomodoro> {
  late Duration _duration;
  late Duration _current;
  late bool _running;
  Timer? _timer;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _duration = widget.duration;
    _current = widget.current;
    _running = widget.running;

    // Enter immersive fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (_running) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _current += const Duration(seconds: 1);
        if (_current >= _duration) {
          _current = _duration;
          _running = false;
          _timer?.cancel();
        }
      });
    });
  }

  void _toggleRunning() {
    setState(() {
      if (_running) {
        _timer?.cancel();
        _running = false;
      } else {
        _running = true;
        _startTimer();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _current = Duration.zero;
      _running = false;
    });
  }

  String _formatRemaining() {
    final remaining = _duration - _current;
    final seconds = remaining.inSeconds.clamp(0, remaining.inSeconds);
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  void dispose() {
    _timer?.cancel();
    // best-effort restore
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: SystemUiOverlay.values);
    // also restore overlay style to app colors
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor:const Color.fromARGB(255, 0, 0, 0),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    super.dispose();
  }

  /// Restore system UI and pop with the current state.
  Future<void> _popWithState() async {
    if (_restoring) return;
    _restoring = true;

    // stop timer
    _timer?.cancel();

    // Restore system UI: edgeToEdge so SafeArea works normally
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );

    // Important: set navigation bar color back to app accent (navy)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: kAccentColor,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Slight delay so the OS applies the visuals before popping
    await Future.delayed(const Duration(milliseconds: 220));

    if (mounted) {
      Navigator.of(context).pop({
        'current': _current,
        'running': _running,
        'duration': _duration,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double fontSize = (w / 6).clamp(64.0, 160.0);

    return WillPopScope(
      onWillPop: () async {
        await _popWithState();
        return false;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleRunning,
        onDoubleTap: _resetTimer,
        child: Scaffold(
          backgroundColor: kAccentColor,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    _formatRemaining(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 0.9,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      color: Colors.white70,
                      onPressed: () async {
                        await _popWithState();
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBottomCircleButton(icon: Icons.refresh, onTap: _resetTimer),
                      const SizedBox(width: 24),
                      _buildBottomCircleButton(icon: _running ? Icons.pause : Icons.play_arrow, onTap: _toggleRunning, big: true),
                      const SizedBox(width: 24),
                      _buildBottomCircleButton(icon: Icons.fullscreen_exit, onTap: _popWithState),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCircleButton({required IconData icon, required VoidCallback onTap, bool big = false}) {
    final size = big ? 72.0 : 48.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(big ? 0.14 : 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: big ? 36 : 22),
      ),
    );
  }
}