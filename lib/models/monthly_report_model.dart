class MonthlyReportModel {
  final int totalIncome;
  final int totalExpense;
  final int balance;
  final int transactionCount;
  final List<MonthlyTransactionItem> transactions;

  MonthlyReportModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.transactions,
  });

  factory MonthlyReportModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    final transactionsRaw =
        data['transactions'] ?? data['items'] ?? data['data'] ?? [];

    return MonthlyReportModel(
      totalIncome: int.tryParse(
            (data['total_income'] ?? data['income'] ?? 0).toString(),
          ) ??
          0,
      totalExpense: int.tryParse(
            (data['total_expense'] ?? data['expense'] ?? 0).toString(),
          ) ??
          0,
      balance: int.tryParse(
            (data['balance'] ?? 0).toString(),
          ) ??
          0,
      transactionCount: int.tryParse(
            (data['transaction_count'] ?? transactionsRaw.length).toString(),
          ) ??
          0,
      transactions: transactionsRaw is List
          ? transactionsRaw
              .map(
                (item) => MonthlyTransactionItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
    );
  }
}

class MonthlyTransactionItem {
  final int id;
  final String date;
  final String type;
  final int amount;
  final String description;
  final String categoryName;

  MonthlyTransactionItem({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.description,
    required this.categoryName,
  });

  factory MonthlyTransactionItem.fromJson(Map<String, dynamic> json) {
    return MonthlyTransactionItem(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      date: (json['date'] ?? '').toString(),
      type: (json['type'] ?? 'expense').toString(),
      amount: int.tryParse((json['amount'] ?? 0).toString()) ?? 0,
      description: (json['description'] ?? '').toString(),
      categoryName:
          (json['category']?['name'] ?? json['category_name'] ?? 'Tanpa kategori')
              .toString(),
    );
  }
}