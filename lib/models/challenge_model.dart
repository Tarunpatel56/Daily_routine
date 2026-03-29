class DailyLog {
  String id;
  DateTime date;
  String entry; // "what I did that day"

  DailyLog({required this.id, required this.date, required this.entry});

  factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
    id: json['id'],
    date: DateTime.parse(json['date']),
    entry: json['entry'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'entry': entry,
  };
}

class Challenge {
  String id;
  String title;
  String description;
  int totalDays;
  DateTime startDate;
  List<DailyLog> logs;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.totalDays,
    required this.startDate,
    List<DailyLog>? logs,
  }) : logs = logs ?? [];

  int get daysElapsed {
    final now = DateTime.now();
    // Calculate difference in midnight to midnight
    final startMidnight = DateTime(startDate.year, startDate.month, startDate.day);
    final nowMidnight = DateTime(now.year, now.month, now.day);
    final difference = nowMidnight.difference(startMidnight).inDays;
    return difference < 0 ? 0 : difference;
  }

  int get daysRemaining {
    final elapsed = daysElapsed;
    final remaining = totalDays - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    totalDays: json['totalDays'],
    startDate: DateTime.parse(json['startDate']),
    logs: (json['logs'] as List?)?.map((e) => DailyLog.fromJson(e)).toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'totalDays': totalDays,
    'startDate': startDate.toIso8601String(),
    'logs': logs.map((e) => e.toJson()).toList(),
  };
}
