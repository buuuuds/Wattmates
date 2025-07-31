import 'dart:async';
import 'package:flutter/material.dart';
import '../models/electricity_record.dart';
import '../services/sqlite_service.dart';
import '../widgets/record_item.dart';
import '../dialog/record_dialog.dart';

class RecordsScreen extends StatefulWidget {
  final List<ElectricityRecord> records;

  const RecordsScreen({super.key, required this.records});

  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String _searchQuery = '';
  List<ElectricityRecord> _filteredRecords = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filteredRecords = _removeDuplicateRecords(widget.records);
  }

  @override
  void didUpdateWidget(RecordsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_searchQuery.isEmpty) {
      _filteredRecords = _removeDuplicateRecords(widget.records);
    } else {
      _performSearch(_searchQuery);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _filterRecords(String query) {
    _searchQuery = query;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        setState(() {
          _filteredRecords = _removeDuplicateRecords(widget.records);
          _isSearching = false;
        });
      } else {
        _performSearch(query);
      }
    });
  }

  void _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final searchResults = await SQLiteService.searchRecords(query);
      final filtered = _removeDuplicateRecords(searchResults);
      setState(() {
        _filteredRecords = filtered;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _filteredRecords = [];
        _isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching records: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  List<ElectricityRecord> _removeDuplicateRecords(
    List<ElectricityRecord> records,
  ) {
    final seen = <String>{};
    return records.where((record) {
      final key = '${record.name.toLowerCase()}|${record.room.toLowerCase()}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  Future<void> _addRecord(ElectricityRecord record) async {
    try {
      final existing = await SQLiteService.searchByNameAndRoom(
        record.name,
        record.room,
      );
      if (existing.isNotEmpty) {
        throw Exception('Duplicate entry: same name and room already exist.');
      }

      await SQLiteService.addRecord(record);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Record added successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error adding record: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _updateRecord(ElectricityRecord record) async {
    try {
      await SQLiteService.updateRecord(record);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Record updated successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error updating record: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _deleteRecord(String recordId) async {
    try {
      await SQLiteService.deleteRecord(recordId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Record deleted successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error deleting record: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Electricity Records'),
        backgroundColor:
            theme.appBarTheme.backgroundColor ??
            (isDark ? Colors.grey[900] : Colors.white),
        foregroundColor:
            theme.appBarTheme.foregroundColor ??
            (isDark ? Colors.white : Colors.black),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => RecordDialog.showAddDialog(context, _addRecord),
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: isDark ? Colors.grey[850] : Colors.white,
              child: TextField(
                onChanged: _filterRecords,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: 'Search by name, date, or value',
                  labelStyle: TextStyle(color: theme.hintColor),
                  prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredRecords.isEmpty
                    ? Center(
                        child: Text(
                          'No records found.',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        key: ValueKey(_filteredRecords.length),
                        itemCount: _filteredRecords.length,
                        itemBuilder: (context, index) {
                          final record = _filteredRecords[index];
                          return RecordItem(
                            record: record,
                            onEdit: () => RecordDialog.showEditDialog(
                              context,
                              record,
                              _updateRecord,
                            ),
                            onDelete: () => _deleteRecord(record.id),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
