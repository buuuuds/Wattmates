import 'package:flutter/material.dart';
import '../models/electricity_record.dart';
import '../widgets/custom_bar_chart.dart'; // StatCard import removed

class DashboardScreen extends StatefulWidget {
  final List<ElectricityRecord> records;

  const DashboardScreen({super.key, required this.records});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedClient = 'All Clients';
  List<String> _clients = ['All Clients'];

  @override
  void initState() {
    super.initState();
    _updateClientList();
  }

  void _updateClientList() {
    Set<String> clientNames = widget.records
        .map((record) => record.name)
        .toSet();
    _clients = ['All Clients'] + clientNames.toList();
  }

  @override
  Widget build(BuildContext context) {
    _updateClientList();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: DropdownButton<String>(
              value: _selectedClient,
              dropdownColor: theme.cardColor,
              style: theme.textTheme.bodyMedium,
              items: _clients
                  .map(
                    (client) =>
                        DropdownMenuItem(value: client, child: Text(client)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClient = value!;
                });
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatsCards(),
            const SizedBox(height: 20),
            Expanded(child: _buildChart(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    List<ElectricityRecord> filteredRecords = _selectedClient == 'All Clients'
        ? widget.records
        : widget.records
              .where((record) => record.name == _selectedClient)
              .toList();

    double totalKwh = filteredRecords.fold(
      0,
      (sum, record) => sum + record.predictedKwh,
    );
    double totalPrice = filteredRecords.fold(
      0,
      (sum, record) => sum + record.totalPrice,
    );
    int totalRecords = filteredRecords.length;

    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flash_on, color: Colors.orange, size: 32),
                    const SizedBox(height: 12),
                    Text('Total KWH', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      totalKwh.toStringAsFixed(1),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_money, color: Colors.green, size: 32),
                    const SizedBox(height: 12),
                    Text('Total Price', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      '₱${totalPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt, color: Colors.blue, size: 32),
                    const SizedBox(height: 12),
                    Text('Total Records', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      totalRecords.toString(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ThemeData theme) {
    List<ElectricityRecord> filteredRecords = _selectedClient == 'All Clients'
        ? widget.records
        : widget.records
              .where((record) => record.name == _selectedClient)
              .toList();

    // Group records by month
    Map<int, double> monthlyData = {};
    for (var record in filteredRecords) {
      int month = record.date.month;
      monthlyData[month] = (monthlyData[month] ?? 0) + record.totalPrice;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Electricity Bills (₱)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: CustomBarChart(monthlyData: monthlyData)),
        ],
      ),
    );
  }
}
