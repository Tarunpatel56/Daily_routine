class StudySession {
  StudySession({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.durationMilliseconds,
  });

  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationMilliseconds;

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      durationMilliseconds: (json['durationMilliseconds'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'durationMilliseconds': durationMilliseconds,
    };
  }
}
