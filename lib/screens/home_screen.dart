import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/schedule.dart';
import '../models/assignment.dart';
import '../models/note.dart';

import '../utils/dialog_components.dart';
import '../utils/date_utils.dart';

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

  String _selectedDateString = DateUtilsHelper.formatDate(DateTime.now());

  String _noteSearchQuery = '';

  bool _showAddOptions = false;

  int _cachedPendingTasks = 0;
  bool _isFirstLoad = true;

  late final String uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User must be logged in to use HomePage.');
    }
    uid = user.uid;
  }

  //Helpers 

  DateTime? _parseDateString(String input) {
    return DateUtilsHelper.tryParse(input);
  }

  void _selectDate(String dateString) {
    setState(() {
      _selectedDateString = dateString;
    });
  }

  void _filterNotes(String query) {
    setState(() {
      _noteSearchQuery = query.trim().toLowerCase();
    });
  }

  void _toggleAddOptions() {
    setState(() => _showAddOptions = !_showAddOptions);
  }

  void _hideAddOptions() {
    setState(() => _showAddOptions = false);
  }

  //Firestore streams

  Stream<QuerySnapshot<Map<String, dynamic>>> _schedulesForSelectedDay() {
    final day = _parseDateString(_selectedDateString) ?? DateTime.now();
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _db
        .collection('users')
        .doc(uid)
        .collection('schedules')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _allNotesStream() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('notes')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _allAssignmentsStream() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('assignments')
        .orderBy('dueDate', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _allAssignmentsSimpleStream() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('assignments')
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userDocStream() {
    return _db.collection('users').doc(uid).snapshots();
  }

  int _countPendingTasks(QuerySnapshot<Map<String, dynamic>>? snapshot) {
    if (snapshot == null) return _cachedPendingTasks;
    
    int count = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final isFinished = data['isFinished'] as bool? ?? false;
      if (!isFinished) {
        count++;
      }
    }
    
    // Update cache
    _cachedPendingTasks = count;
    _isFirstLoad = false;
    
    return count;
  }

  Widget _buildTaskCounter(String username, int pendingTasks, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Text(
          'Hello $username',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: scheme.onBackground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'You\'ve got',
          style: GoogleFonts.montserratAlternates(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: scheme.onBackground,
          ),
        ),
        Text(
          '$pendingTasks tasks to do',
          style: GoogleFonts.montserratAlternates(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Delete handlers 

  void _confirmDeleteSchedule(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Are you sure want to delete schedule?',
        icon: Icons.delete_forever,
        onConfirm: () async {
          Navigator.pop(context);
          await _db
              .collection('users')
              .doc(uid)
              .collection('schedules')
              .doc(schedule.id)
              .delete();

          if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) =>
                SuccessDialog(title: 'Schedule deleted successfully'),
          );
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
        onConfirm: () async {
          Navigator.pop(context);
          await _db
              .collection('users')
              .doc(uid)
              .collection('notes')
              .doc(note.id)
              .delete();

          if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) => SuccessDialog(title: 'Note deleted successfully'),
          );
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
        onConfirm: () async {
          Navigator.pop(context);
          await _db
              .collection('users')
              .doc(uid)
              .collection('assignments')
              .doc(assignment.id)
              .delete();

          if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) =>
                SuccessDialog(title: 'Assignment deleted successfully'),
          );
        },
      ),
    );
  }

  //Detail openers

  Future<void> _openScheduleDetail(Schedule schedule) async {
    await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailSchedulePage(
          schedule: schedule,
          onEdit: () async {
            final res = await Navigator.push<dynamic>(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddEditSchedulePage(isEditing: true, schedule: schedule),
              ),
            );
            return res;
          },
          onDelete: () async {
            _confirmDeleteSchedule(schedule);
            return Future.value(null);
          },
        ),
      ),
    );
  }

  Future<void> _openNoteDetail(Note note) async {
    await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailNotePage(
          note: note,
          onEdit: () async {
            final res = await Navigator.push<dynamic>(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddEditNotePage(isEditing: true, note: note),
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
  }

  Future<void> _openAssignmentDetail(Assignment assignment) async {
    await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailAssignmentPage(
          assignment: assignment,
          onEdit: () async {
            final res = await Navigator.push<Assignment?>(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditAssignmentPage(
                  isEditing: true,
                  assignment: assignment,
                ),
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
  }

  // Toggle assignment done

  Future<void> _toggleAssignmentDone(Assignment assignment) async {
    final newValue = !assignment.isFinished;

    await _db
        .collection('users')
        .doc(uid)
        .collection('assignments')
        .doc(assignment.id)
        .update({
      'isFinished': newValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }


  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bool fabDisabled =
        (_selectedIndex == 3 ||
            _selectedIndex == 4 ||
            _selectedIndex == 5 ||
            _selectedIndex == 6);

    return Scaffold(
      backgroundColor: scheme.background,

      appBar: (_selectedIndex >= 3)
          ? null
          : AppBar(
              backgroundColor: scheme.background,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              elevation: 0,
              toolbarHeight: 120,
              title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _userDocStream(),
                builder: (context, userSnap) {
                  final userData = userSnap.data?.data();
                  final username = (userData?['username'] as String?) ?? 'User';

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _allAssignmentsSimpleStream(),
                    builder: (context, snap) {
                      if (_isFirstLoad && snap.connectionState == ConnectionState.waiting) {
                        return _buildTaskCounter(username, _cachedPendingTasks, scheme);
                      }
                      
                      if (snap.hasError) {
                        print('Error loading assignments: ${snap.error}');
                        return _buildTaskCounter(username, _cachedPendingTasks, scheme);
                      }

                      final pendingTasks = _countPendingTasks(snap.data);
                      return _buildTaskCounter(username, pendingTasks, scheme);
                    },
                  );
                },
              ),
              actions: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _userDocStream(),
                  builder: (context, userSnap) {
                    final userData = userSnap.data?.data();
                    final photoBase64 =
                        (userData?['photoBase64'] as String?) ?? '';

                    Widget child;
                    BoxDecoration decoration;

                    if (photoBase64.isNotEmpty) {
                      try {
                        final bytes = base64Decode(photoBase64);
                        decoration = BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: MemoryImage(bytes),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: scheme.primary.withOpacity(0.6),
                            width: 1.2,
                          ),
                        );
                        child = const SizedBox.shrink();
                      } catch (_) {
                        decoration = BoxDecoration(
                          color: scheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: scheme.outline),
                        );
                        child = Icon(
                          Icons.person,
                          color: scheme.onSurface,
                          size: 30,
                        );
                      }
                    } else {
                      decoration = BoxDecoration(
                        color: scheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: scheme.outline),
                      );
                      child = Icon(
                        Icons.person,
                        color: scheme.onSurface,
                        size: 30,
                      );
                    }

                    return Padding(
                      padding:
                          const EdgeInsets.only(right: 16.0, top: 20),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = 6;
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: decoration,
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

      body: Stack(
        children: [
          Column(
            children: [
              if (_selectedIndex == 0 ||
                  _selectedIndex == 1 ||
                  _selectedIndex == 2)
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
                    // SCHEDULE
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _schedulesForSelectedDay(),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snap.error}',
                              style: GoogleFonts.inter(
                                color: scheme.onBackground,
                              ),
                            ),
                          );
                        }
                        
                        if (!snap.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: scheme.primary,
                            ),
                          );
                        }

                        final schedules = snap.data!.docs
                            .map((d) => Schedule.fromDoc(d))
                            .toList();

                        return ScheduleTab(
                          schedules: schedules,
                          selectedDate: _selectedDateString,
                          onSelectDate: _selectDate,
                          onTapSchedule: _openScheduleDetail,
                        );
                      },
                    ),

                    // NOTES 
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _allNotesStream(),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snap.error}',
                              style: GoogleFonts.inter(
                                color: scheme.onBackground,
                              ),
                            ),
                          );
                        }
                        
                        if (!snap.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: scheme.primary,
                            ),
                          );
                        }

                        var notes = snap.data!.docs
                            .map((d) => Note.fromDoc(d))
                            .toList();

                        if (_noteSearchQuery.isNotEmpty) {
                          notes = notes.where((n) {
                            final t = n.title.toLowerCase();
                            final d = n.description.toLowerCase();
                            return t.contains(_noteSearchQuery) ||
                                d.contains(_noteSearchQuery);
                          }).toList();
                        }

                        return NoteTab(
                          notes: notes,
                          onSearch: _filterNotes,
                          onTapNote: _openNoteDetail,
                        );
                      },
                    ),

                    // ASSIGNMENTS 
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _allAssignmentsStream(),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          return StreamBuilder<
                              QuerySnapshot<Map<String, dynamic>>>(
                            stream: _allAssignmentsSimpleStream(),
                            builder: (context, snap2) {
                              if (!snap2.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: scheme.primary,
                                  ),
                                );
                              }
                              final assignments = snap2.data!.docs
                                  .map((d) => Assignment.fromDoc(d))
                                  .toList();

                              return AssignmentTab(
                                assignments: assignments,
                                selectedSubTabIndex: _assignmentTabIndex,
                                onSubTabChanged: (i) =>
                                    setState(() => _assignmentTabIndex = i),
                                onTapAssignment: _openAssignmentDetail,
                                onToggleStatus: _toggleAssignmentDone,
                              );
                            },
                          );
                        }

                        if (!snap.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: scheme.primary,
                            ),
                          );
                        }

                        final assignments = snap.data!.docs
                            .map((d) => Assignment.fromDoc(d))
                            .toList();

                        return AssignmentTab(
                          assignments: assignments,
                          selectedSubTabIndex: _assignmentTabIndex,
                          onSubTabChanged: (i) =>
                              setState(() => _assignmentTabIndex = i),
                          onTapAssignment: _openAssignmentDetail,
                          onToggleStatus: _toggleAssignmentDone,
                        );
                      },
                    ),

                    // STATISTICS
                    StatisticsScreen(
                      assignments: const [],
                      weeklyStudyHours: const [10, 25, 15, 20],
                    ),

                    // TAB 4: Mood
                    const MoodScreen(),

                    // TAB 5: Pomodoro
                    const PomodoroScreen(),

                    // TAB 6: Profile
                    const ProfileScreen(),
                  ],
                ),
              ),
            ],
          ),

          // ADD OPTIONS 
          AddOptionsFab(
            showAddOptions: _showAddOptions,
            onToggle: _toggleAddOptions,

            // ADD SCHEDULE
            onAddSchedule: () async {
              _hideAddOptions();

              final result = await Navigator.push<Schedule?>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditSchedulePage(isEditing: false),
                ),
              );

              if (!mounted) return;

              if (result != null) {
                showDialog(
                  context: context,
                  builder: (_) => const SuccessDialog(
                    title: 'Schedule saved successfully',
                  ),
                );
              }
            },

            // ADD NOTE
            onAddNote: () async {
              _hideAddOptions();

              final result = await Navigator.push<Note?>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditNotePage(isEditing: false),
                ),
              );

              if (!mounted) return;

              if (result != null) {
                showDialog(
                  context: context,
                  builder: (_) => const SuccessDialog(
                    title: 'Note saved successfully',
                  ),
                );
              }
            },

            // ADD ASSIGNMENT 
            onAddAssignment: () async {
              _hideAddOptions();

              final result = await Navigator.push<Assignment?>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AddEditAssignmentPage(isEditing: false),
                ),
              );

              if (!mounted) return;

              if (result != null) {
                showDialog(
                  context: context,
                  builder: (_) => const SuccessDialog(
                    title: 'Assignment saved successfully'),
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