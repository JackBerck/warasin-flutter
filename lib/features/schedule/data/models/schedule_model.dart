import 'package:flutter/material.dart';
import '../../../medicine/data/models/medicine_model.dart';

class Schedule {
  final String id;
  final String userId;
  final String medicineId;
  final TimeOfDay time;
  final List<int> days; // 1=Monday, 2=Tuesday, ..., 7=Sunday
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  // Optional - untuk UI saja
  Medicine? medicine;

  Schedule({
    required this.id,
    required this.userId,
    required this.medicineId,
    required this.time,
    required this.days,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.medicine,
  });

  // Convert TimeOfDay to string (HH:mm)
  static String timeToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Convert string to TimeOfDay
  static TimeOfDay stringToTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // Convert days list to string (comma separated)
  static String daysToString(List<int> days) {
    return days.join(',');
  }

  // Convert string to days list
  static List<int> stringToDays(String daysString) {
    return daysString.split(',').map((e) => int.parse(e)).toList();
  }

  // Get day name in Indonesian
  static String getDayName(int day) {
    const dayNames = {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
      7: 'Minggu',
    };
    return dayNames[day] ?? '';
  }

  // Get short day name
  static String getShortDayName(int day) {
    const dayNames = {
      1: 'Sen',
      2: 'Sel',
      3: 'Rab',
      4: 'Kam',
      5: 'Jum',
      6: 'Sab',
      7: 'Min',
    };
    return dayNames[day] ?? '';
  }

  // Convert to Map untuk SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'medicine_id': medicineId,
      'time': timeToString(time),
      'days': daysToString(days),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // Convert to Map untuk Supabase
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'medicine_id': medicineId,
      'time': timeToString(time),
      'days': days.map((d) => getDayName(d).toLowerCase()).toList(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create dari Map SQLite
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      userId: map['user_id'],
      medicineId: map['medicine_id'],
      time: stringToTime(map['time']),
      days: stringToDays(map['days']),
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isSynced: map['is_synced'] == 1,
    );
  }

  // Copy with
  Schedule copyWith({
    String? id,
    String? userId,
    String? medicineId,
    TimeOfDay? time,
    List<int>? days,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    Medicine? medicine,
  }) {
    return Schedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicineId: medicineId ?? this.medicineId,
      time: time ?? this.time,
      days: days ?? this.days,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      medicine: medicine ?? this.medicine,
    );
  }
}
