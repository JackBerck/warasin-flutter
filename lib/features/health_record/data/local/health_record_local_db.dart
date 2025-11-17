import 'package:sqflite/sqflite.dart';
import '../../../../services/local_database_service.dart';
import '../models/health_record_model.dart';

class HealthRecordLocalDB {
  static final HealthRecordLocalDB instance = HealthRecordLocalDB._init();
  HealthRecordLocalDB._init();

  Future<Database> get database async {
    return await LocalDatabaseService.instance.database;
  }

  // Create health record
  Future<HealthRecord> create(HealthRecord record) async {
    final db = await database;
    await db.insert('health_records', record.toMap());
    return record;
  }

  // Get all records by user
  Future<List<HealthRecord>> getAllByUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      'health_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return maps.map((map) => HealthRecord.fromMap(map)).toList();
  }

  // Get record by id
  Future<HealthRecord?> getById(String id) async {
    final db = await database;
    final maps = await db.query(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return HealthRecord.fromMap(maps.first);
  }

  // Get record by date
  Future<HealthRecord?> getByDate(String userId, DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final maps = await db.query(
      'health_records',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateStr],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return HealthRecord.fromMap(maps.first);
  }

  // Get records in date range
  Future<List<HealthRecord>> getByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];

    final maps = await db.query(
      'health_records',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, startStr, endStr],
      orderBy: 'date DESC',
    );

    return maps.map((map) => HealthRecord.fromMap(map)).toList();
  }

  // Update record
  Future<int> update(HealthRecord record) async {
    final db = await database;
    return await db.update(
      'health_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Delete record
  Future<int> delete(String id) async {
    final db = await database;
    return await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }

  // Get unsynced records
  Future<List<HealthRecord>> getUnsynced(String userId) async {
    final db = await database;
    final maps = await db.query(
      'health_records',
      where: 'user_id = ? AND is_synced = 0',
      whereArgs: [userId],
    );

    return maps.map((map) => HealthRecord.fromMap(map)).toList();
  }

  // Mark as synced
  Future<int> markAsSynced(String id) async {
    final db = await database;
    return await db.update(
      'health_records',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get latest record
  Future<HealthRecord?> getLatest(String userId) async {
    final db = await database;
    final maps = await db.query(
      'health_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return HealthRecord.fromMap(maps.first);
  }
}
