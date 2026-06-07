import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'request.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE requests(
        id TEXT PRIMARY KEY,
        studentName TEXT,
        studentId TEXT,
        title TEXT,
        type TEXT,
        content TEXT,
        status INTEGER,
        date TEXT
      )
      ''');
    });
  }
}