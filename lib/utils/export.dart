import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction.dart';

class ExportUtils {
  static Future<void> exportCsv(
    BuildContext context,
    List<FinanceTx> items,
  ) async {
    final rows = <List<dynamic>>[
      ['id', 'title', 'amount', 'type', 'category', 'occurred_at', 'notes'],
      ...items.map(
        (t) => [
          t.id,
          t.title,
          t.amount,
          t.type,
          t.category ?? '',
          t.occurredAt.toIso8601String(),
          t.notes ?? '',
        ],
      ),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/transactions.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Transactions CSV');
  }

  static Future<void> exportPdf(
    BuildContext context,
    List<FinanceTx> items,
    String title,
  ) async {
    final pdf = pw.Document();
    final nf = NumberFormat.currency(symbol: '\$');

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Header(level: 0, child: pw.Text('Transactions • $title')),
          pw.Table.fromTextArray(
            headers: ['Title', 'Amount', 'Type', 'Category', 'Date'],
            data: items
                .map(
                  (t) => [
                    t.title,
                    nf.format(t.amount),
                    t.type,
                    t.category ?? '—',
                    DateFormat.yMMMd().format(t.occurredAt),
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
