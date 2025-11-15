class Assignment {
  final String title;
  final String date;
  final String time;
  final String description;
  bool isFinished;

  Assignment(this.title, this.date, this.time, this.description,
      {this.isFinished = false});

  void toggleFinished() {
    isFinished = !isFinished;
  }
}