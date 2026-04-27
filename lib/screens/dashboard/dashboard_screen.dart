import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../models/dashboard_summary_model.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../auth/login_screen.dart';
import '../transactions/transaction_form_screen.dart';
import '../categories/category_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../reports/report_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardSummaryModel> _summaryFuture;

  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _summaryFuture = DashboardService().getSummary();
  }

  Future<void> _refresh() async {
    setState(() {
      _summaryFuture = DashboardService().getSummary();
    });

    await _summaryFuture;
  }

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  String _formatCurrency(int value) {
    return _currencyFormatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<DashboardSummaryModel>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final summary = snapshot.data ?? DashboardSummaryModel.empty();

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  _HeaderSection(
                  onLogout: _logout,
                  onProfileTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                  const SizedBox(height: 24),

                  _BalanceCard(
                    balance: _formatCurrency(summary.balance),
                    income: _formatCurrency(summary.totalIncome),
                    expense: _formatCurrency(summary.totalExpense),
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _MiniStatCard(
                          title: 'Pemasukan',
                          value: _formatCurrency(summary.totalIncome),
                          icon: Icons.trending_up_rounded,
                          iconColor: AppColors.income,
                          isLoading: isLoading,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _MiniStatCard(
                          title: 'Pengeluaran',
                          value: _formatCurrency(summary.totalExpense),
                          icon: Icons.trending_down_rounded,
                          iconColor: AppColors.expense,
                          isLoading: isLoading,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _MiniStatCard(
                    title: 'Jumlah Transaksi',
                    value: '${summary.transactionCount} transaksi',
                    icon: Icons.receipt_long_rounded,
                    iconColor: AppColors.primary,
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: 24),

                  _QuickActionSection(
                    onRefresh: _refresh,
                  ),

                  const SizedBox(height: 24),

                  _InfoCard(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

  class _HeaderSection extends StatelessWidget {
    const _HeaderSection({
      required this.onLogout,
      required this.onProfileTap,
    });

    final VoidCallback onLogout;
    final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catatan Keuangan',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Pantau keuangan pribadi Anda',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onLogout,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
    required this.isLoading,
  });

  final String balance;
  final String income;
  final String expense;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1E40AF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.savings_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Saldo Saat Ini',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          isLoading
              ? _LoadingBar(
                  width: 190,
                  color: Colors.white.withOpacity(0.45),
                )
              : Text(
                  balance,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _BalanceItem(
                  label: 'Masuk',
                  value: income,
                  icon: Icons.arrow_downward_rounded,
                  isLoading: isLoading,
                ),
              ),
              Container(
                width: 1,
                height: 42,
                color: Colors.white.withOpacity(0.22),
              ),
              Expanded(
                child: _BalanceItem(
                  label: 'Keluar',
                  value: expense,
                  icon: Icons.arrow_upward_rounded,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  const _BalanceItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                isLoading
                    ? _LoadingBar(
                        width: 80,
                        color: Colors.white.withOpacity(0.45),
                      )
                    : Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.isLoading,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
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
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
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
                isLoading
                    ? const _LoadingBar(width: 100)
                    : Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionSection extends StatelessWidget {
  const _QuickActionSection({
    required this.onRefresh,
  });

  final Future<void> Function() onRefresh;

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan dibuat pada tahap berikutnya.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _openTransactionForm(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TransactionFormScreen(),
      ),
    );

    if (result == true) {
      await onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Akses Cepat',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.9,
          children: [
            _QuickActionButton(
              title: 'Tambah',
              subtitle: 'Transaksi',
              icon: Icons.add_card_rounded,
              color: AppColors.primary,
              onTap: () => _openTransactionForm(context),
            ),
            _QuickActionButton(
            title: 'Transaksi',
            subtitle: 'Riwayat',
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF0891B2),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransactionListScreen(),
                ),
              );
            },
          ),
            _QuickActionButton(
              title: 'Kategori',
              subtitle: 'Kelola',
              icon: Icons.category_rounded,
              color: const Color(0xFF7C3AED),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoryScreen(),
                  ),
                );
              },
            ),
            _QuickActionButton(
            title: 'Laporan',
            subtitle: 'Bulanan',
            icon: Icons.bar_chart_rounded,
            color: const Color(0xFFF59E0B),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportScreen(),
                ),
              );
            },
          ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Catat transaksi secara rutin agar saldo dan laporan bulanan lebih akurat.',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({
    required this.width,
    this.color,
  });

  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      width: width,
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}