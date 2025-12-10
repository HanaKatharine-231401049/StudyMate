// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/assignment.dart';
import '../models/note.dart';
import '../models/schedule.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String usersCollection = 'users';

  FirestoreService();

  // ----------------- Helpers -----------------
  DocumentReference<Map<String, dynamic>> userRef(String uid) =>
      _db.collection(usersCollection).doc(uid);

  CollectionReference<Map<String, dynamic>> userSubCol(
          {required String uid, required String subcollection}) =>
      userRef(uid).collection(subcollection);

  String? get currentUserId => _auth.currentUser?.uid;

  String _resolveUid(String? uid) {
    final resolved = uid ?? currentUserId;
    if (resolved == null) {
      throw FirebaseException(
          plugin: 'firestore_service', message: 'No authenticated user (uid is null).');
    }
    return resolved;
  }

  // ----------------- USER OPERATIONS -----------------
  /// Ambil user doc snapshot
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) async {
    return await userRef(uid).get();
  }

  /// Buat user awal (merge: true sehingga tidak menimpa field lain)
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
    Map<String, dynamic>? extra,
  }) async {
    final docRef = userRef(uid);
    final data = <String, dynamic>{
      'name': name,
      'email': email,
      'photoUrl': photoUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (extra != null) data.addAll(extra);
    await docRef.set(data, SetOptions(merge: true));
  }

  /// Update user partial (merge)
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    await userRef(uid).set(updates, SetOptions(merge: true));
  }

  /// Hapus user
  Future<void> deleteUser(String uid) async {
    await userRef(uid).delete();
  }

  /// Dapatkan display name (fallback ke currentUser jika doc tidak ada)
  Future<String?> getUserDisplayName([String? uid]) async {
    final resolved = _resolveUid(uid);
    try {
      final doc = await userRef(resolved).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['name'] != null && (data['name'] as String).isNotEmpty) {
          return data['name'] as String;
        }
      }
      return _auth.currentUser?.displayName;
    } catch (e) {
      print('Error getting user display name: $e');
      return _auth.currentUser?.displayName;
    }
  }

  // ----------------- ASSIGNMENT OPERATIONS -----------------
  Future<Assignment> addAssignment(Assignment assignment, {String? uid}) async {
    try {
      final userId = _resolveUid(uid);
      final now = DateTime.now();
      final assignmentWithUser = assignment.copyWith(
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await userSubCol(uid: userId, subcollection: 'assignments')
          .add(assignmentWithUser.toMap());

      return assignmentWithUser.copyWith(id: docRef.id);
    } catch (e) {
      print('Error adding assignment: $e');
      rethrow;
    }
  }

  Future<void> updateAssignment(Assignment assignment, {String? uid}) async {
    try {
      final userId = _resolveUid(uid ?? assignment.userId);
      final updated = assignment.copyWith(updatedAt: DateTime.now());

      await userSubCol(uid: userId, subcollection: 'assignments')
          .doc(updated.id)
          .update(updated.toMap());
    } catch (e) {
      print('Error updating assignment: $e');
      rethrow;
    }
  }

  Future<void> deleteAssignment(String assignmentId, {String? uid}) async {
    try {
      final userId = _resolveUid(uid);
      await userSubCol(uid: userId, subcollection: 'assignments')
          .doc(assignmentId)
          .delete();
    } catch (e) {
      print('Error deleting assignment: $e');
      rethrow;
    }
  }

  Future<void> toggleAssignmentCompletion(String assignmentId, bool currentStatus,
      {String? uid}) async {
    try {
      final userId = _resolveUid(uid);
      final now = DateTime.now();
      await userSubCol(uid: userId, subcollection: 'assignments')
          .doc(assignmentId)
          .update({
        'isFinished': !currentStatus,
        'finishedAt': !currentStatus ? now.toIso8601String() : null,
        'updatedAt': now.toIso8601String(),
      });
    } catch (e) {
      print('Error toggling assignment: $e');
      rethrow;
    }
  }

  Stream<List<Assignment>> getAssignmentsStream({bool? isFinished, String? uid}) {
    final userId = _resolveUid(uid);
    final assignmentsRef = userSubCol(uid: userId, subcollection: 'assignments');

    Query<Map<String, dynamic>> query =
        assignmentsRef.orderBy('createdAt', descending: true) as Query<Map<String, dynamic>>;

    if (isFinished != null) {
      query = query.where('isFinished', isEqualTo: isFinished);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Assignment.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<Assignment> getAssignmentById(String assignmentId, {String? uid}) async {
    final userId = _resolveUid(uid);
    final doc = await userSubCol(uid: userId, subcollection: 'assignments')
        .doc(assignmentId)
        .get();
    if (doc.exists && doc.data() != null) {
      return Assignment.fromMap(doc.id, doc.data()!);
    } else {
      throw Exception('Assignment not found');
    }
  }

  // ----------------- NOTE OPERATIONS -----------------
  Future<Note> addNote(Note note, {String? uid}) async {
    try {
      final userId = _resolveUid(uid);
      final now = DateTime.now();
      final noteWithUser = note.copyWith(
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await userSubCol(uid: userId, subcollection: 'notes')
          .add(noteWithUser.toMap());

      return noteWithUser.copyWith(id: docRef.id);
    } catch (e) {
      print('Error adding note: $e');
      rethrow;
    }
  }

  Future<void> updateNote(Note note, {String? uid}) async {
    try {
      final userId = _resolveUid(uid ?? note.userId);
      final updated = note.copyWith(updatedAt: DateTime.now());

      await userSubCol(uid: userId, subcollection: 'notes')
          .doc(updated.id)
          .update(updated.toMap());
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(String noteId, {String? uid}) async {
    try {
      final userId = _resolveUid(uid);
      await userSubCol(uid: userId, subcollection: 'notes')
          .doc(noteId)
          .delete();
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }

  Stream<List<Note>> getNotesStream({String? uid}) {
    final userId = _resolveUid(uid);
    return userSubCol(uid: userId, subcollection: 'notes')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<Note>> searchNotes(String query, {String? uid}) {
    final userId = _resolveUid(uid);
    final lowerQuery = query.toLowerCase();
    return userSubCol(uid: userId, subcollection: 'notes')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Note.fromMap(doc.id, doc.data()))
          .where((note) =>
              note.title.toLowerCase().contains(lowerQuery) ||
              note.description.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  Future<Note> getNoteById(String noteId, {String? uid}) async {
    final userId = _resolveUid(uid);
    final doc = await userSubCol(uid: userId, subcollection: 'notes').doc(noteId).get();
    if (doc.exists && doc.data() != null) {
      return Note.fromMap(doc.id, doc.data()!);
    } else {
      throw Exception('Note not found');
    }
  }

  // ----------------- SCHEDULE OPERATIONS -----------------
  Future<Schedule> addSchedule(Schedule schedule, {String? uid}) async {
    try {
      final userId = _resolveUid(uid);
      final now = DateTime.now();
      final scheduleWithUser = schedule.copyWith(
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await userSubCol(uid: userId, subcollection: 'schedules')
          .add(scheduleWithUser.toMap());

      return scheduleWithUser.copyWith(id: docRef.id);
    } catch (e) {
      print('Error adding schedule: $e');
      rethrow;
    }
  }

  Future<void> updateSchedule(Schedule schedule, {String? uid}) async {
    try {
      final userId = _resolveUid(uid ?? schedule.userId);
      final updated = schedule.copyWith(updatedAt: DateTime.now());

      await userSubCol(uid: userId, subcollection: 'schedules')
          .doc(updated.id)
          .update(updated.toMap());
    } catch (e) {
      print('Error updating schedule: $e');
      rethrow;
    }
  }

  Future<void> deleteSchedule(String scheduleId, {String? uid}) async {
    try {
      final userId = _resolveUid(uid);
      await userSubCol(uid: userId, subcollection: 'schedules')
          .doc(scheduleId)
          .delete();
    } catch (e) {
      print('Error deleting schedule: $e');
      rethrow;
    }
  }

  Stream<List<Schedule>> getAllSchedules({String? uid}) {
    final userId = _resolveUid(uid);
    return userSubCol(uid: userId, subcollection: 'schedules')
        .orderBy('date')
        .orderBy('time')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<Schedule>> getSchedulesByDate(String dateString, {String? uid}) {
    final userId = _resolveUid(uid);
    return userSubCol(uid: userId, subcollection: 'schedules')
        .where('date', isEqualTo: dateString)
        .orderBy('time')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Schedule.fromMap(doc.id, doc.data())).toList());
  }

  Future<List<String>> getScheduleDates({String? uid}) async {
    final userId = _resolveUid(uid);
    final snapshot = await userSubCol(uid: userId, subcollection: 'schedules')
        .orderBy('date')
        .get();

    final dates = snapshot.docs
        .map((doc) => (doc.data()['date'] as String? ?? ''))
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    return dates;
  }

  Future<Schedule> getScheduleById(String scheduleId, {String? uid}) async {
    final userId = _resolveUid(uid);
    final doc = await userSubCol(uid: userId, subcollection: 'schedules')
        .doc(scheduleId)
        .get();
    if (doc.exists && doc.data() != null) {
      return Schedule.fromMap(doc.id, doc.data()!);
    } else {
      throw Exception('Schedule not found');
    }
  }
}
