import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food.dart';
import '../models/log_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calorie_tracker.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories REAL NOT NULL,
        protein_g REAL NOT NULL,
        carbs_g REAL NOT NULL,
        fat_g REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE log_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        name TEXT NOT NULL,
        calories REAL NOT NULL,
        protein_g REAL NOT NULL,
        carbs_g REAL NOT NULL,
        fat_g REAL NOT NULL,
        servings REAL NOT NULL DEFAULT 1.0
      )
    ''');
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.insert('settings', {'key': 'daily_goal', 'value': '2000'});
  }

  // Settings
  Future<int> getDailyGoal() async {
    final db = await database;
    final result =
        await db.query('settings', where: 'key = ?', whereArgs: ['daily_goal']);
    if (result.isEmpty) return 2000;
    return int.parse(result.first['value'] as String);
  }

  Future<void> setDailyGoal(int calories) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': 'daily_goal', 'value': calories.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Foods (presets)
  Future<List<Food>> getFoods() async {
    final db = await database;
    final maps = await db.query('foods', orderBy: 'name ASC');
    return maps.map(Food.fromMap).toList();
  }

  Future<int> insertFood(Food food) async {
    final db = await database;
    return db.insert('foods', food.toMap());
  }

  Future<void> updateFood(Food food) async {
    final db = await database;
    await db.update('foods', food.toMap(),
        where: 'id = ?', whereArgs: [food.id]);
  }

  Future<void> deleteFood(int id) async {
    final db = await database;
    await db.delete('foods', where: 'id = ?', whereArgs: [id]);
  }

  // Log entries
  Future<List<LogEntry>> getEntriesForDate(String date) async {
    final db = await database;
    final maps = await db.query('log_entries',
        where: 'date = ?', whereArgs: [date], orderBy: 'id ASC');
    return maps.map(LogEntry.fromMap).toList();
  }

  Future<List<String>> getLoggedDates() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT DISTINCT date FROM log_entries ORDER BY date DESC');
    return result.map((r) => r['date'] as String).toList();
  }

  Future<int> insertLogEntry(LogEntry entry) async {
    final db = await database;
    return db.insert('log_entries', entry.toMap());
  }

  Future<void> updateLogEntry(LogEntry entry) async {
    final db = await database;
    await db.update('log_entries', entry.toMap(),
        where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<void> deleteLogEntry(int id) async {
    final db = await database;
    await db.delete('log_entries', where: 'id = ?', whereArgs: [id]);
  }
}
