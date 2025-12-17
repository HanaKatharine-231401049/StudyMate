// lib/models/schedule.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;            // Firestore doc id
  final String title;
  final String date;          // formatted string for UI (e.g., "2025-12-10")
  final String time;          // time range string
  final String description;

  Schedule({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.description,
  });

  Schedule copyWith({
    String? id,
    String? title,
    String? date,
    String? time,
    String? description,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      description: description ?? this.description,
    );
  }

  /// Firestore -> Schedule
  factory Schedule.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Schedule(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      date: (data['dateString'] ?? '') as String, // read UI string
      time: (data['timeRange'] ?? '') as String,
      description: (data['description'] ?? '') as String,
    );
  }

  /// Schedule -> Firestore map (for local use; service adds timestamps)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateString': date,
      'timeRange': time,
      'description': description,
    };
  }
}