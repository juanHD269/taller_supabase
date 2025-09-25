import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class ChartWidget extends StatelessWidget {
  final List<FinanceTx> items;
  const ChartWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final totals = _categoryTotals();
    if (totals.isEmpty) {
      return const Card(
        child: SizedBox(
          height: 180,
          child: Center(child: Text('No data to chart')),
        ),
      );
    }

    final sections = <PieChartSectionData>[];
    final totalSum = totals.values.fold<double>(0, (a, b) => a + b);
    double radius = 60;

    totals.forEach((cat, amount) {
      final pct = amount / totalSum * 100;
      sections.add(
        PieChartSectionData(
          value: amount,
          title: '${pct.toStringAsFixed(0)}%',
          radius: radius,
        ),
      );
      radius -= 2; // pequeño escalón visual
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Expenses by Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(sections: sections, sectionsSpace: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _categoryTotals() {
    final map = <String, double>{};
    for (final t in items.where((e) => e.type == 'expense')) {
      final key = t.category ?? 'Other';
      map[key] = (map[key] ?? 0) + t.amount;
    }
    return map;
  }
}
