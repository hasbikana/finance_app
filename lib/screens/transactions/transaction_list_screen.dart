import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late Future<List<TransactionModel>> _transactionFuture;

  final _searchController = TextEditingController();

  String _selectedType = 'all';

  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactionFuture = TransactionService().getTransactions(
      type: _selectedType,
      search: _searchController.text.trim(),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadTransactions();
    });

    await _transactionFuture;
  }

  Future<void> _openAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TransactionFormScreen(),
      ),
    );

    if (result == true) {
      await _refresh();
    }
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Transaksi'),
          content: Text(
            'Yakin ingin menghapus transaksi "${transaction.description}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expense,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await TransactionService().deleteTransaction(id: transaction.id);
      await _refresh();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil dihapus.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus transaksi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatCurrency(int value) {
    return _currencyFormatter.format(value);
  }

  Color _typeColor(String type) {
    return type == 'income' ? AppColors.income : AppColors.expense;
  }

  IconData _typeIcon(String type) {
    return type == 'income'
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
  }

  String _typeLabel(String type) {
    return type == 'income' ? 'Pemasukan' : 'Pengeluaran';
  }

  Widget _filterButton({
    required String label,
    required String value,
  }) {
    final isSelected = _selectedType == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = value;
            _loadTransactions();
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade200,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.muted,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 80),
        Container(
          height: 92,
          width: 92,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.primary,
            size: 42,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Belum Ada Transaksi',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tambahkan transaksi pertama agar catatan keuangan mulai terbentuk.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.muted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        ElevatedButton.icon(
          onPressed: _openAddTransaction,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah Transaksi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _transactionTile(TransactionModel transaction) {
    final color = _typeColor(transaction.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(
            _typeIcon(transaction.type),
            color: color,
          ),
        ),
        title: Text(
          transaction.description.isEmpty
              ? _typeLabel(transaction.type)
              : transaction.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${transaction.categoryName ?? 'Tanpa kategori'} • ${transaction.date}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              transaction.type == 'income'
                  ? '+${_formatCurrency(transaction.amount)}'
                  : '-${_formatCurrency(transaction.amount)}',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteTransaction(transaction);
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_rounded,
                          size: 18,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text('Hapus'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTransaction,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Transaksi',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _refresh(),
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _refresh();
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _filterButton(label: 'Semua', value: 'all'),
                    const SizedBox(width: 10),
                    _filterButton(label: 'Masuk', value: 'income'),
                    const SizedBox(width: 10),
                    _filterButton(label: 'Keluar', value: 'expense'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<TransactionModel>>(
                future: _transactionFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final transactions = snapshot.data ?? [];

                  if (transactions.isEmpty) {
                    return _emptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return _transactionTile(transactions[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}