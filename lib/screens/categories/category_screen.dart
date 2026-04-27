import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<CategoryModel>> _categoryFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    _categoryFuture = CategoryService().getCategories();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadCategories();
    });

    await _categoryFuture;
  }

      Future<void> _showCategoryForm({
        CategoryModel? category,
      }) async {
        final controller = TextEditingController(text: category?.name ?? '');
        final formKey = GlobalKey<FormState>();

        final result = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            bool isLoading = false;

            return StatefulBuilder(
              builder: (context, setModalState) {
                Future<void> saveCategory() async {
      if (!formKey.currentState!.validate()) return;

      setModalState(() => isLoading = true);

      try {
        if (category == null) {
          await CategoryService().createCategory(
            name: controller.text.trim(),
          );
        } else {
          await CategoryService().updateCategory(
            id: category.id,
            name: controller.text.trim(),
          );
        }

        if (!context.mounted) return;

        Navigator.pop(context, true);
        return;
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              category == null
                  ? 'Gagal menambahkan kategori.'
                  : 'Gagal mengubah kategori.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        setModalState(() => isLoading = false);
      }
    }

            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                    bottom: Radius.circular(32),
                  ),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.category_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              category == null
                                  ? 'Tambah Kategori'
                                  : 'Edit Kategori',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      TextFormField(
                        controller: controller,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Nama kategori',
                          hintText: 'Contoh: Makanan, Gaji, Transportasi',
                          prefixIcon: const Icon(
                            Icons.label_rounded,
                            color: AppColors.primary,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.4,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama kategori wajib diisi';
                          }

                          if (value.trim().length < 3) {
                            return 'Nama kategori minimal 3 karakter';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 22),

                      ElevatedButton(
                        onPressed: isLoading ? null : saveCategory,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withOpacity(0.5),
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                category == null
                                    ? 'Simpan Kategori'
                                    : 'Update Kategori',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
   

    if (result == true) {
      await _refresh();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            category == null
                ? 'Kategori berhasil ditambahkan.'
                : 'Kategori berhasil diperbarui.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Kategori'),
          content: Text(
            'Yakin ingin menghapus kategori "${category.name}"?',
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
      await CategoryService().deleteCategory(id: category.id);
      await _refresh();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori berhasil dihapus.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal menghapus kategori. Pastikan kategori tidak sedang dipakai transaksi.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 92,
              width: 92,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.category_outlined,
                color: AppColors.primary,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum Ada Kategori',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan kategori agar transaksi lebih mudah dikelompokkan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () => _showCategoryForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Kategori'),
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
        ),
      ),
    );
  }

  Widget _categoryTile(CategoryModel category, int index) {
    final colors = [
      AppColors.primary,
      const Color(0xFF7C3AED),
      const Color(0xFF0891B2),
      const Color(0xFFF59E0B),
      const Color(0xFF16A34A),
      const Color(0xFFDB2777),
    ];

    final color = colors[index % colors.length];

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
            Icons.label_rounded,
            color: color,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: const Text(
          'Kategori transaksi',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 12,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (value) {
            if (value == 'edit') {
              _showCategoryForm(category: category);
            }

            if (value == 'delete') {
              _deleteCategory(category);
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryForm(),
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
          'Kategori',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<CategoryModel>>(
          future: _categoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final categories = snapshot.data ?? [];

            if (categories.isEmpty) {
              return _emptyState();
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7C3AED),
                        Color(0xFF4F46E5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
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
                          Icons.category_rounded,
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
                              'Kelola Kategori',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${categories.length} kategori tersedia',
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

                ...List.generate(
                  categories.length,
                  (index) => _categoryTile(categories[index], index),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}