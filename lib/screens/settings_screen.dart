import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/electricity_record.dart';

class SettingsScreen extends StatelessWidget {
  final List<ElectricityRecord> records;
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.records,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    double totalKwh = records.fold(0, (sum, r) => sum + r.predictedKwh);
    double totalCost = records.fold(0, (sum, r) => sum + r.totalPrice);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total kWh: $totalKwh',
              style: textTheme.bodyLarge?.copyWith(fontSize: 18),
            ),
            Text(
              'Total Cost: ₱$totalCost',
              style: textTheme.bodyLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 24),

            // 🌙 Dark Mode Switch
            Card(
              color: colorScheme.surface,
              child: ListTile(
                leading: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: colorScheme.primary,
                ),
                title: Text('Dark Mode', style: textTheme.bodyLarge),
                subtitle: Text(
                  'Switch between light and dark themes',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: onThemeChanged,
                  activeColor: colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ❌ Reset All Records
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever),
              label: const Text('Reset All Records'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: colorScheme.surface,
                    title: const Text('Confirm Reset'),
                    content: const Text(
                      'Are you sure you want to delete all records?',
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: const Text('Yes, Reset'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await DatabaseHelper().clearAllData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All records have been reset.'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
