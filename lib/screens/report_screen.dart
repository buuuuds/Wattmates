import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/electricity_record.dart';

class ReportsScreen extends StatefulWidget {
  final List<ElectricityRecord> records;

  const ReportsScreen({super.key, required this.records});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = [
    'This Month',
    'Last Month',
    'Last 3 Months',
    'Last 6 Months',
    'This Year',
    'All Time',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _getFilteredRecords();
    final topConsumers = _getTopConsumers(filteredRecords);
    final statistics = _calculateStatistics(filteredRecords);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              items: _periods
                  .map(
                    (period) =>
                        DropdownMenuItem(value: period, child: Text(period)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
              },
              underline: const SizedBox(),
              icon: Icon(
                Icons.filter_list,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(context, statistics),
            const SizedBox(height: 24),
            _buildExportSection(context),
            const SizedBox(height: 24),
            _buildTopConsumersSection(context, topConsumers),
            const SizedBox(height: 24),
            _buildMonthlyBreakdown(context, filteredRecords),
            const SizedBox(height: 24),
            _buildRoomPerformance(context, filteredRecords),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, Map<String, double> stats) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary for $_selectedPeriod',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatCard(
                context,
                'Total Revenue',
                '₱${stats['totalRevenue']!.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.green,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context,
                'Total kWh',
                '${stats['totalKwh']!.toStringAsFixed(1)}',
                Icons.flash_on,
                Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context,
                'Average Bill',
                '₱${stats['averageBill']!.toStringAsFixed(2)}',
                Icons.receipt,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context,
                'Active Tenants',
                '${stats['activeTenants']!.toInt()}',
                Icons.people,
                Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ), // 👈 Added margin
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.25)
                : Colors.grey.withOpacity(0.1),
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
            'Export Reports',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportToPDF(),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportToExcel(),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Export Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _exportToCSV(),
              icon: const Icon(Icons.text_snippet),
              label: const Text('Export CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopConsumersSection(
    BuildContext context,
    List<Map<String, dynamic>> topConsumers,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.25)
                : Colors.grey.withOpacity(0.1),
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
            'Top Consumers',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (topConsumers.isEmpty)
            Center(
              child: Text(
                'No data available for selected period',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            )
          else
            ...topConsumers.asMap().entries.map((entry) {
              final index = entry.key;
              final consumer = entry.value;
              return _buildConsumerTile(
                context,
                index + 1,
                consumer['name'],
                consumer['room'],
                consumer['totalKwh'],
                consumer['totalAmount'],
                consumer['recordCount'],
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildConsumerTile(
    BuildContext context,
    int rank,
    String name,
    String room,
    double totalKwh,
    double totalAmount,
    int recordCount,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Rank Colors
    Color rankColor = rank == 1
        ? kGoldColor
        : rank == 2
        ? Colors.grey[400]!
        : Colors.brown[300]!;
    IconData rankIcon = rank == 1
        ? Icons.emoji_events
        : rank == 2
        ? Icons.military_tech
        : Icons.workspace_premium;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(rankIcon, color: Colors.white, size: 16),
                Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Consumer Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  room,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                Text(
                  '$recordCount bill${recordCount != 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Usage Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${totalKwh.toStringAsFixed(1)} kWh',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromARGB(255, 223, 204, 39),
                ),
              ),
              Text(
                '₱${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdown(
    BuildContext context,
    List<ElectricityRecord> records,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final monthlyData = <String, Map<String, double>>{};

    for (final record in records) {
      final monthKey = DateFormat('yyyy-MM').format(record.date);
      monthlyData[monthKey] ??= {'kwh': 0, 'amount': 0, 'count': 0};
      monthlyData[monthKey]!['kwh'] =
          monthlyData[monthKey]!['kwh']! + record.predictedKwh;
      monthlyData[monthKey]!['amount'] =
          monthlyData[monthKey]!['amount']! + record.totalPrice;
      monthlyData[monthKey]!['count'] = monthlyData[monthKey]!['count']! + 1;
    }

    final sortedEntries = monthlyData.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedEntries.take(6).map((entry) {
            final monthName = DateFormat(
              'MMMM yyyy',
            ).format(DateFormat('yyyy-MM').parse(entry.key));
            final data = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.2), // 👈 white-ish stroke
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${data['count']!.toInt()} records',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${data['kwh']!.toStringAsFixed(1)} kWh',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 223, 204, 39),
                        ),
                      ),
                      Text(
                        '₱${data['amount']!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRoomPerformance(
    BuildContext context,
    List<ElectricityRecord> records,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final roomData = <String, Map<String, double>>{};

    for (final record in records) {
      roomData[record.room] ??= {'kwh': 0, 'amount': 0, 'count': 0};
      roomData[record.room]!['kwh'] =
          roomData[record.room]!['kwh']! + record.predictedKwh;
      roomData[record.room]!['amount'] =
          roomData[record.room]!['amount']! + record.totalPrice;
      roomData[record.room]!['count'] = roomData[record.room]!['count']! + 1;
    }

    final sortedRooms = roomData.entries.toList()
      ..sort((a, b) => b.value['amount']!.compareTo(a.value['amount']!));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3) // darker shadow for dark mode
                : Colors.grey.withOpacity(0.1), // lighter for light mode
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room Performance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedRooms.take(10).map((entry) {
            final room = entry.key;
            final data = entry.value;
            final avgBill = data['amount']! / data['count']!;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.2), // 👈 white-ish stroke
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Avg: ₱${avgBill.toStringAsFixed(2)}/bill',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${data['kwh']!.toStringAsFixed(1)} kWh',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 223, 204, 39),
                        ),
                      ),
                      Text(
                        '₱${data['amount']!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  List<ElectricityRecord> _getFilteredRecords() {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'This Month':
        return widget.records
            .where(
              (record) =>
                  record.date.year == now.year &&
                  record.date.month == now.month,
            )
            .toList();

      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1);
        return widget.records
            .where(
              (record) =>
                  record.date.year == lastMonth.year &&
                  record.date.month == lastMonth.month,
            )
            .toList();

      case 'Last 3 Months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3);
        return widget.records
            .where((record) => record.date.isAfter(threeMonthsAgo))
            .toList();

      case 'Last 6 Months':
        final sixMonthsAgo = DateTime(now.year, now.month - 6);
        return widget.records
            .where((record) => record.date.isAfter(sixMonthsAgo))
            .toList();

      case 'This Year':
        return widget.records
            .where((record) => record.date.year == now.year)
            .toList();

      default: // All Time
        return widget.records;
    }
  }

  List<Map<String, dynamic>> _getTopConsumers(List<ElectricityRecord> records) {
    final consumerData = <String, Map<String, dynamic>>{};

    for (final record in records) {
      final key = '${record.name}|${record.room}';
      if (!consumerData.containsKey(key)) {
        consumerData[key] = {
          'name': record.name,
          'room': record.room,
          'totalKwh': 0.0,
          'totalAmount': 0.0,
          'recordCount': 0,
        };
      }

      consumerData[key]!['totalKwh'] += record.predictedKwh;
      consumerData[key]!['totalAmount'] += record.totalPrice;
      consumerData[key]!['recordCount']++;
    }

    final sortedConsumers = consumerData.values.toList()
      ..sort((a, b) => b['totalAmount'].compareTo(a['totalAmount']));

    return sortedConsumers.take(10).toList();
  }

  Map<String, double> _calculateStatistics(List<ElectricityRecord> records) {
    if (records.isEmpty) {
      return {
        'totalRevenue': 0.0,
        'totalKwh': 0.0,
        'averageBill': 0.0,
        'activeTenants': 0.0,
      };
    }

    final totalRevenue = records.fold(
      0.0,
      (sum, record) => sum + record.totalPrice,
    );
    final totalKwh = records.fold(
      0.0,
      (sum, record) => sum + record.predictedKwh,
    );
    final uniqueTenants = records
        .map((r) => '${r.name}|${r.room}')
        .toSet()
        .length;

    return {
      'totalRevenue': totalRevenue,
      'totalKwh': totalKwh,
      'averageBill': totalRevenue / records.length,
      'activeTenants': uniqueTenants.toDouble(),
    };
  }

  void _exportToPDF() {
    // TODO: Implement PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            Text('PDF export feature coming soon!'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportToExcel() {
    // TODO: Implement Excel export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            Text('Excel export feature coming soon!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportToCSV() {
    // TODO: Implement CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            Text('CSV export feature coming soon!'),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Gold color constant (not available by default)
const Color kGoldColor = Color(0xFFFFD700);
