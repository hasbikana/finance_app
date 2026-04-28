import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/widgets.dart';
import '../../viewmodels/transactions_viewmodel.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _searchCtrl = TextEditingController();
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TransactionsViewModel>().loadTransactions());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Fungsi pembersih universal (jika ada data mentah dari API)
  String _clean(String raw) => raw.replaceAll(RegExp(r'\s*\(?id[:\s]*\d+\)?\s*', caseSensitive: false), '').trim();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionsViewModel>();
    return AppScaffold(
      title: 'Transaksi',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionFormScreen()));
          if (res == true) {
            if (!mounted) return;
            vm.loadTransactions();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              vm.setSearch('');
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (v) => vm.setSearch(v),
                ),
                const SizedBox(height: 14),
                SegmentedPicker<String>(
                  value: vm.filterType,
                  onChanged: vm.setFilter,
                  items: const [
                    AppChoiceChip(label: 'Semua', value: 'all'),
                    AppChoiceChip(label: 'Masuk', value: 'income', color: Colors.green),
                    AppChoiceChip(label: 'Keluar', value: 'expense', color: Colors.red),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.transactions.isEmpty
                    ? EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Belum Ada Transaksi',
                        message: 'Tambahkan transaksi pertama Anda.',
                        actionLabel: 'Tambah Transaksi',
                        onAction: () async {
                          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionFormScreen()));
                          if (res == true) {
                            if (!mounted) return;
                            vm.loadTransactions();
                          }
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: vm.loadTransactions,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: vm.transactions.length,
                          itemBuilder: (context, index) {
                            final item = vm.transactions[index];
                            final isIncome = item.type == 'income';
                            final color = isIncome ? Colors.green : Colors.red;
                            final theme = Theme.of(context);

                            // ═══════ TAMPILAN SATU TRANSAKSI (TANPA ID, created_at, updated_at) ═══════
                            return AppCard(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: EdgeInsets.zero,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                leading: IconBox(
                                  icon: isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                  color: color,
                                ),
                                title: Text(
                                  _clean(item.description.isEmpty ? (isIncome ? 'Pemasukan' : 'Pengeluaran') : item.description),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text(
                                  _clean('${item.categoryName ?? 'Tanpa kategori'} • ${item.date}'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${isIncome ? '+' : '-'} ${_currency.format(item.amount)}',
                                      style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (_) => _deleteItem(item.id),  // id hanya untuk hapus
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(children: [
                                            Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                                            SizedBox(width: 10),
                                            Text('Hapus'),
                                          ]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) {
      final vm = context.read<TransactionsViewModel>();
      final success = await vm.deleteTransaction(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Berhasil dihapus' : 'Gagal menghapus'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}