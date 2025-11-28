import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:studymate/screens/statistics_screen.dart';

// Import Model
import '../models/schedule.dart';
import '../models/assignment.dart';
import '../models/note.dart';

// Import Utility
import '../utils/colors.dart';
import '../utils/dialog_components.dart';

// Import Pages
import 'add_edit_schedule_screen.dart';
import 'add_edit_assignment_screen.dart';
import 'add_edit_note_screen.dart';
import 'detail_schedule_screen.dart';
import 'detail_assignment_screen.dart';
import 'detail_note_screen.dart';
import 'statistics_screen.dart';
import 'mood_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 0: Schedule, 1: Notes, 2: Assignment
  int _selectedIndex = 0;
  // 0: Unfinished, 1: Finished (untuk Assignment)
  int _assignmentTabIndex = 0;

  // Variabel untuk filter tanggal
  String _selectedDate = '15 January 2025';

  // State untuk menampilkan add options
  bool _showAddOptions = false;

  // --- Data Dummy ---
  List<Schedule> schedules = [
    Schedule('Grafika Komputer', '15 January 2025', '10.30 - 11.20',
        'ILK3103 - A, 2 SKS'),
    Schedule('Pemrograman Mobile', '15 January 2025', '10.30 - 11.20',
        'ILK3103 - A, 2 SKS'),
    Schedule('Struktur Data', '16 January 2025', '08.00 - 09.30',
        'ILK2205 - B, 3 SKS'),
  ];
  List<Assignment> assignments = [
    Assignment('Grafika Komputer - Primitive Drawing', '12 Jan 2025', '11.00',
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris quam orci, convallis nec enim eu, hendrerit imperdiet tortor. Nulla scelerisque posuere ullamcorper. Lorem ipsum dolor sit amet....',
        isFinished: false),
    Assignment('Pemrograman Mobile - UI/UX', '14 Jan 2025', '14.00',
        'Mauris quam orci, convallis nec enim eu, hendrerit imperdiet tortor.',
        isFinished: false),
    Assignment(
        'Jaringan Komputer', '10 Jan 2025', '18.00', 'Tugas sudah selesai',
        isFinished: true),
  ];
  List<Note> allNotes = [
    Note('Grafika Komputer - Primitive Drawing', '15 Jan 2025',
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris quam orci, convallis nec enim eu, hendrerit imperdiet tortor. Nulla scelerisque posuere ullamcorper. Lorem ipsum dolor sit amet....'),
    Note('Pemrograman Mobile - UI/UX', '16 Jan 2025',
        'Catatan penting tentang lifecycle stateful widget dan provider management.'),
  ];

  List<Note> filteredNotes = [];

  @override
  void initState() {
    super.initState();
    filteredNotes = allNotes;
  }

  // --- Fungsi Pencarian Note ---
  void _filterNotes(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      filteredNotes = allNotes.where((note) {
        return note.title.toLowerCase().contains(lowerCaseQuery) ||
            note.description.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }

  // --- Fungsi untuk memilih tanggal ---
  void _selectDate(String date) {
    setState(() {
      _selectedDate = date;
    });
  }

  // --- 1. Schedule Tab Widgets ---
  Widget _buildScheduleTab() {
    return Column(
      children: [
        // Header Hari
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('January',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              // Tombol Kalendar yang bisa diklik
              GestureDetector(
                onTap: _showCalendarDialog,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today,
                      size: 20, color: kInkTone),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Baris Tanggal (Bisa diklik)
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _buildDateItem('Mon', '14', '14 January 2025'),
              _buildDateItem('Tue', '15', '15 January 2025'),
              _buildDateItem('Wed', '16', '16 January 2025'),
              _buildDateItem('Thu', '17', '17 January 2025'),
              _buildDateItem('Fri', '18', '18 January 2025'),
              _buildDateItem('Sat', '19', '19 January 2025'),
              _buildDateItem('Sun', '20', '20 January 2025'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Daftar Jadwal
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount:
                schedules.where((s) => s.date.contains(_selectedDate)).length,
            itemBuilder: (context, index) {
              final schedule = schedules
                  .where((s) => s.date.contains(_selectedDate))
                  .toList()[index];
              return _buildScheduleItem(schedule, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem(String day, String date, String fullDate) {
    bool isSelected = _selectedDate == fullDate;
    return GestureDetector(
      onTap: () => _selectDate(fullDate),
      child: Container(
        width: 50,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? kInkTone.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(day,
                style: GoogleFonts.inter(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 12,
                    color: isSelected ? kInkTone : Colors.grey[700])),
            Text(date,
                style: GoogleFonts.inter(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    decoration: isSelected
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: kInkTone)),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog kalendar
  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Date',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: CalendarDatePicker(
              initialDate: DateTime(2025, 1, 15),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateChanged: (DateTime date) {
                String formattedDate =
                    '${date.day} ${_getMonthName(date.month)} ${date.year}';
                setState(() {
                  _selectedDate = formattedDate;
                });
                Navigator.pop(context);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text('Cancel', style: GoogleFonts.inter(color: kAccentColor)),
            ),
          ],
        );
      },
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  Widget _buildScheduleItem(Schedule schedule, int index) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailSchedulePage(
              schedule: schedule,
              onEdit: () {
                // Callback untuk edit
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditSchedulePage(
                        isEditing: true, schedule: schedule),
                  ),
                ).then((_) {
                  // Refresh data setelah edit
                  setState(() {});
                });
              },
              onDelete: () {
                // Callback untuk delete
                _confirmDeleteSchedule(index);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: kInkTone.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.access_time, size: 20, color: kInkTone),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(schedule.time,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(schedule.title,
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(schedule.description,
                      style: GoogleFonts.inter(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSchedule(int index) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Are you sure want to delete schedule?',
        icon: Icons.delete_forever,
        onConfirm: () {
          // Tutup dialog konfirmasi terlebih dahulu
          Navigator.pop(context);

          // Gunakan post frame callback untuk menghindari error navigator
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              schedules.removeAt(index);
            });

            // Tampilkan success dialog setelah state diupdate
            showDialog(
              context: context,
              builder: (context) => SuccessDialog(
                title: 'Schedule deleted successfully',
                onConfirm: () {
                  // Navigator.pop(context);
                },
              ),
            );
          });
        },
      ),
    );
  }

  // --- 2. Note Tab Widgets ---
  Widget _buildNoteTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text('List Notes',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: _filterNotes,
                  decoration: InputDecoration(
                    hintText: 'Search Notes',
                    hintStyle: GoogleFonts.inter(),
                    prefixIcon: const Icon(Icons.search, color: kAccentColor),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: kInkTone.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: kInkTone.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: kInkTone.withOpacity(0.5)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) {
              return _buildNoteItem(filteredNotes[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoteItem(Note note, int index) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailNotePage(
              note: note,
              onEdit: () {
                // Callback untuk edit
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEditNotePage(isEditing: true, note: note),
                  ),
                ).then((_) {
                  // Refresh data setelah edit
                  setState(() {});
                });
              },
              onDelete: () {
                // Callback untuk delete
                _confirmDeleteNote(note, index);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: kInkTone.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.title,
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(note.description,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteNote(Note note, int index) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Are you sure want to delete note?',
        icon: Icons.delete_forever,
        onConfirm: () {
          // Tutup dialog konfirmasi terlebih dahulu
          Navigator.pop(context);

          // Gunakan post frame callback untuk menghindari error navigator
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              allNotes.remove(note);
              _filterNotes('');
            });

            // Tampilkan success dialog setelah state diupdate
            showDialog(
              context: context,
              builder: (context) => SuccessDialog(
                title: 'Note deleted successfully',
                onConfirm: () {
                  // Navigator.pop(context);
                },
              ),
            );
          });
        },
      ),
    );
  }

  // --- 3. Assignment Tab Widgets ---
  Widget _buildAssignmentTab() {
    List<Assignment> filteredAssignments = _assignmentTabIndex == 0
        ? assignments.where((a) => !a.isFinished).toList()
        : assignments.where((a) => a.isFinished).toList();

    return Column(
      children: [
        // Toggle Button Finished/Unfinished
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              _buildAssignmentTabButton(0, 'Unfinished'),
              const SizedBox(width: 10),
              _buildAssignmentTabButton(1, 'Finished'),
            ],
          ),
        ),
        // Daftar Tugas
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: filteredAssignments.length,
            itemBuilder: (context, index) {
              final assignment = filteredAssignments[index];
              final originalIndex = assignments.indexOf(assignment);
              return _buildAssignmentItem(assignment, originalIndex);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentTabButton(int index, String title) {
    bool isSelected = _assignmentTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _assignmentTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kAccentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kAccentColor.withOpacity(0.5)),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : kAccentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentItem(Assignment assignment, int index) {
    bool isFinished = assignment.isFinished;
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailAssignmentPage(
              assignment: assignment,
              onEdit: () {
                // Callback untuk edit
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditAssignmentPage(
                        isEditing: true, assignment: assignment),
                  ),
                ).then((_) {
                  // Refresh data setelah edit
                  setState(() {});
                });
              },
              onDelete: () {
                // Callback untuk delete
                _confirmDeleteAssignment(index);
              },
              onToggleStatus: () {
                // Callback untuk toggle status
                setState(() {
                  assignment.toggleFinished();
                });
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: kInkTone.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: kInkTone),
                      const SizedBox(width: 5),
                      Text('${assignment.date}, ${assignment.time}',
                          style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(assignment.title,
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(assignment.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Ikon Ceklis/Reload
            GestureDetector(
              onTap: () {
                setState(() {
                  assignment.toggleFinished();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFinished ?  kSuccessColor : Colors.white ,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isFinished ? kSuccessColor : Colors.transparent),
                ),
                child: Icon(
                  isFinished ? Icons.check : Icons.check,
                  color: isFinished ?  Colors.white : kSuccessColor ,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAssignment(int index) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Are you sure want to delete assignment?',
        icon: Icons.delete_forever,
        onConfirm: () {
          // Tutup dialog konfirmasi terlebih dahulu
          Navigator.pop(context);

          // Gunakan post frame callback untuk menghindari error navigator
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              assignments.removeAt(index);
            });

            // Tampilkan success dialog setelah state diupdate
            showDialog(
              context: context,
              builder: (context) => SuccessDialog(
                title: 'Assignment deleted successfully',
                onConfirm: () {
                  // Navigator.pop(context);
                },
              ),
            );
          });
        },
      ),
    );
  }

  // --- Widget Utama ---
  @override
  Widget build(BuildContext context) {
    // final tabs = [
    //   _buildScheduleTab(),
    //   _buildNoteTab(),
    //   _buildAssignmentTab(),
    //   StatisticsContent(
    //     assignments: assignments,
    //     weeklyStudyHours: [10, 25, 15, 20],
    //   ),
    // ];

    int totalTasks = assignments.where((a) => !a.isFinished).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: (_selectedIndex == 3 || _selectedIndex == 4)
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
              if (_selectedIndex != 3 && _selectedIndex != 4)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      _buildHeaderTabButton(0, 'Schedule'),
                      const SizedBox(width: 10),
                      _buildHeaderTabButton(1, 'Notes'),
                      const SizedBox(width: 10),
                      _buildHeaderTabButton(2, 'Assignment'),
                    ],
                  ),
                ),

              // INDEXEDSTACK: render semua tab di sini, tapi tampilkan hanya index aktif
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    // Tab 0: Schedule
                    _buildScheduleTab(),

                    // Tab 1: Notes
                    _buildNoteTab(),

                    // Tab 2: Assignment
                    _buildAssignmentTab(),

                    // Tab 3: Statistics 
                    StatisticsScreen(
                      assignments: assignments,
                      weeklyStudyHours: [10, 25, 15, 20],
                    ),
                    // Tab 4: Mood / Music screen 
                    const MoodScreen(),
                  ],
                ),
              ),
            ],
          ),

          // Overlay untuk menutupi layar (tidak menutupi bottom nav)
          if (_showAddOptions)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom,
              child: GestureDetector(
                onTap: _hideAddOptions,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

          // Tombol Add Options (sama seperti sebelumnya)
          if (_showAddOptions)
            Positioned(
              right: 16,
              bottom: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildAddOptionButton('Schedule', Icons.schedule, () {
                    _hideAddOptions();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AddEditSchedulePage(isEditing: false),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  _buildAddOptionButton('Note', Icons.note_add, () {
                    _hideAddOptions();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddEditNotePage(isEditing: false),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  _buildAddOptionButton('Assignment', Icons.assignment, () {
                    _hideAddOptions();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AddEditAssignmentPage(isEditing: false),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: (_selectedIndex == 3 || _selectedIndex == 4)
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (_showAddOptions)
                  _hideAddOptions();
                else
                  _showAddOptionsFunc();
              },
              backgroundColor: kAccentColor,
              shape: const CircleBorder(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showAddOptions
                    ? const Icon(Icons.close,
                        color: Colors.white, size: 30, key: ValueKey('close'))
                    : const Icon(Icons.add,
                        color: Colors.white, size: 30, key: ValueKey('add')),
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  void _showAddOptionsFunc() {
    setState(() {
      _showAddOptions = true;
    });
  }

  void _hideAddOptions() {
    setState(() {
      _showAddOptions = false;
    });
  }

  Widget _buildHeaderTabButton(int index, String title) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
            if (index != 2) {
              _assignmentTabIndex = 0;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? kInkTone : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kInkTone.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : kInkTone,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(color: kAccentColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 0;
              });
            },
            child: const Icon(Icons.home, color: Colors.white, size: 30),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
            child: const Icon(Icons.access_time, color: Colors.white, size: 30),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
            }, // statistik sebagai tab ke-3
            child: const Icon(Icons.bar_chart, color: Colors.white, size: 30),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 4;
              });
            },
            child: const Icon(Icons.music_note, color: Colors.white, size: 30),
          ),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOptionButton(
      String title, IconData icon, VoidCallback onPressed) {
    const double buttonWidth = 170; // atur lebar sesuai yang diinginkan
    const double buttonHeight = 48; // atur tinggi sesuai yang diinginkan
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: buttonWidth, // pastikan semua sama lebar
        height: buttonHeight, // pastikan semua sama tinggi (opsional)
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kAccentColor),
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: kAccentColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            fixedSize: const Size(buttonWidth, buttonHeight),
            elevation: 0,
          ),
          icon: Icon(icon, size: 20),
          label: Text('+ $title',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }
}