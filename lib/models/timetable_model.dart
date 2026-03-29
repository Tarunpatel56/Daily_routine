import 'package:flutter/material.dart';

class TimetableEntry {
  String id;
  String title;
  TimeOfDay startTime;
  TimeOfDay endTime;

  TimetableEntry({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) => TimetableEntry(
    id: json['id'],
    title: json['title'],
    startTime: TimeOfDay(hour: json['startHour'], minute: json['startMinute']),
    endTime: TimeOfDay(hour: json['endHour'], minute: json['endMinute']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startHour': startTime.hour,
    'startMinute': startTime.minute,
    'endHour': endTime.hour,
    'endMinute': endTime.minute,
  };
}
