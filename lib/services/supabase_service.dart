import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';

final _sb = Supabase.instance.client;

class SupabaseService {
  Future<List<FinanceTx>> fetchByMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final res = await _sb
        .from('transactions')
        .select()
        .gte('occurred_at', start.toIso8601String())
        .lt('occurred_at', end.toIso8601String())
        .order('occurred_at', ascending: false);

    return (res as List)
        .map((e) => FinanceTx.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> insert(FinanceTx tx) async {
    await _sb.from('transactions').insert(tx.toInsert());
  }

  Future<void> remove(String id) async {
    await _sb.from('transactions').delete().eq('id', id);
  }

  double balance(Iterable<FinanceTx> items) {
    double inc = 0, exp = 0;
    for (final t in items) {
      if (t.type == 'income')
        inc += t.amount;
      else
        exp += t.amount;
    }
    return inc - exp;
  }

  Map<String, double> totals(Iterable<FinanceTx> items) {
    double inc = 0, exp = 0;
    for (final t in items) {
      if (t.type == 'income')
        inc += t.amount;
      else
        exp += t.amount;
    }
    return {'income': inc, 'expense': exp};
  }
}
