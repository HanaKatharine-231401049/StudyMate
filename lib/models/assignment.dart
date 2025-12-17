import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_utils.dart';

class Assignment {
  final String id;          
  final String title;
  final DateTime dueDate;   
  final String time;        
  final String description;
  final bool isFinished;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.time,
    required this.description,
    required this.isFinished,
  });

  String get dateString => DateUtilsHelper.formatDate(dueDate);

  Assignment copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    String? time,
    String? description,
    bool? isFinished,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      time: time ?? this.time,
      description: description ?? this.description,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  factory Assignment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final title = data['title']?.toString() ?? '';
    final time = (data['time'] ?? data['timeRange'] ?? '').toString();
    final description = data['description']?.toString() ?? '';

    final isFinished = data['isFinished'] is bool
        ? data['isFinished'] as bool
        : false;

    DateTime? dueDate;

    final dueDateTs = data['dueDate'];
    final dateTs = data['date'];

    if (dueDateTs is Timestamp) {
      dueDate = dueDateTs.toDate();
    } else if (dateTs is Timestamp) {
      dueDate = dateTs.toDate();
    } else if (data['dateString'] is String) {
      dueDate = DateUtilsHelper.tryParse(data['dateString'] as String);
    } else if (data['date'] is String) {
      dueDate = DateUtilsHelper.tryParse(data['date'] as String);
    }

    return Assignment(
      id: doc.id,
      title: title,
      dueDate: dueDate ?? DateTime.now(),
      time: time,
      description: description,
      isFinished: isFinished,
    );
  }

  Map<String, dynamic> toMap({bool isNew = false}) {
    return {
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'time': time,
      'description': description,
      'isFinished': isFinished,
      if (isNew) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
