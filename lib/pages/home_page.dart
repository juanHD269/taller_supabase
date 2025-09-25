import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/supabase_service.dart';
import '../widgets/balance_card.dart';
import '../widgets/chart_widget.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_page.dart';
import '../utils/export.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final service = SupabaseService();
  DateTime currentMonth = DateTime.now();
  late Future<List<FinanceTx>> _future;

  @override
  void initState() {
    super.initState();
    _future = service.fetchByMonth(currentMonth);
  }

  Future<void> _reload() async {
    setState(() {
      _future = service.fetchByMonth(currentMonth);
    });
    await _future;
  }

  void _changeMonth(int delta) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + delta, 1);
      _future = service.fetchByMonth(currentMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat.yMMMM().format(currentMonth);
    return Scaffold(
      appBar: AppBar(
        title: Text('Balance • $monthLabel'),
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.file_download),
            onPressed: () async {
              final items = await _future;
              await ExportUtils.exportCsv(context, items);
            },
          ),
          IconButton(
            tooltip: 'Export PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final items = await _future;
              await ExportUtils.exportPdf(context, items, monthLabel);
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<List<FinanceTx>>(
        future: _future,
        builder: (c, snap) {
          if (!snap.hasData) {
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          final totals = service.totals(items);
          final balance = service.balance(items);

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                BalanceCard(
                  income: totals['income']!,
                  expense: totals['expense']!,
                  balance: balance,
                ),
                const SizedBox(height: 16),
                ChartWidget(items: items),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => _changeMonth(-1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => _changeMonth(1),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final t in items)
                  TransactionCard(
                    tx: t,
                    onDelete: () async {
                      await service.remove(t.id);
                      _reload();
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          );
          if (ok == true) _reload(); // refresca al volver del form
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
