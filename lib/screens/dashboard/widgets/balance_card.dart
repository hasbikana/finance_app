import 'package:flutter/material.dart';
import '../../../core/widgets.dart';

class BalanceCard extends StatelessWidget {
  final String balance;
  final String income;
  final String expense;
  final bool isLoading;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings_rounded, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Saldo Saat Ini',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 18),
          isLoading
              ? const LoadingBar(width: 190, color: Colors.white54)
              : Text(balance,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6)),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _BalanceItem(label: 'Masuk', value: income, icon: Icons.arrow_downward_rounded, isLoading: isLoading)),
              Expanded(child: _BalanceItem(label: 'Keluar', value: expense, icon: Icons.arrow_upward_rounded, isLoading: isLoading)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isLoading;

  const _BalanceItem({required this.label, required this.value, required this.icon, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              isLoading
                  ? const LoadingBar(width: 80, color: Colors.white54)
                  : Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }
}