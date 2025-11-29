// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// models
import '../models/schedule.dart';
import '../models/assignment.dart';
import '../models/note.dart';

// utils
import '../utils/colors.dart';
import '../utils/dialog_components.dart';

// pages
import 'add_edit_schedule_screen.dart';
import 'add_edit_assignment_screen.dart';
import 'add_edit_note_screen.dart';
import 'detail_schedule_screen.dart';
import 'detail_assignment_screen.dart';
import 'detail_note_screen.dart';
import 'statistics_screen.dart';
import 'mood_screen.dart';
import 'pomodoro_screen.dart';
import 'profile_screen.dart';

// widgets
import '../widgets/header_tabs.dart';
import '../widgets/schedule_tab.dart';
import '../widgets/note_tab.dart';
import '../widgets/assignment_tab.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/add_options_fab.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 0: Schedule, 1: Notes, 2: Assignment, 3: Statistics, 4: Mood, 5: Pomodoro, 6: Profile
  late int _selectedIndex;
  int _assignmentTabIndex = 0;

  // tanggal terpilih - format sesuai dengan schedule_tab
  String _selectedDate = '15 January 2025';

  // state add options
  bool _showAddOptions = false;

  // --- Data Dummy ---
  List<Schedule> schedules = [
    Schedule('Grafika Komputer', '15 January 2025', '10.30 - 11.20', 'ILK3103 - A, 2 SKS'),
    Schedule('Pemrograman Mobile', '15 January 2025', '10.30 - 11.20', 'ILK3103 - A, 2 SKS'),
    Schedule('Struktur Data', '16 January 2025', '08.00 - 09.30', 'ILK2205 - B, 3 SKS'),
  ];
  List<Assignment> assignments = [
    Assignment('Grafika Komputer - Primitive Drawing', '12 Jan 2025', '11.00',
        'Lorem ipsum dolor sit amet...', isFinished: false),
    Assignment('Pemrograman Mobile - UI/UX', '14 Jan 2025', '14.00',
        'Mauris quam orci...', isFinished: false),
    Assignment('Jaringan Komputer', '10 Jan 2025', '18.00', 'Tugas sudah selesai',
        isFinished: true),
  ];
  List<Note> allNotes = [
    Note('Grafika Komputer - Primitive Drawing', '15 Jan 2025', 'Lorem ipsum dolor sit amet...'),
    Note('Pemrograman Mobile - UI/UX', '16 Jan 2025', 'Catatan penting tentang lifecycle...'),
  ];

  // untuk fitur pencarian
  List<Note> filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    filteredNotes = List.from(allNotes);
  }

  // --- Utilities untuk notes/assignments/schedules --- //
  void _filterNotes(String query) {
    final lower = query.toLowerCase();
    setState(() {
      if (query.trim().isEmpty) {
        filteredNotes = List.from(allNotes);
      } else {
        filteredNotes = allNotes.where((note) {
          return note.title.toLowerCase().contains(lower) ||
              note.description.toLowerCase().contains(lower);
        }).toList();
      }
    });
  }

  void _selectDate(String date) {
    setState(() {
      _selectedDate = date;
    });
  }

  // --- Schedule handlers ---
  Future<void> _openScheduleDetail(Schedule schedule) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailSchedulePage(
          schedule: schedule,
          onEdit: () async {
            final res = await Navigator.push<dynamic>(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditSchedulePage(isEditing: true, schedule: schedule),
              ),
            );
            return res;
          },
          onDelete: () {
            _confirmDeleteSchedule(schedule);
            return Future.value(null);
          },
        ),
      ),
    );

    // if DetailSchedulePage returned something via edit/delete flow, handle here
    if (result is Schedule) {
      final idx = schedules.indexOf(schedule);
      if (idx != -1) {
        setState(() => schedules[idx] = result);
      } else {
        final fallbackIndex = schedules.indexWhere((s) =>
            s.title == schedule.title && s.date == schedule.date && s.time == schedule.time);
        if (fallbackIndex != -1) setState(() => schedules[fallbackIndex] = result);
      }
      showDialog(context: context, builder: (_) => const SuccessDialog(title: 'Schedule updated successfully'));
    }

    if (result is Map && result['deleted'] == true) {
      final idx = schedules.indexOf(schedule);
      if (idx != -1) {
        setState(() => schedules.removeAt(idx));
      } else {
        final fallbackIndex = schedules.indexWhere((s) =>
            s.title == schedule.title && s.date == schedule.date && s.time == schedule.time);
        if (fallbackIndex != -1) setState(() => schedules.removeAt(fallbackIndex));
      }
    }
  }

  // --- Assignment handlers ---
  // --- Assignment handlers ---
