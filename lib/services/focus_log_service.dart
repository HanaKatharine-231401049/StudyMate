// lib/services/focus_log_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/focus_log.dart';

class FocusLogService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userFocusLogsRef(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('focus_logs');
  }

  /// Add a focus log (called when a focus session completes)
  Future<void> addFocusLog({
    required String uid,
    required int durationSeconds,
    String source = 'pomodoro',
  }) async {
    await _userFocusLogsRef(uid).add({
      'durationSeconds': durationSeconds,
      'completedAt': FieldValue.serverTimestamp(),
      'source': source,
    });
  }

  /// Stream all focus logs for a user (newest first)
  Stream<List<FocusLog>> focusLogsStream(String uid) {
    return _userFocusLogsRef(uid)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FocusLog.fromDoc).toList());
  }

  /// Stream focus logs for a specific day (e.g. for "Today" stats)
  Stream<List<FocusLog>> focusLogsForDayStream(String uid, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _userFocusLogsRef(uid)
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('completedAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FocusLog.fromDoc).toList());
  }

  /// One-shot total minutes for a given day (used in Pomodoro "Focus Today")
  Future<int> totalFocusMinutesForDay(String uid, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final snap = await _userFocusLogsRef(uid)
        .where(
          'completedAt',                          // ✅ correct field
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where(
          'completedAt',
          isLessThan: Timestamp.fromDate(end),
        )
        .get();

    int totalSeconds = 0;

    for (final doc in snap.docs) {
      final data = doc.data();
      final secondsDynamic = data['durationSeconds'];

      if (secondsDynamic is int) {
        totalSeconds += secondsDynamic;
      } else if (secondsDynamic is num) {
        totalSeconds += secondsDynamic.toInt();
      }
    }

    return (totalSeconds / 60).round();
  }
}