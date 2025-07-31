import 'package:intl/intl.dart';

class ElectricityRecord {
  final String id;
  final String name;
  final String room;
  final double predictedKwh;
  final double kwhPrice;
  final DateTime date;
  final double totalPrice;

  ElectricityRecord({
    required this.id,
    required this.name,
    required this.room,
    required this.predictedKwh,
    required this.kwhPrice,
    required this.date,
  }) : totalPrice = predictedKwh * kwhPrice;

  String get monthYear => DateFormat('MMMM yyyy').format(date);
  String get displayDate => DateFormat('MMM dd, yyyy').format(date);

  // ✅ Rename this from `toMap` to `toSQLiteMap`
  Map<String, dynamic> toSQLiteMap() {
    return {
      'id': int.tryParse(id),
      'name': name,
      'room': room,
      'predicted_kwh': predictedKwh,
      'kwh_price': kwhPrice,
      'total_price': totalPrice,
      'date': date.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  // ✅ Rename this from `fromMap` to `fromSQLiteMap`
  factory ElectricityRecord.fromSQLiteMap(Map<String, dynamic> map) {
    return ElectricityRecord(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      room: map['room'] ?? '',
      predictedKwh: (map['predicted_kwh'] ?? 0.0).toDouble(),
      kwhPrice: (map['kwh_price'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }

  ElectricityRecord copyWith({
    String? id,
    String? name,
    String? room,
    double? predictedKwh,
    double? kwhPrice,
    DateTime? date,
  }) {
    return ElectricityRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      predictedKwh: predictedKwh ?? this.predictedKwh,
      kwhPrice: kwhPrice ?? this.kwhPrice,
      date: date ?? this.date,
    );
  }
}
