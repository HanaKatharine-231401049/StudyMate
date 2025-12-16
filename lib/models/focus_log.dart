// lib/models/focus_log.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FocusLog {
  final String id;              // Firestore doc id
  final int durationSeconds;    // how long the focus was
  final DateTime completedAt;   // when it finished
  final String source;          // e.g. "pomodoro"

  FocusLog({
    required this.id,
    required this.durationSeconds,
    required this.completedAt,
    this.source = 'pomodoro',
  });

  int get durationMinutes => (durationSeconds / 60).round();

  Map<String, dynamic> toMap() {
    return {
      'durationSeconds': durationSeconds,
      'completedAt': Timestamp.fromDate(completedAt),
      'source': source,
    };
  }

  factory FocusLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['completedAt'];
    final completed = ts is Timestamp ? ts.toDate() : DateTime.now();

    return FocusLog(
      id: doc.id,
      durationSeconds: (data['durationSeconds'] ?? 0) as int,
      completedAt: completed,
      source: (data['source'] ?? 'pomodoro') as String,
    );
  }
}
