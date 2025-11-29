// lib/models/assignment.dart
class Assignment {
  String title;
  String date;
  String time;
  String description;
  bool isFinished;

  Assignment(
    this.title,
    this.date,
    this.time,
    this.description, {
    this.isFinished = false,
  });

  // copyWith untuk membuat salinan dengan perubahan tertentu
  Assignment copyWith({
    String? title,
    String? date,
    String? time,
    String? description,
    bool? isFinished,
  }) {
    return Assignment(
      title ?? this.title,
      date ?? this.date,
      time ?? this.time,
      description ?? this.description,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  // helper toggle (mutasi sederhana, tetap kompatibel jika kamu menggunakan instance mutabel)
  void toggleFinished() {
    isFinished = !isFinished;
  }
}
