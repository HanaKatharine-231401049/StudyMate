// lib/models/schedule.dart
class Schedule {
  String? id; // Ditambahkan untuk Firestore document ID
  String? userId; // Ditambahkan untuk user-specific data
  String title;
  String date;
  String time;
  String description;
  DateTime? createdAt; // Ditambahkan untuk timestamp
  DateTime? updatedAt; // Ditambahkan untuk timestamp

  Schedule({
    this.id,
    this.userId,
    required this.title,
    required this.date,
    required this.time,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  Schedule copyWith({
    String? id,
    String? userId,
    String? title,
    String? date,
    String? time,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'date': date,
      'time': time,
      'description': description,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Create from Firestore document
  factory Schedule.fromMap(String id, Map<String, dynamic> map) {
    return Schedule(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Schedule(title: $title, date: $date, time: $time)';
  }
}