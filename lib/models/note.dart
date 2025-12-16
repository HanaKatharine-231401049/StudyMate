// lib/models/note.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Note {
  final String id;
  final String title;

  /// UI-friendly formatted string (what your textfields show)
  final String date;

  final String description;

  Note({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
  });

  Note copyWith({
    String? id,
    String? title,
    String? date,
    String? description,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  factory Note.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // Prefer stored UI string if present
    String dateString = (data['dateString'] ?? '') as String;

    // If dateString missing, fall back to Timestamp -> formatted string
    final ts = data['date'];
    if (dateString.isEmpty && ts is Timestamp) {
      dateString = DateFormat('d MMMM yyyy').format(ts.toDate());
    }

    return Note(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      date: dateString,
      description: (data['description'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap({
    required DateTime dateObj,
  }) {
    return {
      'title': title,
      'date': Timestamp.fromDate(dateObj), // real firestore date
      'dateString': date,                  // UI string
      'description': description,
    };
  }
}
