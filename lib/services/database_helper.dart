// services/database_helper.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/electricity_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'electricity_records.db');
    debugLog('[DB PATH] SQLite DB Path: $path');

    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE electricity_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        room TEXT NOT NULL,
        predicted_kwh REAL NOT NULL,
        kwh_price REAL NOT NULL,
        total_price REAL NOT NULL,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_name ON electricity_records(name)');
    await db.execute('CREATE INDEX idx_date ON electricity_records(date)');
    await db.execute(
      'CREATE INDEX idx_room_date ON electricity_records(room, date)',
    );
  }

  Future<int> insertRecord(ElectricityRecord record) async {
    final db = await database;

    debugLog(
      '[INSERT] Trying to insert record for ${record.room} (${record.name})',
    );

    final startOfMonth = DateTime(record.date.year, record.date.month, 1);
    final endOfMonth = DateTime(
      record.date.month == 12 ? record.date.year + 1 : record.date.year,
      record.date.month == 12 ? 1 : record.date.month + 1,
      1,
    );

    final existing = await db.query(
      'electricity_records',
      where: 'room = ? AND date >= ? AND date < ?',
      whereArgs: [
        record.room,
        startOfMonth.toIso8601String(),
        endOfMonth.toIso8601String(),
      ],
    );

    debugLog('[CHECK] Existing records this month: ${existing.length}');

    if (existing.isNotEmpty) {
      debugLog('[INSERT] ❌ Skipped: Duplicate this month.');
      throw Exception('This room already has a record for this month.');
    }

    final id = await db.insert(
      'electricity_records',
      record.toSQLiteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugLog('[INSERT] ✅ Inserted record ID: $id');

    await _enforce12MonthLimit(record.name);
    return id;
  }

  // Isolate-friendly parsing
  static List<ElectricityRecord> _parseRecords(
    List<Map<String, dynamic>> maps,
  ) {
    return maps.map((map) => ElectricityRecord.fromSQLiteMap(map)).toList();
  }

  Future<List<ElectricityRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query('electricity_records', orderBy: 'date DESC');
    return compute(_parseRecords, maps);
  }

  Future<List<ElectricityRecord>> getRecentRecords(int limit) async {
    final db = await database;
    final maps = await db.query(
      'electricity_records',
      orderBy: 'date DESC',
      limit: limit,
    );
    return compute(_parseRecords, maps);
  }

  Future<List<ElectricityRecord>> getRecordsByClient(String clientName) async {
    final db = await database;
    final maps = await db.query(
      'electricity_records',
      where: 'name = ?',
      whereArgs: [clientName],
      orderBy: 'date DESC',
    );
    return compute(_parseRecords, maps);
  }

  Future<int> updateRecord(ElectricityRecord record) async {
    final db = await database;
    return await db.update(
      'electricity_records',
      record.toSQLiteMap(),
      where: 'id = ?',
      whereArgs: [int.parse(record.id)],
    );
  }

  Future<int> deleteRecord(String recordId) async {
    final db = await database;
    return await db.delete(
      'electricity_records',
      where: 'id = ?',
      whereArgs: [int.parse(recordId)],
    );
  }

  Future<List<ElectricityRecord>> searchRecords(String query) async {
    final db = await database;
    final maps = await db.query(
      'electricity_records',
      where: 'name LIKE ? OR room LIKE ? OR CAST(id as TEXT) LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return compute(_parseRecords, maps);
  }

  Future<Map<int, double>> getMonthlyData({String? clientName}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (clientName != null && clientName != 'All Clients') {
      whereClause = 'WHERE name = ?';
      whereArgs = [clientName];
    }

    final maps = await db.rawQuery('''
      SELECT 
        CAST(strftime('%m', date) AS INTEGER) as month,
        SUM(total_price) as total
      FROM electricity_records 
      $whereClause
      GROUP BY strftime('%m', date)
      ORDER BY month
    ''', whereArgs);

    return {
      for (var map in maps)
        map['month'] as int: (map['total'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future<Map<String, double>> getStatistics({String? clientName}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (clientName != null && clientName != 'All Clients') {
      whereClause = 'WHERE name = ?';
      whereArgs = [clientName];
    }

    final result = await db.rawQuery('''
      SELECT 
        SUM(predicted_kwh) as total_kwh,
        SUM(total_price) as total_price,
        COUNT(*) as total_records
      FROM electricity_records 
      $whereClause
    ''', whereArgs);

    if (result.isNotEmpty) {
      return {
        'totalKwh': _toDouble(result[0]['total_kwh']),
        'totalPrice': _toDouble(result[0]['total_price']),
        'totalRecords': _toDouble(result[0]['total_records']),
      };
    }

    return {'totalKwh': 0.0, 'totalPrice': 0.0, 'totalRecords': 0.0};
  }

  Future<List<String>> getClientNames() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT name FROM electricity_records ORDER BY name',
    );
    return maps.map((map) => map['name'] as String).toList();
  }

  Future<void> _enforce12MonthLimit(String clientName) async {
    final db = await database;
    final records = await db.query(
      'electricity_records',
      where: 'name = ?',
      whereArgs: [clientName],
      orderBy: 'date DESC',
    );

    if (records.length > 12) {
      for (int i = 12; i < records.length; i++) {
        await db.delete(
          'electricity_records',
          where: 'id = ?',
          whereArgs: [records[i]['id']],
        );
      }
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('electricity_records');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // ✅ FIXED: Add this private method to avoid _toDouble error
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// ✅ Debug log printer
void debugLog(String message) {
  const bool isDebug = !bool.fromEnvironment('dart.vm.product');
  if (isDebug) print(message);
}
