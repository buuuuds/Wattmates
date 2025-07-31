import 'package:flutter/material.dart';
import '../models/electricity_record.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final List<ElectricityRecord> records;

  const HistoryScreen({super.key, required this.records});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedMonth = 'All';
  late final List<String> _cachedMonthList;

  @override
  void initState() {
    super.initState();
    _cachedMonthList =
        ['All'] +
              widget.records
                  .map((r) => DateFormat('yyyy-MM').format(r.date))
                  .toSet()
                  .toList()
          ..sort((a, b) => b.compareTo(a)); // newest first
  }

  List<ElectricityRecord> get _filteredRecords {
    if (_selectedMonth == 'All') return widget.records;
    return widget.records.where((record) {
      final recordMonth = DateFormat('yyyy-MM').format(record.date);
      return recordMonth == _selectedMonth;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[200];
    final appBarBg = isDark ? Colors.black : Colors.white;
    final appBarFg = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.black : Colors.white;
    final dividerColor = isDark ? Colors.grey[800] : Colors.grey[300];
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          DropdownButton<String>(
            value: _selectedMonth,
            onChanged: (value) {
              setState(() {
                _selectedMonth = value!;
              });
            },
            items: _cachedMonthList
                .map(
                  (month) => DropdownMenuItem(
                    value: month,
                    child: Text(
                      month == 'All'
                          ? 'All Clients'
                          : DateFormat(
                              'MMMM yyyy',
                            ).format(DateFormat('yyyy-MM').parse(month)),
                      style: TextStyle(color: textColor),
                    ),
                  ),
                )
                .toList(),
            underline: const SizedBox(),
            icon: Icon(Icons.filter_list, color: textColor),
            dropdownColor: cardColor,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _filteredRecords.isEmpty
            ? Center(
                child: Text(
                  'No records for selected month.',
                  style: TextStyle(color: subtitleColor, fontSize: 16),
                ),
              )
            : ListView.separated(
                itemCount: _filteredRecords.length,
                separatorBuilder: (_, __) =>
                    Divider(color: dividerColor, thickness: 1),
                itemBuilder: (_, index) {
                  final record = _filteredRecords.elementAt(index);
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: const Icon(
                        Icons.history,
                        color: Colors.orangeAccent,
                      ),
                      title: Text(
                        record.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room: ${record.room}',
                            style: TextStyle(color: subtitleColor),
                          ),
                          Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(record.date)}',
                            style: TextStyle(color: subtitleColor),
                          ),
                          Text(
                            'KWH: ${record.predictedKwh.toStringAsFixed(1)}',
                            style: TextStyle(color: subtitleColor),
                          ),
                        ],
                      ),
                      trailing: Text(
                        '₱${record.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
