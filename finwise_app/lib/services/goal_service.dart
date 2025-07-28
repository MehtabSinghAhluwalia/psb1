import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/financial_goal.dart';

class GoalService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'financial_goals.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE goals(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            targetAmount REAL,
            currentAmount REAL,
            targetDate TEXT,
            category TEXT,
            icon TEXT
          )
        ''');
      },
    );
  }

  Future<void> addGoal(FinancialGoal goal) async {
    final db = await database;
    await db.insert(
      'goals',
      goal.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FinancialGoal>> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals');
    return List.generate(maps.length, (i) => FinancialGoal.fromJson(maps[i]));
  }

  Future<void> updateGoal(FinancialGoal goal) async {
    final db = await database;
    await db.update(
      'goals',
      goal.toJson(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(String id) async {
    final db = await database;
    await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 