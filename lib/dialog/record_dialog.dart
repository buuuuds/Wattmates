// dialog/record_dialog.dart
import 'package:flutter/material.dart';
import '../models/electricity_record.dart';

class RecordDialog {
  static void showAddDialog(
    BuildContext context,
    Function(ElectricityRecord) onAdd,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final roomController = TextEditingController();
    final kwhController = TextEditingController();
    final priceController = TextEditingController(text: '11.0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add, color: Colors.blue),
            SizedBox(width: 8),
            Text('Add New Record'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: roomController,
                  decoration: const InputDecoration(
                    labelText: 'Room',
                    prefixIcon: Icon(Icons.room),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Room is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: kwhController,
                  decoration: const InputDecoration(
                    labelText: 'Predicted kWh',
                    prefixIcon: Icon(Icons.flash_on),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'kWh is required';
                    if (double.tryParse(value!) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'kWh Price (₱)',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Price is required';
                    if (double.tryParse(value!) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final newRecord = ElectricityRecord(
                  id: '', // Firebase will auto-generate ID
                  name: nameController.text.trim(),
                  room: roomController.text.trim(),
                  predictedKwh: double.parse(kwhController.text),
                  kwhPrice: double.parse(priceController.text),
                  date: DateTime.now(),
                );

                onAdd(newRecord);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static void showEditDialog(
    BuildContext context,
    ElectricityRecord record,
    Function(ElectricityRecord) onEdit,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: record.name);
    final roomController = TextEditingController(text: record.room);
    final kwhController = TextEditingController(
      text: record.predictedKwh.toString(),
    );
    final priceController = TextEditingController(
      text: record.kwhPrice.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.orange),
            SizedBox(width: 8),
            Text('Edit Record'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: roomController,
                  decoration: const InputDecoration(
                    labelText: 'Room',
                    prefixIcon: Icon(Icons.room),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Room is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: kwhController,
                  decoration: const InputDecoration(
                    labelText: 'Predicted kWh',
                    prefixIcon: Icon(Icons.flash_on),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'kWh is required';
                    if (double.tryParse(value!) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'kWh Price (₱)',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Price is required';
                    if (double.tryParse(value!) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final updatedRecord = ElectricityRecord(
                  id: record.id,
                  name: nameController.text.trim(),
                  room: roomController.text.trim(),
                  predictedKwh: double.parse(kwhController.text),
                  kwhPrice: double.parse(priceController.text),
                  date: record.date,
                );

                onEdit(updatedRecord);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
