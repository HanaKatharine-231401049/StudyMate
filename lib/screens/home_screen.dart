// lib/screens/home_screen.dart - UPDATE BAGIAN IMPORT
// tambahkan ini di bagian import paling atas
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// services
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

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

  // --- Data dari Firebase ---
  List<Schedule> schedules = [];
  List<Assignment> assignments = [];
  List<Note> allNotes = [];
  List<Note> filteredNotes = [];

  // User name untuk display
  String _userName = 'User';

  // Stream subscriptions
  late StreamSubscription<List<Schedule>> _scheduleSubscription;
  late StreamSubscription<List<Assignment>> _assignmentSubscription;
  late StreamSubscription<List<Note>> _noteSubscription;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadUserData();
    _setupFirebaseListeners();
  }

  @override
  void dispose() {
    _scheduleSubscription.cancel();
    _assignmentSubscription.cancel();
    _noteSubscription.cancel();
    super.dispose();
  }

  void _loadUserData() {
    final authService = AuthService();
    _userName = authService.currentUser?.displayName ?? 'User';
  }

  void _setupFirebaseListeners() {
    final firestoreService = FirestoreService();
    
    // Listen to schedules
    _scheduleSubscription = firestoreService.getSchedulesByDate(_selectedDate).listen((schedulesList) {
      if (mounted) {
        setState(() {
          schedules = schedulesList;
        });
      }
    });

    // Listen to all assignments
    _assignmentSubscription = firestoreService.getAssignmentsStream().listen((assignmentsList) {
      if (mounted) {
        setState(() {
          assignments = assignmentsList;
        });
      }
    });

    // Listen to notes
    _noteSubscription = firestoreService.getNotesStream().listen((notesList) {
      if (mounted) {
        setState(() {
          allNotes = notesList;
          filteredNotes = List.from(allNotes);
        });
      }
    });
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
      // Refresh schedules untuk date baru
      final firestoreService = FirestoreService();
      _scheduleSubscription.cancel();
      _scheduleSubscription = firestoreService.getSchedulesByDate(date).listen((schedulesList) {
        if (mounted) {
          setState(() {
            schedules = schedulesList;
          });
        }
      });
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
            if (res is Schedule) {
              // Update di Firebase
              final firestoreService = FirestoreService();
              await firestoreService.updateSchedule(res);
              return res;
            }
            return null;
          },
          onDelete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => ConfirmationDialog(
                title: 'Are you sure want to delete schedule?',
                icon: Icons.delete_forever,
                onConfirm: () => Navigator.pop(context, true),
                onCancel: () => Navigator.pop(context, false),
              ),
            );
            
            if (confirmed == true) {
              final firestoreService = FirestoreService();
              await firestoreService.deleteSchedule(schedule.id!);
              return true;
            }
            return false;
          },
        ),
      ),
    );

    if (result is Map && result['deleted'] == true) {
      // Success dialog akan ditampilkan dari detail page
      return;
    }
  }

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
            if (res is Assignment) {
              // Update di Firebase
              final firestoreService = FirestoreService();
              await firestoreService.updateAssignment(res);
              return res;
            }
            return null;
          },
          onDelete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => ConfirmationDialog(
                title: 'Are you sure want to delete assignment?',
                icon: Icons.delete_forever,
                onConfirm: () => Navigator.pop(context, true),
                onCancel: () => Navigator.pop(context, false),
              ),
            );
            
            if (confirmed == true) {
              final firestoreService = FirestoreService();
              await firestoreService.deleteAssignment(assignment.id!);
              return true;
            }
            return false;
          },
        ),
      ),
    );

    if (result is Map && result['deleted'] == true) {
      // Success dialog akan ditampilkan dari detail page
      return;
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
            if (res is Note) {
              // Update di Firebase
              final firestoreService = FirestoreService();
              await firestoreService.updateNote(res);
              return res;
            }
            return null;
          },
          onDelete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => ConfirmationDialog(
                title: 'Are you sure want to delete note?',
                icon: Icons.delete_forever,
                onConfirm: () => Navigator.pop(context, true),
                onCancel: () => Navigator.pop(context, false),
              ),
            );
            
            if (confirmed == true) {
              final firestoreService = FirestoreService();
              await firestoreService.deleteNote(note.id!);
              return true;
            }
            return false;
          },
        ),
      ),
    );

    if (result is Map && result['deleted'] == true) {
      // Success dialog akan ditampilkan dari detail page
      return;
    }
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
                  Text('Hello $_userName', // DIUBAH: Gunakan nama dari Firebase
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
                      schedules: schedules.where((s) => s.date.contains(_selectedDate)).toList(),
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
                      onToggleStatus: (assignment) async {
                        final firestoreService = FirestoreService();
                        await firestoreService.toggleAssignmentCompletion(
                          assignment.id!,
                          assignment.isFinished,
                        );
                      },
                    ),

                    // Tab 3: Statistics (tidak diubah)
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
                final firestoreService = FirestoreService();
                final savedSchedule = await firestoreService.addSchedule(result);
                
                showDialog(
                  context: context,
                  builder: (context) => SuccessDialog(title: 'Schedule saved successfully'),
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
                final firestoreService = FirestoreService();
                final savedNote = await firestoreService.addNote(result);
                
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
                final firestoreService = FirestoreService();
                final savedAssignment = await firestoreService.addAssignment(result);
                
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