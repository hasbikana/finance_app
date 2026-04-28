import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/widgets.dart';
import '../../models/dashboard_summary_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../auth/login_screen.dart';
import 'widgets/balance_card.dart';
import 'widgets/stats_grid.dart';
import 'widgets/action_grid.dart';
import '../categories/category_screen.dart';
import '../transactions/transaction_form_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../reports/report_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DashboardViewModel>().loadSummary());
  }

  Future<void> _refresh() async {
    await context.read<DashboardViewModel>().loadSummary();
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final summary = vm.summary ?? DashboardSummaryModel.empty();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
          ),
        ],
        leading: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          icon: const Icon(Icons.person_rounded),
          tooltip: 'Profil',
        ),
      ),
      body: AppPage(
        refresh: _refresh,
        children: [
          const SizedBox(height: 8),
          BalanceCard(
            balance: _currency.format(summary.balance),
            income: _currency.format(summary.totalIncome),
            expense: _currency.format(summary.totalExpense),
            isLoading: vm.isLoading,
          ),
          const SizedBox(height: 20),
          StatsGrid(
            summary: summary,
            isLoading: vm.isLoading,
            currency: _currency,
          ),
          const SizedBox(height: 24),
          Text(
            'Akses Cepat',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 14),
          ActionGrid(
            onAdd: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
              );
              if (res == true) _refresh();
            },
            onTransactions: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionListScreen()),
            ),
            onCategories: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoryScreen()),
            ),
            onReports: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportScreen()),
            ),
          ),
        ],
      ),
    );
  }
}