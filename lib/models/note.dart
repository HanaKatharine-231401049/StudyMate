import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Note {
  final String id;
  final String title;

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

    String dateString = (data['dateString'] ?? '') as String;

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
      'date': Timestamp.fromDate(dateObj), 
      'dateString': date,                  
      'description': description,
    };
  }
}