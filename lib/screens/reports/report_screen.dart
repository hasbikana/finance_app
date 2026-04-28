import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/widgets.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../models/monthly_report_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Pastikan ViewModel memuat data setelah widget terpasang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportViewModel>().loadReport();
    });
  }

  Future<void> _printPdf() async {
    final vm = context.read<ReportViewModel>();
    final report = vm.report;
    if (report == null) return;

    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => [
        pw.Text('Laporan Keuangan', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text('Periode: ${_monthName(vm.month)} ${vm.year}', style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 20),
        pw.Table(border: pw.TableBorder.all(color: PdfColors.grey300), children: [
          _summaryRow('Total Pemasukan', _currency.format(report.totalIncome)),
          _summaryRow('Total Pengeluaran', _currency.format(report.totalExpense)),
          _summaryRow('Saldo', _currency.format(report.balance)),
          _summaryRow('Jumlah Transaksi', '${report.transactionCount} transaksi'),
        ]),
        pw.SizedBox(height: 24),
        pw.Text('Daftar Transaksi', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Tanggal', 'Kategori', 'Jenis', 'Nominal', 'Keterangan'],
          data: report.transactions.map((item) => [
            item.date,
            item.categoryName,
            item.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
            _currency.format(item.amount),
            item.description,
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(6),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  String _monthName(int m) {
    const months = ['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
    return months[m - 1];
  }

  pw.TableRow _summaryRow(String label, String value) {
    return pw.TableRow(children: [
      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(label)),
      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportViewModel>();
    final report = vm.report;
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Laporan',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: vm.month,
                  decoration: const InputDecoration(labelText: 'Bulan', filled: true),
                  items: List.generate(12, (i) => i + 1)
                      .map((m) => DropdownMenuItem(value: m, child: Text(_monthName(m))))
                      .toList(),
                  onChanged: (v) => vm.setMonth(v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: vm.year,
                  decoration: const InputDecoration(labelText: 'Tahun', filled: true),
                  items: List.generate(5, (i) => DateTime.now().year - i)
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (v) => vm.setYear(v!),
                ),
              ),
            ]),
          ),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : report == null
                    ? const Center(child: Text('Gagal memuat laporan'))
                    : RefreshIndicator(
                        onRefresh: vm.loadReport,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            HeroBanner(
                              title: 'Laporan Bulanan',
                              subtitle: '${_monthName(vm.month)} ${vm.year}',
                              icon: Icons.bar_chart_rounded,
                              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFD9706)]),
                            ),
                            const SizedBox(height: 18),
                            Row(children: [
                              Expanded(child: _summaryCard('Pemasukan', _currency.format(report.totalIncome), Icons.trending_up_rounded, Colors.green)),
                              const SizedBox(width: 12),
                              Expanded(child: _summaryCard('Pengeluaran', _currency.format(report.totalExpense), Icons.trending_down_rounded, Colors.red)),
                            ]),
                            const SizedBox(height: 12),
                            _summaryCard('Saldo Bulan Ini', _currency.format(report.balance), Icons.account_balance_wallet_rounded, theme.colorScheme.primary),
                            const SizedBox(height: 18),
                            PrimaryButton(label: 'Cetak PDF', onPressed: _printPdf),
                            const SizedBox(height: 18),
                            ...report.transactions.map((item) => _transactionTile(item, theme)),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      child: Row(children: [
        IconBox(icon: icon, color: color, size: 44),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
          ]),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════
  // TAMPILAN SATU TRANSAKSI (BERSIH – TANPA ID, created_at, updated_at)
  Widget _transactionTile(MonthlyTransactionItem item, ThemeData theme) {
    final isIncome = item.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;

    // Fungsi pembersih: hapus teks seperti " (id:12)" jika ada dari API
    String clean(String raw) => raw.replaceAll(RegExp(r'\s*\(?id[:\s]*\d+\)?\s*', caseSensitive: false), '').trim();

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        IconBox(icon: isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              clean(item.description.isEmpty ? (isIncome ? 'Pemasukan' : 'Pengeluaran') : item.description),
              style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              clean('${item.categoryName} • ${item.date}'),
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
          ]),
        ),
        Text(
          '${isIncome ? '+' : '-'} ${_currency.format(item.amount)}',
          style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 14),
        ),
      ]),
    );
  }
}