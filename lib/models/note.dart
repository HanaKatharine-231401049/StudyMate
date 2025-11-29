// lib/models/note.dart
class Note {
  String title;
  String date;
  String description;

  Note(this.title, this.date, this.description);

  // copyWith untuk membuat salinan dengan perubahan tertentu
  Note copyWith({
    String? title,
    String? date,
    String? description,
  }) {
    return Note(
      title ?? this.title,
      date ?? this.date,
      description ?? this.description,
    );
  }

  @override
  String toString() => 'Note(title: $title, date: $date)';
}
