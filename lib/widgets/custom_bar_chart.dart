import 'package:flutter/material.dart';

class CustomBarChart extends StatelessWidget {
  final Map<int, double> monthlyData;

  const CustomBarChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    double maxValue = monthlyData.values.isNotEmpty
        ? monthlyData.values.reduce((a, b) => a > b ? a : b)
        : 1000;

    if (maxValue == 0) maxValue = 1000;

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(12, (index) {
              int month = index + 1;
              double value = monthlyData[month] ?? 0;
              double height = value / maxValue * 200;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height.isNaN ? 0 : height,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: value > 0
                            ? Center(
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    '₱${value.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        months[index].split('').join('\n'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Monthly Bills Range: ₱0 - ₱${maxValue.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Total: ₱${monthlyData.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