Future<void> _openAssignmentDetail(Assignment assignment) async {
  final result = await Navigator.push<dynamic>(
    context,
    MaterialPageRoute(
      builder: (_) => DetailAssignmentPage(
        assignment: assignment,
        onEdit: () async {
          final res = await Navigator.push<Assignment?>(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditAssignmentPage(isEditing: true, assignment: assignment),
            ),
          );
          return res;
        },
        onDelete: () {
          _confirmDeleteAssignment(assignment);
          return Future.value(null);
        },
      ),
    ),
  );

  if (result is Assignment) {
    final idx = assignments.indexOf(assignment);
    if (idx != -1) {
      setState(() => assignments[idx] = result);
    } else {
      final fallbackIndex = assignments.indexWhere((a) =>
          a.title == assignment.title && a.date == assignment.date && a.time == assignment.time);
      if (fallbackIndex != -1) setState(() => assignments[fallbackIndex] = result);
    }
    showDialog(context: context, builder: (_) => const SuccessDialog(title: 'Assignment updated successfully'));
  }

  if (result is Map && result['deleted'] == true) {
    final idx = assignments.indexOf(assignment);
    if (idx != -1) {
      setState(() => assignments.removeAt(idx));
    } else {
      final fallbackIndex = assignments.indexWhere((a) =>
          a.title == assignment.title && a.date == assignment.date && a.time == assignment.time);
      if (fallbackIndex != -1) setState(() => assignments.removeAt(fallbackIndex));
    }
  }
}

  // --- Note handlers ---
  Future<void> _openNoteDetail(Note note) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailNotePage(
          note: note,
          onEdit: () async {
            final res = await Navigator.push<dynamic>(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditNotePage(isEditing: true, note: note),
              ),
            );
            return res;
          },
          onDelete: () {
          _confirmDeleteNote(note);
          return Future.value(null);
        },
        ),
      ),
    );

    // Handle updated note
    if (result is Note) {
      final idx = allNotes.indexOf(note);
      if (idx != -1) {
        setState(() {
          allNotes[idx] = result;
          _filterNotes('');
        });
      } else {
        final fallbackIndex = allNotes.indexWhere((n) => n.title == note.title && n.date == note.date);
        if (fallbackIndex != -1) {
          setState(() {
            allNotes[fallbackIndex] = result;
            _filterNotes('');
          });
        }
      }
      showDialog(context: context, builder: (_) => const SuccessDialog(title: 'Note updated successfully'));
    }

    // Handle delete signal returned from AddEditNotePage
    if (result is Map && result['deleted'] == true) {
      final idx = allNotes.indexOf(note);
      if (idx != -1) {
        setState(() {
          allNotes.removeAt(idx);
          _filterNotes('');
        });
      } else {
        final fallbackIndex = allNotes.indexWhere((n) => n.title == note.title && n.date == note.date);
        if (fallbackIndex != -1) {
          setState(() {
            allNotes.removeAt(fallbackIndex);
            _filterNotes('');
          });
        }
      }
    }
  }

  // --- Confirm delete routines ---
  void _confirmDeleteSchedule(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Are you sure want to delete schedule?',
        icon: Icons.delete_forever,
        onConfirm: () {
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              schedules.remove(schedule);
            });
            showDialog(
              context: context,
              builder: (context) => SuccessDialog(
                title: 'Schedule deleted successfully',
                onConfirm: () {},
              ),
            );
          });
        },
      ),
    );
  }

  void _confirmDeleteAssignment(Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Are you sure want to delete assignment?',
        icon: Icons.delete_forever,
        onConfirm: () {
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              assignments.remove(assignment);
            });
            showDialog(
              context: context,
              builder: (context) => SuccessDialog(
                title: 'Assignment deleted successfully',
                onConfirm: () {},
              ),
            );
          });
        },
      ),
    );
  }

  void _confirmDeleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Are you sure want to delete note?',
        icon: Icons.delete_forever,
        onConfirm: () {
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              allNotes.remove(note);
              _filterNotes('');
            });
            showDialog(
              context: context,
              builder: (context) => SuccessDialog(
                title: 'Note deleted successfully',
                onConfirm: () {},
              ),
            );
          });
        },
      ),
    );
  }

  // toggle add options
  void _toggleAddOptions() {
    setState(() {
      _showAddOptions = !_showAddOptions;
    });
  }

  void _hideAddOptions() {
    setState(() {
      _showAddOptions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalTasks = assignments.where((a) => !a.isFinished).length;

    // disable FAB pada tab tertentu (3..6)
    final bool fabDisabled =
        (_selectedIndex == 3 || _selectedIndex == 4 || _selectedIndex == 5 || _selectedIndex == 6);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: (_selectedIndex == 3 ||
              _selectedIndex == 4 ||
              _selectedIndex == 5 ||
              _selectedIndex == 6)
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              toolbarHeight: 120,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text('Hello Mark',
                      style: GoogleFonts.montserrat(
                          fontSize: 18, fontWeight: FontWeight.normal)),
                  const SizedBox(height: 4),
                  Text('You\'ve got',
                      style: GoogleFonts.montserratAlternates(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  Text('$totalTasks tasks today',
                      style: GoogleFonts.montserratAlternates(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kAccentColor)),
                  const SizedBox(height: 8),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 20),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.person, color: kInkTone, size: 30),
                  ),
                ),
              ],
            ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: HeaderTabs(
                    selectedIndex: _selectedIndex,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                        if (index != 2) _assignmentTabIndex = 0;
                        _showAddOptions = false;
                      });
                    },
                  ),
                ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    // Tab 0: Schedule
                    ScheduleTab(
                      schedules: schedules,
                      selectedDate: _selectedDate,
                      onSelectDate: _selectDate,
                      onTapSchedule: _openScheduleDetail,
                    ),

                    // Tab 1: Notes
                    NoteTab(
                      notes: filteredNotes,
                      onSearch: _filterNotes,
                      onTapNote: (note) => _openNoteDetail(note),
                    ),

                    // Tab 2: Assignment
                    AssignmentTab(
                      assignments: assignments,
                      selectedSubTabIndex: _assignmentTabIndex,
                      onSubTabChanged: (i) {
                        setState(() => _assignmentTabIndex = i);
                      },
                      onTapAssignment: (assignment) => _openAssignmentDetail(assignment),
                      onToggleStatus: (assignment) {
                        setState(() {
                          assignment.toggleFinished();
                        });
                      },
                    ),

                    // Tab 3: Statistics
                    StatisticsScreen(
                      assignments: assignments,
                      weeklyStudyHours: [10, 25, 15, 20],
                    ),

                    // Tab 4: Mood / Music screen
                    const MoodScreen(),

                    // Tab 5: Pomodoro
                    const PomodoroScreen(),

                    // Tab 6: Profile
                    const ProfileScreen(),
                  ],
                ),
              ),
            ],
          ),

          // AddOptionsFab menangani overlay + FAB + option buttons
          AddOptionsFab(
            showAddOptions: _showAddOptions,
            onToggle: _toggleAddOptions,
            onAddSchedule: () async {
              _hideAddOptions();
              final result = await Navigator.push<dynamic>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditSchedulePage(isEditing: false),
                ),
              );

              if (result is Schedule) {
                setState(() {
                  schedules.insert(0, result);
                });
                showDialog(
                  context: context,
                  builder: (context) => const SuccessDialog(title: 'Schedule saved successfully'),
                );
              }
            },
            onAddNote: () async {
              _hideAddOptions();
              final result = await Navigator.push<dynamic>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditNotePage(isEditing: false),
                ),
              );

              if (result is Note) {
                setState(() {
                  allNotes.insert(0, result);
                  _filterNotes('');
                });
                showDialog(
                  context: context,
                  builder: (context) => const SuccessDialog(title: 'Note saved successfully'),
                );
              }
            },
            onAddAssignment: () async {
              _hideAddOptions();
              final result = await Navigator.push<Assignment?>(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditAssignmentPage(isEditing: false),
                ),
              );
              if (result is Assignment) {
                setState(() {
                  assignments.insert(0, result);
                });
                showDialog(
                  context: context,
                  builder: (context) => const SuccessDialog(title: 'Assignment saved successfully'),
                );
              }
            },
            disabled: fabDisabled,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTapIndex: (idx) {
          setState(() {
            _selectedIndex = idx;
            _showAddOptions = false;
          });
        },
      ),
    );
  }
}