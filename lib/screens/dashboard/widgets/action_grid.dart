import 'package:flutter/material.dart';
import '../../../core/widgets.dart';

class ActionGrid extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onTransactions;
  final VoidCallback onCategories;
  final VoidCallback onReports;

  const ActionGrid({
    super.key,
    required this.onAdd,
    required this.onTransactions,
    required this.onCategories,
    required this.onReports,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData('Tambah', 'Transaksi', Icons.add_card_rounded, Theme.of(context).colorScheme.primary, onAdd),
      _ActionData('Transaksi', 'Riwayat', Icons.receipt_long_rounded, Colors.cyan, onTransactions),
      _ActionData('Kategori', 'Kelola', Icons.category_rounded, Colors.purple, onCategories),
      _ActionData('Laporan', 'Bulanan', Icons.bar_chart_rounded, Colors.amber, onReports),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final a = actions[index];
        return AppCard(
          onTap: a.onTap,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconBox(icon: a.icon, color: a.color, size: 48, iconSize: 26),
              const SizedBox(height: 10),
              Text(a.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
              Text(a.subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        );
      },
    );
  }
}

class _ActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionData(this.title, this.subtitle, this.icon, this.color, this.onTap);
}