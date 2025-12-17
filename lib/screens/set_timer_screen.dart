// lib/screens/set_timer_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SetTimerScreen extends StatefulWidget {
  final int initialFocusHours;
  final int initialFocusMinutes;
  final int initialBreakMinutes;
  final int initialBreakSeconds;
  final int initialSessions;

  const SetTimerScreen({
    super.key,
    this.initialFocusHours = 0,
    this.initialFocusMinutes = 25,
    this.initialBreakMinutes = 5,
    this.initialBreakSeconds = 0,
    this.initialSessions = 4,
  });

  @override
  State<SetTimerScreen> createState() => _SetTimerScreenState();
}

class _SetTimerScreenState extends State<SetTimerScreen> {
  int _selectedTab = 0;

  int _focusHours = 0;
  int _focusMinutes = 25;

  int _breakMinutes = 5;
  int _breakSeconds = 0;

  int _sessions = 4;

  late TextEditingController _focusHoursCtrl;
  late TextEditingController _focusMinutesCtrl;
  late TextEditingController _breakMinutesCtrl;
  late TextEditingController _breakSecondsCtrl;
  late TextEditingController _sessionsCtrl;

  @override
  void initState() {
    super.initState();

    _focusHours = widget.initialFocusHours.clamp(0, 2);
    _focusMinutes = widget.initialFocusMinutes.clamp(0, 59);
    if (_focusHours >= 2 && _focusMinutes > 45) _focusMinutes = 45;

    _breakMinutes = widget.initialBreakMinutes.clamp(0, 45);
    _breakSeconds = widget.initialBreakSeconds.clamp(0, 59);

    _sessions = widget.initialSessions.clamp(1, 10);

    _focusHoursCtrl = TextEditingController(text: '$_focusHours');
    _focusMinutesCtrl = TextEditingController(text: '$_focusMinutes');
    _breakMinutesCtrl = TextEditingController(text: '$_breakMinutes');
    _breakSecondsCtrl = TextEditingController(text: '$_breakSeconds');
    _sessionsCtrl = TextEditingController(text: '$_sessions');
  }

  @override
  void dispose() {
    _focusHoursCtrl.dispose();
    _focusMinutesCtrl.dispose();
    _breakMinutesCtrl.dispose();
    _breakSecondsCtrl.dispose();
    _sessionsCtrl.dispose();
    super.dispose();
  }

