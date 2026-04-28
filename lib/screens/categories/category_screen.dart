import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets.dart';
import '../../models/category_model.dart';
import '../../viewmodels/categories_viewmodel.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CategoriesViewModel>().loadCategories());
  }

  Future<void> _showForm({CategoryModel? category}) async {
    if (category != null) _nameCtrl.text = category.name;
    final isEdit = category != null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 22),
                Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 22),
                TInputField(
                  controller: _nameCtrl,
                  hintText: 'Nama Kategori',
                  icon: Icons.label_rounded,
                  validator: (v) => v!.trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: isEdit ? 'Update' : 'Simpan',
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final vm = context.read<CategoriesViewModel>();
                    bool ok;
                    if (isEdit) {
                      ok = await vm.updateCategory(category.id, _nameCtrl.text.trim());
                    } else {
                      ok = await vm.createCategory(_nameCtrl.text.trim());
                    }
                    if (!mounted) return; // tambahkan mounted check
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? 'Berhasil' : 'Gagal'), backgroundColor: ok ? Colors.green : Colors.red),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    ).then((_) => _nameCtrl.clear());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoriesViewModel>();
    return AppScaffold(
      title: 'Kategori',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.categories.isEmpty
              ? EmptyState(
                  icon: Icons.category_outlined,
                  title: 'Belum Ada Kategori',
                  message: 'Tambahkan kategori untuk mengelompokkan transaksi.',
                  actionLabel: 'Tambah Kategori',
                  onAction: () => _showForm(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  itemCount: vm.categories.length,
                  itemBuilder: (context, index) {
                    final cat = vm.categories[index];
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: IconBox(icon: Icons.label_rounded, color: Colors.primaries[index % Colors.primaries.length]),
                        title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: const Text('Kategori transaksi'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') _showForm(category: cat);
                            if (v == 'delete') _delete(cat);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 10), Text('Edit')])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 10), Text('Hapus')])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _delete(CategoryModel cat) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus ${cat.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) {
      final vm = context.read<CategoriesViewModel>();
      final success = await vm.deleteCategory(cat.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Berhasil dihapus' : 'Gagal menghapus'), backgroundColor: success ? Colors.green : Colors.red),
      );
    }
  }
}