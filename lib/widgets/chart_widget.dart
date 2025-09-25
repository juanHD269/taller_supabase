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
    final sum = totals.values.fold<double>(0, (a, b) => a + b);
    totals.entries.toList().asMap().forEach((i, e) {
      sections.add(
        PieChartSectionData(
          value: e.value,
          title: '${(e.value / sum * 100).toStringAsFixed(0)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expenses by Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(sections: sections, sectionsSpace: 2),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: totals.entries.map((e) {
                final pct = (e.value / sum * 100);
                return Chip(
                  label: Text('${e.key} • ${pct.toStringAsFixed(0)}%'),
                  avatar: const Icon(Icons.circle, size: 12),
                );
              }).toList(),
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
