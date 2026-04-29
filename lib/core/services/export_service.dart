// lib/core/services/export_service.dart

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/transactions/domain/entities/transaction.dart';
import '../utils/app_logger.dart';
import '../utils/currency_formatter.dart';

/// Serviço de exportação de dados do app.
///
/// Suporta dois formatos:
/// - **CSV** — planilha compatível com Excel/Google Sheets, compartilhada via Share.
/// - **PDF** — relatório formatado com resumo e tabela, compartilhado via Printing.
///
/// Use [ExportService.instance] (singleton).
final class ExportService {
  ExportService._();

  static final ExportService instance = ExportService._();

  static final _dateFmt = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _filenameFmt = DateFormat('yyyyMMdd', 'pt_BR');

  // ── CSV ────────────────────────────────────────────────────────────────────

  /// Gera e compartilha um arquivo CSV com as [transactions] do período.
  Future<void> exportCsv({
    required List<Transaction> transactions,
    required DateTime start,
    required DateTime end,
  }) async {
    final rows = <List<dynamic>>[
      ['Data', 'Descrição', 'Tipo', 'Valor (R\$)', 'Status', 'Observações'],
      ...transactions.map(
        (t) => [
          _dateFmt.format(t.date),
          t.description,
          t.type.label,
          CurrencyFormatter.format(t.amount),
          t.status.label,
          t.notes ?? '',
        ],
      ),
    ];

    final csv = const ListToCsvConverter(fieldDelimiter: ';').convert(rows);

    final dir = await getTemporaryDirectory();
    final filename =
        'transacoes_${_filenameFmt.format(start)}_${_filenameFmt.format(end)}.csv';
    final file = File('${dir.path}/$filename');
    await file.writeAsString('\uFEFF$csv'); // BOM para Excel reconhecer UTF-8

    AppLogger.info('ExportService: CSV gerado em ${file.path}');

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv', name: filename)],
      subject: 'Transações exportadas — ${_dateFmt.format(start)} a ${_dateFmt.format(end)}',
    );
  }

  // ── PDF ────────────────────────────────────────────────────────────────────

  /// Gera e compartilha um PDF com relatório do período.
  Future<void> exportPdf({
    required List<Transaction> transactions,
    required DateTime start,
    required DateTime end,
  }) async {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpense;

    final doc = pw.Document(
      title: 'Relatório Financeiro',
      author: 'Controle Financeiro',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        header: (_) => _buildPdfHeader(start, end),
        footer: _buildPdfFooter,
        build: (ctx) => [
          _buildPdfSummary(totalIncome, totalExpense, balance),
          pw.SizedBox(height: 20),
          _buildPdfTable(transactions),
          if (transactions.isEmpty)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(24),
                child: pw.Text(
                  'Nenhuma transação no período selecionado.',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final bytes = await doc.save();
    final filename =
        'relatorio_${_filenameFmt.format(start)}_${_filenameFmt.format(end)}.pdf';

    AppLogger.info('ExportService: PDF gerado ($filename)');

    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  // ── PDF builders ──────────────────────────────────────────────────────────

  pw.Widget _buildPdfHeader(DateTime start, DateTime end) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Controle Financeiro',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Gerado em ${_dateFmt.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Período: ${_dateFmt.format(start)} a ${_dateFmt.format(end)}',
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
        pw.SizedBox(height: 4),
      ],
    );
  }

  pw.Widget _buildPdfFooter(pw.Context ctx) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Controle Financeiro',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummary(int income, int expense, int balance) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _pdfSummaryItem('Receitas', income, PdfColors.green800),
          _pdfSummaryItem('Despesas', expense, PdfColors.red800),
          _pdfSummaryItem(
            'Saldo',
            balance,
            balance >= 0 ? PdfColors.green800 : PdfColors.red800,
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSummaryItem(String label, int cents, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(
          CurrencyFormatter.format(cents),
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfTable(List<Transaction> transactions) {
    if (transactions.isEmpty) return pw.SizedBox();

    return pw.TableHelper.fromTextArray(
      headers: ['Data', 'Descrição', 'Tipo', 'Valor'],
      data: transactions
          .map(
            (t) => [
              _dateFmt.format(t.date),
              t.description.length > 45
                  ? '${t.description.substring(0, 42)}...'
                  : t.description,
              t.type.label,
              CurrencyFormatter.format(t.amount),
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF37474F)),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellHeight: 22,
      columnWidths: {
        0: const pw.FixedColumnWidth(72),
        1: const pw.FlexColumnWidth(),
        2: const pw.FixedColumnWidth(64),
        3: const pw.FixedColumnWidth(80),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }
}
