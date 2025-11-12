import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  LocalDatabaseService._init();
  static final LocalDatabaseService instance = LocalDatabaseService._init();

  static Database? _database;

  // Bump versi saat menambah/mengubah schema
  static const int _dbVersion = 2;
  static const String _dbName = 'warasin.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
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

    // Create medicines table (inkluding stock)
    await db.execute('''
      CREATE TABLE medicines (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT,
        description TEXT,
        stock INTEGER DEFAULT 0,
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Jika versi lama belum punya kolom stock, tambahkan
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE medicines ADD COLUMN stock INTEGER DEFAULT 0;');
      } catch (_) {
        // ignore jika gagal (mis. kolom sudah ada)
      }
    }
    // Tambahkan migrasi berikutnya disini bila naik versi lagi
  }

  Future<void> _onOpen(Database db) async {
    // Safety check: kalau tabel ada tapi kolom stock belum ada, tambahkan
    try {
      final info = await db.rawQuery("PRAGMA table_info(medicines);");
      final hasStock = info.any((row) => row['name'] == 'stock');
      if (!hasStock) {
        await db.execute('ALTER TABLE medicines ADD COLUMN stock INTEGER DEFAULT 0;');
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> init() async {
    await database;
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }

  // Utility untuk development: hapus DB file (opsional)
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);
    _database = null;
  }
}