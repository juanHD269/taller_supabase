import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../services/supabase_service.dart';
import '../widgets/transaction_card.dart';
import '../widgets/chart_widget.dart';
import '../utils/export.dart';
import '../theme/theme_controller.dart';
import '../theme/app_theme.dart';
import 'add_transaction_bottomsheet.dart';

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

  Future<bool?> _openAddSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) =>
          AddTransactionSheet(onSubmit: (tx) async => service.insert(tx)),
    );
  }

  Future<bool> _confirmDelete(BuildContext ctx) async {
    final res = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat.yMMMM().format(currentMonth);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _reload,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text('Balance • $monthLabel'),
              actions: [
                IconButton(
                  tooltip: 'Theme',
                  onPressed: () => context.read<ThemeController>().toggle(),
                  icon: const Icon(Icons.brightness_6_rounded),
                ),
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
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GradientHeader(balanceFuture: _future, service: service),
                    const SizedBox(height: Spacing.md),
                    _MonthSelector(
                      onPrev: () => _changeMonth(-1),
                      onNext: () => _changeMonth(1),
                    ),
                    const SizedBox(height: Spacing.md),
                    FutureBuilder<List<FinanceTx>>(
                      future: _future,
                      builder: (c, snap) {
                        if (!snap.hasData) {
                          if (snap.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('Error: ${snap.error}'),
                            );
                          }
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final items = snap.data!;
                        if (items.isEmpty) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  const Icon(Icons.inbox_outlined, size: 40),
                                  const SizedBox(height: 12),
                                  const Text('No transactions yet'),
                                  const SizedBox(height: 8),
                                  FilledButton.icon(
                                    onPressed: () async {
                                      final ok = await _openAddSheet(context);
                                      if (ok == true) _reload();
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add first transaction'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            ChartWidget(items: items),
                            const SizedBox(height: Spacing.md),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Transactions',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 6),
                            for (final t in items)
                              Dismissible(
                                key: ValueKey(t.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                ),
                                confirmDismiss: (_) async =>
                                    await _confirmDelete(context),
                                onDismissed: (_) async {
                                  await service.remove(t.id);
                                  _reload();
                                },
                                child: TransactionCard(
                                  tx: t,
                                  onDelete: () async {
                                    final confirm = await _confirmDelete(
                                      context,
                                    );
                                    if (confirm) {
                                      await service.remove(t.id);
                                      _reload();
                                    }
                                  },
                                ),
                              ),
                            const SizedBox(height: 100),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _AddFab(
        onTap: () async {
          final ok = await _openAddSheet(context);
          if (ok == true) _reload();
        },
      ),
    );
  }
}

class _GradientHeader extends StatelessWidget {
  final Future<List<FinanceTx>> balanceFuture;
  final SupabaseService service;
  const _GradientHeader({required this.balanceFuture, required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FinanceTx>>(
      future: balanceFuture,
      builder: (c, snap) {
        double income = 0, expense = 0, balance = 0;
        if (snap.hasData) {
          final totals = service.totals(snap.data!);
          income = totals['income']!;
          expense = totals['expense']!;
          balance = service.balance(snap.data!);
        }
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(Spacing.lg),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white.withOpacity(.95),
                size: 36,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        NumberFormat.currency(symbol: '\$').format(balance),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                      Row(
                        children: [
                          _pill(
                            Icons.south_west_rounded,
                            'Income',
                            income,
                            Colors.white,
                          ),
                          const SizedBox(width: 14),
                          _pill(
                            Icons.north_east_rounded,
                            'Expense',
                            expense,
                            Colors.white70,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pill(IconData icon, String label, double value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          '$label · ${NumberFormat.compactCurrency(symbol: '\$').format(value)}',
          style: TextStyle(color: color),
        ),
      ],
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _MonthSelector({required this.onPrev, required this.onNext});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilterChip(
          label: const Text('Prev'),
          onSelected: (_) => onPrev(),
          avatar: const Icon(Icons.chevron_left),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Next'),
          onSelected: (_) => onNext(),
          avatar: const Icon(Icons.chevron_right),
        ),
        const Spacer(),
        const Icon(Icons.filter_list_rounded),
        const SizedBox(width: 4),
        const Text('Filters'),
      ],
    );
  }
}

class _AddFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AddFab({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
