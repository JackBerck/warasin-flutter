import 'package:sqflite/sqflite.dart';
import '../../../../services/local_database_service.dart';
import '../models/schedule_model.dart';

class ScheduleLocalDB {
  static final ScheduleLocalDB instance = ScheduleLocalDB._init();
  ScheduleLocalDB._init();

  Future<Database> get database async {
    return await LocalDatabaseService.instance.database;
  }

  // Create schedule
  Future<Schedule> create(Schedule schedule) async {
    final db = await database;
    await db.insert('schedules', schedule.toMap());
    return schedule;
  }

  // Get all schedules by user
  Future<List<Schedule>> getAllByUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      'schedules',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'time ASC',
    );

    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  // Get schedule by id
  Future<Schedule?> getById(String id) async {
    final db = await database;
    final maps = await db.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Schedule.fromMap(maps.first);
  }

  // Get schedules by medicine
  Future<List<Schedule>> getByMedicine(String medicineId) async {
    final db = await database;
    final maps = await db.query(
      'schedules',
      where: 'medicine_id = ?',
      whereArgs: [medicineId],
      orderBy: 'time ASC',
    );

    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  // Get active schedules
  Future<List<Schedule>> getActiveSchedules(String userId) async {
    final db = await database;
    final maps = await db.query(
      'schedules',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'time ASC',
    );

    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  // Update schedule
  Future<int> update(Schedule schedule) async {
    final db = await database;
    return await db.update(
      'schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  // Delete schedule
  Future<int> delete(String id) async {
    final db = await database;
    return await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  // Toggle active status
  Future<int> toggleActive(String id, bool isActive) async {
    final db = await database;
    return await db.update(
      'schedules',
      {'is_active': isActive ? 1 : 0, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get unsynced schedules
  Future<List<Schedule>> getUnsynced(String userId) async {
    final db = await database;
    final maps = await db.query(
      'schedules',
      where: 'user_id = ? AND is_synced = 0',
      whereArgs: [userId],
    );

    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  // Mark as synced
  Future<int> markAsSynced(String id) async {
    final db = await database;
    return await db.update(
      'schedules',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
