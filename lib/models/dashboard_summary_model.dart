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
    return DashboardSummaryModel(
      totalIncome: int.tryParse(data['total_income']?.toString() ?? '0') ?? 0,
      totalExpense: int.tryParse(data['total_expense']?.toString() ?? '0') ?? 0,
      balance: int.tryParse(data['balance']?.toString() ?? '0') ?? 0,
      transactionCount: int.tryParse(data['transaction_count']?.toString() ?? '0') ?? 0,
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