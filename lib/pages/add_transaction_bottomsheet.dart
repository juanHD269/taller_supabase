// lib/pages/add_transaction_bottomsheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class AddTransactionSheet extends StatefulWidget {
  final Future<void> Function(FinanceTx tx) onSubmit;
  const AddTransactionSheet({super.key, required this.onSubmit});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _category = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  String _type = 'expense';

  @override
  void dispose() {
    _title
      ..removeListener(() {})
      ..dispose();
    _amount.dispose();
    _category.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd();
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // drag handle
              Container(
                height: 4,
                width: 42,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.3),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add Transaction',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) =>
                    (v == null ||
                        double.tryParse(v.replaceAll(',', '.')) == null)
                    ? 'Invalid amount'
                    : null,
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                ],
                onChanged: (v) => setState(() => _type = v!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _category,
                decoration: const InputDecoration(
                  labelText: 'Category (optional)',
                ),
              ),
              const SizedBox(height: 10),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(df.format(_date)),
                trailing: const Icon(Icons.calendar_month_rounded),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: _date,
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),

              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    if (!_form.currentState!.validate()) return;
                    final amount = double.parse(
                      _amount.text.replaceAll(',', '.'),
                    );
                    final tx = FinanceTx(
                      id: 'temp',
                      title: _title.text.trim(),
                      amount: amount,
                      type: _type,
                      category: _category.text.trim().isEmpty
                          ? null
                          : _category.text.trim(),
                      occurredAt: _date,
                      notes: _notes.text.trim().isEmpty
                          ? null
                          : _notes.text.trim(),
                    );
                    await widget.onSubmit(tx);
                    if (mounted) Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
