// lib/models/assignment.dart
class Assignment {
  String? id; // Ditambahkan untuk Firestore document ID
  String? userId; // Ditambahkan untuk user-specific data
  String title;
  String date;
  String time;
  String description;
  bool isFinished;
  DateTime? finishedAt; // Ditambahkan untuk timestamp selesai
  DateTime? createdAt; // Ditambahkan untuk timestamp
  DateTime? updatedAt; // Ditambahkan untuk timestamp

  Assignment({
    this.id,
    this.userId,
    required this.title,
    required this.date,
    required this.time,
    required this.description,
    this.isFinished = false,
    this.finishedAt,
    this.createdAt,
    this.updatedAt,
  });

  // copyWith untuk membuat salinan dengan perubahan tertentu
  Assignment copyWith({
    String? id,
    String? userId,
    String? title,
    String? date,
    String? time,
    String? description,
    bool? isFinished,
    DateTime? finishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      description: description ?? this.description,
      isFinished: isFinished ?? this.isFinished,
      finishedAt: finishedAt ?? this.finishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // helper toggle (mutasi sederhana, tetap kompatibel jika kamu menggunakan instance mutabel)
  void toggleFinished() {
    isFinished = !isFinished;
    finishedAt = isFinished ? DateTime.now() : null;
    updatedAt = DateTime.now();
  }

  // Convert to Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'date': date,
      'time': time,
      'description': description,
      'isFinished': isFinished,
      'finishedAt': finishedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Create from Firestore document
  factory Assignment.fromMap(String id, Map<String, dynamic> map) {
    return Assignment(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      description: map['description'] ?? '',
      isFinished: map['isFinished'] ?? false,
      finishedAt: map['finishedAt'] != null 
          ? DateTime.parse(map['finishedAt']) 
          : null,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
    );
  }
}