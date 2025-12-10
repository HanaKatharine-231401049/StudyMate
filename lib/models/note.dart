// lib/models/note.dart
class Note {
  String? id; // Ditambahkan untuk Firestore document ID
  String? userId; // Ditambahkan untuk user-specific data
  String title;
  String date;
  String description;
  DateTime? createdAt; // Ditambahkan untuk timestamp
  DateTime? updatedAt; // Ditambahkan untuk timestamp

  Note({
    this.id,
    this.userId,
    required this.title,
    required this.date,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  // copyWith untuk membuat salinan dengan perubahan tertentu
  Note copyWith({
    String? id,
    String? userId,
    String? title,
    String? date,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      date: date ?? this.date,
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
      'description': description,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Create from Firestore document
  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      date: map['date'] ?? '',
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
  String toString() => 'Note(title: $title, date: $date)';
}