import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatelessWidget {
  final double income, expense, balance;
  const BalanceCard({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat.currency(symbol: '\$');
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _pill(
              'Income',
              nf.format(income),
              Icons.arrow_downward,
              Colors.green,
            ),
            _pill(
              'Expense',
              nf.format(expense),
              Icons.arrow_upward,
              Colors.red,
            ),
            _pill(
              'Balance',
              nf.format(balance),
              Icons.account_balance_wallet,
              Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value),
      ],
    );
  }
}
