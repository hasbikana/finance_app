import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/app_colors.dart';
import '../../models/monthly_report_model.dart';
import '../../services/report_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late Future<MonthlyReportModel> _reportFuture;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    _reportFuture = ReportService().getMonthlyReport(
      month: _selectedMonth,
      year: _selectedYear,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadReport();
    });

    await _reportFuture;
  }

  String _formatCurrency(int value) {
    return _currencyFormatter.format(value);
  }

  String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return months[month - 1];
  }

  Future<void> _printPdf(MonthlyReportModel report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return [
            pw.Text(
              'Laporan Keuangan Pribadi',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Periode: ${_monthName(_selectedMonth)} $_selectedYear',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                _summaryRow('Total Pemasukan', _formatCurrency(report.totalIncome)),
                _summaryRow('Total Pengeluaran', _formatCurrency(report.totalExpense)),
                _summaryRow('Saldo', _formatCurrency(report.balance)),
                _summaryRow('Jumlah Transaksi', '${report.transactionCount} transaksi'),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Daftar Transaksi',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [
                'Tanggal',
                'Kategori',
                'Jenis',
                'Nominal',
                'Keterangan',
              ],
              data: report.transactions.map((item) {
                return [
                  item.date,
                  item.categoryName,
                  item.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
                  _formatCurrency(item.amount),
                  item.description,
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue700,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(6),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  pw.TableRow _summaryRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(MonthlyTransactionItem item) {
    final isIncome = item.type == 'income';
    final color = isIncome ? AppColors.income : AppColors.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description.isEmpty ? item.categoryName : item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.categoryName} • ${item.date}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isIncome
                ? '+${_formatCurrency(item.amount)}'
                : '-${_formatCurrency(item.amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterSection() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedMonth,
            decoration: _filterDecoration('Bulan'),
            items: List.generate(12, (index) {
              final month = index + 1;

              return DropdownMenuItem(
                value: month,
                child: Text(_monthName(month)),
              );
            }),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedMonth = value;
                _loadReport();
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedYear,
            decoration: _filterDecoration('Tahun'),
            items: List.generate(7, (index) {
              final year = DateTime.now().year - 3 + index;

              return DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            }),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedYear = value;
                _loadReport();
              });
            },
          ),
        ),
      ],
    );
  }

  InputDecoration _filterDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Laporan',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<MonthlyReportModel>(
          future: _reportFuture,
          builder: (context, snapshot) {
            final report = snapshot.data;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || report == null) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(
                    Icons.warning_rounded,
                    color: AppColors.expense,
                    size: 56,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Gagal memuat laporan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF59E0B),
                        Color(0xFFD97706),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Laporan Bulanan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${_monthName(_selectedMonth)} $_selectedYear',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _filterSection(),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: 'Pemasukan',
                        value: _formatCurrency(report.totalIncome),
                        icon: Icons.trending_up_rounded,
                        color: AppColors.income,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        title: 'Pengeluaran',
                        value: _formatCurrency(report.totalExpense),
                        icon: Icons.trending_down_rounded,
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _summaryCard(
                  title: 'Saldo Bulan Ini',
                  value: _formatCurrency(report.balance),
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.primary,
                ),

                const SizedBox(height: 18),

                ElevatedButton.icon(
                  onPressed: () => _printPdf(report),
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Cetak PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Daftar Transaksi',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                if (report.transactions.isEmpty)
                  const Text(
                    'Belum ada transaksi pada periode ini.',
                    style: TextStyle(
                      color: AppColors.muted,
                    ),
                  )
                else
                  ...report.transactions.map(_transactionTile),
              ],
            );
          },
        ),
      ),
    );
  }
}