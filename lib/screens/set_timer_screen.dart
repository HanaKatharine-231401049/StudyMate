// lib/screens/set_timer_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

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
    // batas jam dan menit
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

  // shared decorations & border
  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF03045E), width: 1),
    );
  }

  InputDecoration _smallFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(),
      filled: true,
      fillColor: const Color(0xFFD9E9EC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: _inputBorder(),
      enabledBorder: _inputBorder(),
      focusedBorder: _inputBorder(),
    );
  }

  Widget _segmentedToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E9EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF03045E), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTab = 0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? const Color(0xFF03045E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Focus',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _selectedTab == 0 ? Colors.white : const Color(0xFF03045E),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTab = 1);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? const Color(0xFF03045E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Break',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _selectedTab == 1 ? Colors.white : const Color(0xFF03045E),
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
    required TextEditingController controller,
    required int min,
    required int max,
    required void Function(int) onChanged,
    double width = 86,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFD9E9EC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF03045E), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          // decrement
          Builder(builder: (context) {
            final cur = int.tryParse(controller.text) ?? min;
            final canDec = cur > min;
            return GestureDetector(
              onTap: canDec
                  ? () {
                      final curVal = int.tryParse(controller.text) ?? min;
                      final next = (curVal - 1).clamp(min, max);
                      controller.text = '$next';
                      onChanged(next);
                    }
                  : null,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.remove, size: 18, color: canDec ? Colors.black : Colors.grey),
              ),
            );
          }),
          const SizedBox(width: 6),
          // input
          Expanded(
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
              onChanged: (v) {
                final parsed = int.tryParse(v) ?? min;
                var clamped = parsed.clamp(min, max);
                if (min == 0 && max == 59 && controller == _focusMinutesCtrl && _focusHours >= 2) {
                  clamped = parsed.clamp(0, 45);
                }
                if (clamped != parsed) {
                  controller.text = '$clamped';
                }
                onChanged(clamped);
              },
            ),
          ),
          const SizedBox(width: 6),
          Builder(builder: (context) {
            final cur = int.tryParse(controller.text) ?? min;
            final canInc = cur < max;
            final effectiveCanInc = (controller == _focusMinutesCtrl && _focusHours >= 2) ? (cur < 45) : canInc;
            final iconColor = effectiveCanInc ? Colors.black : Colors.grey;
            return GestureDetector(
              onTap: effectiveCanInc
                  ? () {
                      final curVal = int.tryParse(controller.text) ?? min;
                      var next = (curVal + 1).clamp(min, max);
                      if (controller == _focusMinutesCtrl && _focusHours >= 2) {
                        next = (curVal + 1).clamp(0, 45);
                      }
                      controller.text = '$next';
                      onChanged(next);
                    }
                  : null,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 18, color: iconColor),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _focusPanel() {
    const double inputWidth = 120;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text('Set Focus Duration', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF03045E))),
        const SizedBox(height: 10),

        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hours', style: GoogleFonts.inter(fontSize: 12)),
                const SizedBox(height: 6),
                _numberPicker(
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
                Text('Minutes', style: GoogleFonts.inter(fontSize: 12)),
                const SizedBox(height: 6),
                _numberPicker(
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

  Widget _breakPanel() {
    const double inputWidth = 120;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text('Set Break Duration', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF03045E))),
        const SizedBox(height: 10),

        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Minutes', style: GoogleFonts.inter(fontSize: 12)),
                const SizedBox(height: 6),
                _numberPicker(
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
                Text('Seconds', style: GoogleFonts.inter(fontSize: 12)),
                const SizedBox(height: 6),
                _numberPicker(
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

  Widget _sessionsControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text('Sessions', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF03045E))),
        const SizedBox(height: 8),
        Row(
          children: [
            _numberPicker(
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
            const SizedBox(width: 12),
          ],
        ),
      ],
    );
  }

  void _saveAndReturn() {
    final focusTotalMinutes = _focusHours * 60 + _focusMinutes;
    final breakTotalSeconds = _breakMinutes * 60 + _breakSeconds;

    Navigator.of(context).pop({
      'mode': _selectedTab == 0 ? 'focus' : 'break',
      'focus_hours': _focusHours,
      'focus_minutes': _focusMinutes,
      'focus_total_minutes': focusTotalMinutes,
      'break_minutes': _breakMinutes,
      'break_seconds': _breakSeconds,
      'break_total_seconds': breakTotalSeconds,
      'sessions': _sessions,
    });
  }

  @override
  Widget build(BuildContext context) {
    const double pad = 16.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Set Timer', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(

        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: pad, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _segmentedToggle(),
            
              if (_selectedTab == 0) _focusPanel() else _breakPanel(),
              _sessionsControl(),
              const SizedBox(height: 22),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAndReturn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Save', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
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
