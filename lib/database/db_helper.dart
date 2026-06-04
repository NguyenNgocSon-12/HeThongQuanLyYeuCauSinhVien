import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/request_model.dart';

class DBHelper {
  static const _databaseName = 'request.db';
  static const _databaseVersion = 2;
  static const _requestsTable = 'requests';

  static Database? _db;

  /// sqflite trong dự án hiện tại hỗ trợ Android, iOS và macOS.
  static bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  static Future<Database> get db async {
    if (!isSupported) {
      throw UnsupportedError('SQLite không được hỗ trợ trên nền tảng này.');
    }
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final databasePath = join(await getDatabasesPath(), _databaseName);

    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: _createTables,
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Schema bản cũ không khớp RequestModel nên tạo lại cache cục bộ.
          await database.execute('DROP TABLE IF EXISTS $_requestsTable');
          await _createTables(database, newVersion);
        }
      },
    );
  }

  static Future<void> _createTables(Database database, int version) async {
    await database.execute('''
      CREATE TABLE $_requestsTable(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        studentName TEXT NOT NULL,
        studentId TEXT NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        status TEXT NOT NULL,
        adminNote TEXT,
        processedBy TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        processedAt TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await database.execute(
      'CREATE INDEX idx_requests_user_created '
      'ON $_requestsTable(userId, createdAt DESC)',
    );
    await database.execute(
      'CREATE INDEX idx_requests_sync ON $_requestsTable(isSynced)',
    );
  }

  static Future<void> upsertRequest(RequestModel request) async {
    if (!isSupported || request.id == null) return;

    final database = await db;
    await database.insert(
      _requestsTable,
      request.toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<RequestModel>> getRequestsForUser(String userId) async {
    if (!isSupported) return [];

    final database = await db;
    final rows = await database.query(
      _requestsTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(RequestModel.fromLocalMap).toList();
  }

  static Future<List<RequestModel>> getPendingSync({String? userId}) async {
    if (!isSupported) return [];

    final database = await db;
    final rows = await database.query(
      _requestsTable,
      where: userId == null ? 'isSynced = ?' : 'isSynced = ? AND userId = ?',
      whereArgs: userId == null ? [0] : [0, userId],
      orderBy: 'createdAt ASC',
    );
    return rows.map(RequestModel.fromLocalMap).toList();
  }

  static Future<void> markSynced(String id) async {
    if (!isSupported) return;

    final database = await db;
    await database.update(
      _requestsTable,
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteRequest(String id) async {
    if (!isSupported) return;

    final database = await db;
    await database.delete(_requestsTable, where: 'id = ?', whereArgs: [id]);
  }
}
