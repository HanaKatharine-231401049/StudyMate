// lib/models/schedule.dart
class Schedule {
  String title;
  String date; // contoh: "15 January 2025"
  String time; // contoh: "10.30 - 11.20" atau "10:30"
  String description;

  Schedule(this.title, this.date, this.time, this.description);

  Schedule copyWith({
    String? title,
    String? date,
    String? time,
    String? description,
  }) {
    return Schedule(
      title ?? this.title,
      date ?? this.date,
      time ?? this.time,
      description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Schedule(title: $title, date: $date, time: $time)';
  }
}
