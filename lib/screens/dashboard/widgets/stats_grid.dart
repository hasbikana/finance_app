import 'package:flutter/material.dart';
import '../../../core/widgets.dart';
import '../../../models/dashboard_summary_model.dart';
import 'package:intl/intl.dart';

class StatsGrid extends StatelessWidget {
  final DashboardSummaryModel summary;
  final bool isLoading;
  final NumberFormat currency;

  const StatsGrid({
    super.key,
    required this.summary,
    required this.isLoading,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Pemasukan',
                value: currency.format(summary.totalIncome),
                icon: Icons.trending_up_rounded,
                color: Colors.green,
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                title: 'Pengeluaran',
                value: currency.format(summary.totalExpense),
                icon: Icons.trending_down_rounded,
                color: Colors.red,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _StatCard(
          title: 'Transaksi',
          value: '${summary.transactionCount} transaksi',
          icon: Icons.receipt_long_rounded,
          color: Theme.of(context).colorScheme.primary,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          IconBox(icon: icon, color: color, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                isLoading
                    ? const LoadingBar(width: 100)
                    : Text(value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}