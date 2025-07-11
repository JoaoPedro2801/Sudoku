import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database? _database;

class DB {
  Future get database async {
    if (_database != null) return _database;
    _database = await _initializeDB('sudoku.db');
    return _database;
  }

  Future _initializeDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filepath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sudoku (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR NOT NULL,
      result VARCHAR NOT NULL,
      date VARCHAR NOT NULL,
      level INTEGER NOT NULL
      );
      ''');
  }

  Future addDB(String name, int result, String date, int level) async {
    final banco = await database;
    try {
      await banco.insert(
          'sudoku',
          {
            'name': name,
            'result': result,
            'date': date,
            'level': level,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
      print("Added to database");
    } catch (e) {
      print("Error adding to database: $e");
    }
  }
}
