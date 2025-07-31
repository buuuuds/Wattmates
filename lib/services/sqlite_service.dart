import 'dart:async';
import '../models/electricity_record.dart';
import 'database_helper.dart';

class SQLiteService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  static final StreamController<List<ElectricityRecord>> _recordsController =
      StreamController<List<ElectricityRecord>>.broadcast();

  static Stream<List<ElectricityRecord>> getRecordsStream() {
    _loadRecords();
    return _recordsController.stream;
  }

  static Future<void> _loadRecords() async {
    try {
      final records = await _dbHelper.getAllRecords();
      _recordsController.add(records);
    } catch (e) {
      _recordsController.addError(e);
    }
  }

  static Future<void> addRecord(ElectricityRecord record) async {
    try {
      final existing = await searchByNameAndRoom(record.name, record.room);
      if (existing.isNotEmpty) {
        throw Exception('Duplicate entry: same name and room already exist.');
      }

      final recordToAdd = ElectricityRecord(
        id: '',
        name: record.name,
        room: record.room,
        predictedKwh: record.predictedKwh,
        kwhPrice: record.kwhPrice,
        date: record.date,
      );

      await _dbHelper.insertRecord(recordToAdd);
      await _loadRecords();
    } catch (e) {
      print('Error adding record: \$e');
      rethrow;
    }
  }

  static Future<void> updateRecord(ElectricityRecord record) async {
    try {
      await _dbHelper.updateRecord(record);
      await _loadRecords();
    } catch (e) {
      print('Error updating record: \$e');
      rethrow;
    }
  }

  static Future<void> deleteRecord(String recordId) async {
    try {
      await _dbHelper.deleteRecord(recordId);
      await _loadRecords();
    } catch (e) {
      print('Error deleting record: \$e');
      rethrow;
    }
  }

  static Stream<List<ElectricityRecord>> getRecordsByClient(String clientName) {
    final StreamController<List<ElectricityRecord>> clientController =
        StreamController<List<ElectricityRecord>>.broadcast();

    final subscription = getRecordsStream().listen((records) {
      if (clientName == 'All Clients') {
        clientController.add(records);
      } else {
        final filteredRecords = records
            .where((record) => record.name == clientName)
            .toList();
        clientController.add(filteredRecords);
      }
    });

    clientController.onCancel = () => subscription.cancel();
    return clientController.stream;
  }

  static Future<List<ElectricityRecord>> searchRecords(String query) async {
    try {
      return await _dbHelper.searchRecords(query);
    } catch (e) {
      print('Error searching records: \$e');
      rethrow;
    }
  }

  static Future<Map<int, double>> getMonthlyData({String? clientName}) async {
    try {
      return await _dbHelper.getMonthlyData(clientName: clientName);
    } catch (e) {
      print('Error getting monthly data: \$e');
      return {};
    }
  }

  static Future<Map<String, double>> getStatistics({String? clientName}) async {
    try {
      return await _dbHelper.getStatistics(clientName: clientName);
    } catch (e) {
      print('Error getting statistics: \$e');
      return {'totalKwh': 0.0, 'totalPrice': 0.0, 'totalRecords': 0.0};
    }
  }

  static Future<List<String>> getClientNames() async {
    try {
      return await _dbHelper.getClientNames();
    } catch (e) {
      print('Error getting client names: \$e');
      return [];
    }
  }

  static Future<void> clearAllData() async {
    try {
      await _dbHelper.clearAllData();
      await _loadRecords();
    } catch (e) {
      print('Error clearing data: \$e');
      rethrow;
    }
  }

  static void dispose() {
    _recordsController.close();
  }

  static Future<List<ElectricityRecord>> searchByNameAndRoom(
    String name,
    String room,
  ) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'electricity_records',
        where: 'LOWER(name) = ? AND LOWER(room) = ?',
        whereArgs: [name.toLowerCase(), room.toLowerCase()],
      );
      return result.map((e) => ElectricityRecord.fromSQLiteMap(e)).toList();
    } catch (e) {
      print('Error searching by name and room: \$e');
      return [];
    }
  }

  static Future<void> initDatabase() async {
    await _dbHelper.database;
  }
}
