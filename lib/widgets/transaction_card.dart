import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final FinanceTx tx;
  final VoidCallback? onDelete;
  const TransactionCard({super.key, required this.tx, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 'income';
    final amount =
        (isIncome ? '+' : '-') +
        NumberFormat.currency(symbol: '\$').format(tx.amount);

    return Card(
      child: InkWell(
        onLongPress: onDelete,
        child: Row(
          children: [
            // Colored stripe
            Container(
              width: 6,
              height: 70,
              decoration: BoxDecoration(
                color: isIncome ? Colors.green : Colors.red,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    isIncome
                        ? Icons.trending_down_rounded
                        : Icons.trending_up_rounded,
                  ),
                ),
                title: Text(
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${tx.category ?? '—'} • ${DateFormat.yMMMd().format(tx.occurredAt)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: TextStyle(
                        color: isIncome ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
