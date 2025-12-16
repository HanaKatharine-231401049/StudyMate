import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart'; // Add this import

class StudyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userCol(String uid, String name) {
    return _db.collection('users').doc(uid).collection(name);
  }

  CollectionReference<Map<String, dynamic>> _notesCol(String uid) {
    return _db.collection('users').doc(uid).collection('notes');
  } 

  CollectionReference<Map<String, dynamic>> _schedulesCol(String uid) {
    return _userCol(uid, 'schedules');
  }

  // ---------------- SCHEDULES ----------------

  /// ADD schedule (DateTime in, Timestamp stored)
  Future<void> addSchedule({
    required String uid,
    required String title,
    required DateTime date,
    required String timeRange,
    required String description,
  }) async {
    await _schedulesCol(uid).add({
      'title': title,
      'date': Timestamp.fromDate(date), // ✅ for queries
      'dateString': DateFormat('yyyy-MM-dd').format(date), // ✅ for UI
      'timeRange': timeRange,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// UPDATE schedule (needs scheduleId / doc id)
  Future<void> updateSchedule({
    required String uid,
    required String scheduleId,
    required String title,
    required DateTime date,
    required String timeRange,
    required String description,
  }) async {
    await _schedulesCol(uid).doc(scheduleId).update({
      'title': title,
      'date': Timestamp.fromDate(date),
      'dateString': DateFormat('yyyy-MM-dd').format(date),
      'timeRange': timeRange,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Optional: read schedules for a specific day (now works)
  Stream<QuerySnapshot<Map<String, dynamic>>> schedulesForDay(
      String uid, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _schedulesCol(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .snapshots();
  }

  // ---------------- NOTES ----------------

  Future<void> addNote({
    required String uid,
    required String title,
    required DateTime date, // <-- change to DateTime
    required String description,
  }) async {
    await _notesCol(uid).add({
      'title': title,
      'date': Timestamp.fromDate(date),     // for queries
      'dateString': DateFormat('yyyy-MM-dd').format(date), // for UI if you want
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote({
    required String uid,
    required String noteId,
    required String title,
    required DateTime date,
    required String description,
  }) async {
    await _notesCol(uid).doc(noteId).update({
      'title': title,
      'date': Timestamp.fromDate(date),
      'dateString': DateFormat('yyyy-MM-dd').format(date),
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }


  Stream<QuerySnapshot<Map<String, dynamic>>> notesForDay(String uid, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _userCol(uid, 'notes')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .snapshots();
  }

  // ---------------- ASSIGNMENTS ----------------
  Future<String> addAssignment({
    required String uid,
    required String title,
    required DateTime dueDate,
    required String time,
    required String description,
  }) async {
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('assignments')
        .doc();

    final assignment = Assignment(
      id: ref.id,
      title: title,
      dueDate: dueDate,
      time: time,
      description: description,
      isFinished: false,
    );

    await ref.set(assignment.toMap(isNew: true));
    return ref.id;
  }

  Future<void> updateAssignment({
    required String uid,
    required String assignmentId,
    required String title,
    required DateTime dueDate,
    required String time,
    required String description,
    required bool isFinished,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('assignments')
        .doc(assignmentId)
        .update({
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'time': time,
      'description': description,
      'isFinished': isFinished,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> upcomingAssignments(String uid) {
    final now = Timestamp.fromDate(DateTime.now());

    return _userCol(uid, 'assignments')
        .where('dueDate', isGreaterThanOrEqualTo: now)
        .orderBy('dueDate')
        .snapshots();
  }

  Future<void> toggleAssignmentDone(String uid, String assignmentId, bool done) async {
    await _userCol(uid, 'assignments')
        .doc(assignmentId)
        .update({
          'isFinished': done,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}
