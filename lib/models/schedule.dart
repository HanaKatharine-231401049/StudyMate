import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;          
  final String title;
  final String date;          
  final String time;          
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

  factory Schedule.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Schedule(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      date: (data['dateString'] ?? '') as String, 
      time: (data['timeRange'] ?? '') as String,
      description: (data['description'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateString': date,
      'timeRange': time,
      'description': description,
    };
  }
}
