import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('warasin.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        name TEXT,
        age INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create medicines table
    await db.execute('''
      CREATE TABLE medicines (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create schedules table
    await db.execute('''
      CREATE TABLE schedules (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        medicine_id TEXT NOT NULL,
        time TEXT NOT NULL,
        days TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE
      )
    ''');

    // Create health_records table
    await db.execute('''
      CREATE TABLE health_records (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        blood_pressure_systolic INTEGER,
        blood_pressure_diastolic INTEGER,
        blood_sugar REAL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> init() async {
    await database;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
