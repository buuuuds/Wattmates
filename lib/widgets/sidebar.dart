// widgets/sidebar.dart
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFFFFE500).withOpacity(0.4),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: const Row(
              children: [
                Icon(Icons.electrical_services, color: Colors.green, size: 24),
                SizedBox(width: 10),
                Text(
                  'WATTMATES',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildSidebarItem(Icons.dashboard, 'Dashboard', 0),
          _buildSidebarItem(Icons.people, 'Records', 1),
          _buildSidebarItem(Icons.analytics, 'Reports', 2),
          _buildSidebarItem(Icons.history, 'History', 3),
          const Spacer(),
          _buildSidebarItem(Icons.settings, 'Settings', 4),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    bool isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.yellow.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.green : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.green : Colors.grey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => onItemSelected(index),
      ),
    );
  }
}
