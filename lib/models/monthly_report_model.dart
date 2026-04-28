import 'dart:convert';

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
    final transactionsRaw = data['transactions'] ?? data['items'] ?? data['data'] ?? [];
    return MonthlyReportModel(
      totalIncome: int.tryParse(data['total_income']?.toString() ?? '0') ?? 0,
      totalExpense: int.tryParse(data['total_expense']?.toString() ?? '0') ?? 0,
      balance: int.tryParse(data['balance']?.toString() ?? '0') ?? 0,
      transactionCount: int.tryParse(data['transaction_count']?.toString() ?? '0') ?? 0,
      transactions: transactionsRaw is List
          ? transactionsRaw
              .map((item) => MonthlyTransactionItem.fromJson(Map<String, dynamic>.from(item)))
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
      id: int.tryParse(json['id'].toString()) ?? 0,
      date: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? 'expense',
      amount: int.tryParse(json['amount'].toString()) ?? 0,
      description: _cleanString(json['description']?.toString() ?? ''),
      categoryName: _parseCategoryName(
        json['category'] ?? json['category_name'],
      ),
    );
  }

  static String _cleanString(String raw) {
    return raw
        .replaceAll(RegExp(r'\s*\(?\b(?:id|created_at|updated_at)\b:?\s*\S*\)?', caseSensitive: false), '')
        .trim();
  }

  static String _parseCategoryName(dynamic value) {
    if (value == null) return 'Tanpa kategori';

    if (value is Map) {
      final name = (value['name'] ?? value['category_name'])?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }

    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          final name = (decoded['name'] ?? decoded['category_name'])?.toString().trim();
          if (name != null && name.isNotEmpty) return name;
        }
      } catch (_) {}

      String cleaned = value
          .replaceAll(RegExp(r'\{|\}'), '')
          .replaceAll(RegExp(r'name\s*:\s*'), '')
          .replaceAll(RegExp(r'user_id\s*:\s*\d+'), '')
          .replaceAll(RegExp(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z'), '')
          .replaceAll(RegExp(r'[,\-:]'), ' ')
          .trim();

      if (cleaned.isNotEmpty) return cleaned;
    }

    return 'Tanpa kategori';
  }
}