class Routine {
  String id;
  String title;
  String description;
  DateTime date;
  bool isCompleted;

  Routine({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        date: DateTime.parse(json['date']),
        isCompleted: json['isCompleted'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'isCompleted': isCompleted,
      };
}
