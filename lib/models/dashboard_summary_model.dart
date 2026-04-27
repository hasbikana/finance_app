class DashboardSummaryModel {
  final int totalIncome;
  final int totalExpense;
  final int balance;
  final int transactionCount;

  DashboardSummaryModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    final income = int.tryParse(
          (data['total_income'] ?? data['income'] ?? 0).toString(),
        ) ??
        0;

    final expense = int.tryParse(
          (data['total_expense'] ?? data['expense'] ?? 0).toString(),
        ) ??
        0;

    final balance = int.tryParse(
          (data['balance'] ?? data['saldo'] ?? income - expense).toString(),
        ) ??
        income - expense;

    final transactionCount = int.tryParse(
          (data['transaction_count'] ?? data['total_transactions'] ?? 0)
              .toString(),
        ) ??
        0;

    return DashboardSummaryModel(
      totalIncome: income,
      totalExpense: expense,
      balance: balance,
      transactionCount: transactionCount,
    );
  }

  factory DashboardSummaryModel.empty() {
    return DashboardSummaryModel(
      totalIncome: 0,
      totalExpense: 0,
      balance: 0,
      transactionCount: 0,
    );
  }
}