  OutlineInputBorder _inputBorder(ColorScheme scheme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: scheme.outline, width: 1),
    );
  }

  Widget _segmentedToggle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? scheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Focus',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _selectedTab == 0 ? scheme.onPrimary : scheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? scheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Break',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _selectedTab == 1 ? scheme.onPrimary : scheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberPicker({
    required BuildContext context,
    required TextEditingController controller,
    required int min,
    required int max,
    required void Function(int) onChanged,
    double width = 86,
  }) {
    final scheme = Theme.of(context).colorScheme;

    int _read() => int.tryParse(controller.text) ?? min;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outline, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          // decrement
          Builder(
            builder: (_) {
              final cur = _read();
              final canDec = cur > min;
              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: canDec
                    ? () {
                        final next = (cur - 1).clamp(min, max);
                        controller.text = '$next';
                        onChanged(next);
                      }
                    : null,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(
                    Icons.remove,
                    size: 18,
                    color: canDec
                        ? scheme.onSurface.withOpacity(0.85)
                        : scheme.onSurface.withOpacity(0.35),
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 6),

          // input
          Expanded(
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
              onChanged: (v) {
                final parsed = int.tryParse(v) ?? min;
                var clamped = parsed.clamp(min, max);

                // rule: if focusHours >= 2 then focusMinutes max 45
                if (controller == _focusMinutesCtrl && _focusHours >= 2) {
                  clamped = parsed.clamp(0, 45);
                }

                if (clamped != parsed) {
                  controller.text = '$clamped';
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                }

                onChanged(clamped);
              },
            ),
          ),

          const SizedBox(width: 6),

          // increment
          Builder(
            builder: (_) {
              final cur = _read();
              final canInc = cur < max;
              final effectiveCanInc =
                  (controller == _focusMinutesCtrl && _focusHours >= 2)
                      ? (cur < 45)
                      : canInc;

              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: effectiveCanInc
                    ? () {
                        var next = (cur + 1).clamp(min, max);
                        if (controller == _focusMinutesCtrl && _focusHours >= 2) {
                          next = (cur + 1).clamp(0, 45);
                        }
                        controller.text = '$next';
                        onChanged(next);
                      }
                    : null,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(
                    Icons.add,
                    size: 18,
                    color: effectiveCanInc
                        ? scheme.onSurface.withOpacity(0.85)
                        : scheme.onSurface.withOpacity(0.35),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _focusPanel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const double inputWidth = 120;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Set Focus Duration',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hours',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: scheme.onBackground)),
                const SizedBox(height: 6),
                _numberPicker(
                  context: context,
                  controller: _focusHoursCtrl,
                  min: 0,
                  max: 2,
                  width: inputWidth,
                  onChanged: (val) {
                    setState(() {
                      _focusHours = val;

                      if (_focusHours >= 2 && _focusMinutes > 45) {
                        _focusMinutes = 45;
                        _focusMinutesCtrl.text = '$_focusMinutes';
                      }
                      _focusHoursCtrl.text = '$_focusHours';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Minutes',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: scheme.onBackground)),
                const SizedBox(height: 6),
                _numberPicker(
                  context: context,
                  controller: _focusMinutesCtrl,
                  min: 0,
                  max: 59,
                  width: inputWidth,
                  onChanged: (val) {
                    final effectiveMax = _focusHours >= 2 ? 45 : 59;
                    final clamped = val.clamp(0, effectiveMax);
                    setState(() {
                      _focusMinutes = clamped;
                      _focusMinutesCtrl.text = '$_focusMinutes';
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _breakPanel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const double inputWidth = 120;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Set Break Duration',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Minutes',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: scheme.onBackground)),
                const SizedBox(height: 6),
                _numberPicker(
                  context: context,
                  controller: _breakMinutesCtrl,
                  min: 0,
                  max: 45,
                  width: inputWidth,
                  onChanged: (val) {
                    setState(() {
                      _breakMinutes = val;
                      _breakMinutesCtrl.text = '$_breakMinutes';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seconds',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: scheme.onBackground)),
                const SizedBox(height: 6),
                _numberPicker(
                  context: context,
                  controller: _breakSecondsCtrl,
                  min: 0,
                  max: 59,
                  width: inputWidth,
                  onChanged: (val) {
                    setState(() {
                      _breakSeconds = val;
                      _breakSecondsCtrl.text = '$_breakSeconds';
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _sessionsControl(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(
          'Sessions',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _numberPicker(
              context: context,
              controller: _sessionsCtrl,
              min: 1,
              max: 10,
              width: 140,
              onChanged: (val) {
                setState(() {
                  _sessions = val;
                  _sessionsCtrl.text = '$_sessions';
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  void _saveAndReturn() {
    final focusTotalSeconds = (_focusHours * 3600) + (_focusMinutes * 60);
    final breakTotalSeconds = (_breakMinutes * 60) + _breakSeconds;

    Navigator.of(context).pop({
      // canonical values (Pomodoro should read these)
      'focus_total_seconds': focusTotalSeconds,
      'break_total_seconds': breakTotalSeconds,
      'sessions': _sessions,

      // optional breakdown (handy for UI later)
      'focus_hours': _focusHours,
      'focus_minutes': _focusMinutes,
      'break_minutes': _breakMinutes,
      'break_seconds': _breakSeconds,
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const double pad = 16.0;

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: scheme.primary),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Set Timer',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: pad, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _segmentedToggle(context),
              if (_selectedTab == 0) _focusPanel(context) else _breakPanel(context),
              _sessionsControl(context),
              const SizedBox(height: 22),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 110,
                  child: ElevatedButton(
                    onPressed: _saveAndReturn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
