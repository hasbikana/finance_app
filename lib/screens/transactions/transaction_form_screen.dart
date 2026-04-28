import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/widgets.dart';
import '../../models/category_model.dart';
import '../../viewmodels/transactions_viewmodel.dart';
import '../../viewmodels/categories_viewmodel.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _viewFormat = DateFormat('dd MMM yyyy');
  String _type = 'expense';
  CategoryModel? _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Ambil kategori pertama setelah build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catVM = context.read<CategoriesViewModel>();
      if (catVM.categories.isNotEmpty && _category == null) {
        setState(() => _category = catVM.categories.first);
      }
    });
  }

  int _parseAmount(String v) => int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kategori terlebih dahulu')));
      return;
    }
    final amount = _parseAmount(_amountCtrl.text);
    if (amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal tidak valid')));
      return;
    }
    setState(() => _saving = true);
    final vm = context.read<TransactionsViewModel>();
    final ok = await vm.createTransaction(
      categoryId: _category!.id,
      type: _type,
      amount: amount,
      description: _descCtrl.text.trim(),
      date: _dateFormat.format(_date),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(vm.error ?? 'Gagal menyimpan'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catVM = context.watch<CategoriesViewModel>();
    final isIncome = _type == 'income';
    return AppScaffold(
      title: 'Tambah Transaksi',
      body: AppPage(
        children: [
          HeroBanner(
            title: isIncome ? 'Pemasukan' : 'Pengeluaran',
            subtitle: 'Catat transaksi baru',
            icon: isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            gradient: LinearGradient(
              colors: isIncome ? [Colors.green, Colors.green.shade800] : [Theme.of(context).colorScheme.primary, Colors.blue.shade900],
            ),
          ),
          const SizedBox(height: 18),
          SegmentedPicker<String>(
            value: _type,
            onChanged: (v) => setState(() => _type = v),
            items: const [
              AppChoiceChip(label: 'Pengeluaran', value: 'expense', icon: Icons.arrow_upward_rounded, color: Colors.red),
              AppChoiceChip(label: 'Pemasukan', value: 'income', icon: Icons.arrow_downward_rounded, color: Colors.green),
            ],
          ),
          const SizedBox(height: 18),
          Form(
            key: _formKey,
            child: AppCard(
              child: Column(
                children: [
                  DropdownButtonFormField<CategoryModel>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category_rounded),
                      filled: true,
                    ),
                    items: catVM.categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _category = v),
                    validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
                  ),
                  const SizedBox(height: 14),
                  TInputField(
                    controller: _amountCtrl,
                    hintText: 'Nominal',
                    icon: Icons.payments_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) => _parseAmount(v ?? '') <= 0 ? 'Nominal tidak valid' : null,
                  ),
                  const SizedBox(height: 14),
                  TInputField(
                    controller: _descCtrl,
                    hintText: 'Keterangan',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                    validator: (v) => v!.trim().isEmpty ? 'Keterangan wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        prefixIcon: Icon(Icons.calendar_today_rounded),
                        filled: true,
                      ),
                      child: Text(_viewFormat.format(_date)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(label: 'Simpan Transaksi', isLoading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}