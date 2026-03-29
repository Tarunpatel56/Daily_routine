class StudyTarget {
  String id;
  String title;
  String description;
  DateTime targetDate;
  bool isCompleted;

  StudyTarget({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
    this.isCompleted = false,
  });

  factory StudyTarget.fromJson(Map<String, dynamic> json) => StudyTarget(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        targetDate: DateTime.parse(json['targetDate']),
        isCompleted: json['isCompleted'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetDate': targetDate.toIso8601String(),
        'isCompleted': isCompleted,
      };

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }
}
