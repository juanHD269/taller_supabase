import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final FinanceTx tx;
  final VoidCallback? onDelete;
  const TransactionCard({super.key, required this.tx, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat.currency(symbol: '\$');
    final isIncome = tx.type == 'income';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(isIncome ? Icons.south_west : Icons.north_east),
        ),
        title: Text(tx.title),
        subtitle: Text(
          '${tx.category ?? '—'} • ${DateFormat.yMMMd().format(tx.occurredAt)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (isIncome ? '+' : '-') + nf.format(tx.amount),
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
