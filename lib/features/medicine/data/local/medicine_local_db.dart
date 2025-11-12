import 'package:sqflite/sqflite.dart';
import '../../../../services/local_database_service.dart';
import '../models/medicine_model.dart';

class MedicineLocalDB {
  static final MedicineLocalDB instance = MedicineLocalDB._init();
  MedicineLocalDB._init();

  Future<Database> get database async {
    return await LocalDatabaseService.instance.database;
  }

  // Create medicine
  Future<Medicine> create(Medicine medicine) async {
    final db = await database;
    await db.insert('medicines', medicine.toMap());
    return medicine;
  }

  // Read all medicines by user
  Future<List<Medicine>> getAllByUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      'medicines',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Medicine.fromMap(map)).toList();
  }

  // Read medicine by id
  Future<Medicine?> getById(String id) async {
    final db = await database;
    final maps = await db.query(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Medicine.fromMap(maps.first);
  }

  // Update medicine
  Future<int> update(Medicine medicine) async {
    final db = await database;
    return await db.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  // Delete medicine
  Future<int> delete(String id) async {
    final db = await database;
    return await db.delete(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get unsynced medicines
  Future<List<Medicine>> getUnsynced(String userId) async {
    final db = await database;
    final maps = await db.query(
      'medicines',
      where: 'user_id = ? AND is_synced = 0',
      whereArgs: [userId],
    );

    return maps.map((map) => Medicine.fromMap(map)).toList();
  }

  // Mark as synced
  Future<int> markAsSynced(String id) async {
    final db = await database;
    return await db.update(
      'medicines',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search medicines
  Future<List<Medicine>> search(String userId, String query) async {
    final db = await database;
    final maps = await db.query(
      'medicines',
      where: 'user_id = ? AND (name LIKE ? OR description LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Medicine.fromMap(map)).toList();
  }
}
