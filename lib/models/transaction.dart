class FinanceTx {
  final String id;
  final String title;
  final double amount;
  final String type; // 'income' | 'expense'
  final String? category;
  final DateTime occurredAt;
  final String? notes;

  FinanceTx({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.category,
    required this.occurredAt,
    this.notes,
  });

  factory FinanceTx.fromMap(Map<String, dynamic> m) => FinanceTx(
    id: m['id'] as String,
    title: m['title'] as String,
    amount: double.parse(m['amount'].toString()),
    type: m['type'] as String,
    category: m['category'] as String?,
    occurredAt: DateTime.parse(m['occurred_at'] as String),
    notes: m['notes'] as String?,
  );

  Map<String, dynamic> toInsert() => {
    'title': title,
    'amount': amount,
    'type': type,
    'category': category,
    'occurred_at': occurredAt.toIso8601String(),
    'notes': notes,
  };
}
