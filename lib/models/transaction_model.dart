import 'dart:convert';  // <-- tambahkan impor

class TransactionModel {
  final int id;
  final int amount;
  final String type;
  final String description;
  final String date;
  final String? categoryName;
  final int? categoryId;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.categoryName,
    this.categoryId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      amount: int.tryParse(json['amount'].toString()) ?? 0,
      type: json['type']?.toString() ?? 'expense',
      description: _cleanString(json['description']?.toString() ?? ''),
      date: json['date']?.toString() ?? '',
      categoryName: _parseCategoryName(json['category'] ?? json['category_name']),
      categoryId: json['category_id'] != null ? int.tryParse(json['category_id'].toString()) : null,
    );
  }

  static String _cleanString(String raw) {
    return raw
        .replaceAll(RegExp(r'\s*\(?\b(?:id|created_at|updated_at)\b:?\s*\S*\)?', caseSensitive: false), '')
        .trim();
  }

  static String? _parseCategoryName(dynamic value) {
    if (value == null) return null;

    if (value is Map) {
      final name = (value['name'] ?? value['category_name'])?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }

    if (value is String) {
      // Coba decode JSON
      try {
        final decoded = jsonDecode(value);   // <-- fungsi jsonDecode
        if (decoded is Map) {
          final name = (decoded['name'] ?? decoded['category_name'])?.toString().trim();
          if (name != null && name.isNotEmpty) return name;
        }
      } catch (_) {}

      // Kalau bukan JSON, bersihkan string mentah
      String cleaned = value
          .replaceAll(RegExp(r'\{|\}'), '')
          .replaceAll(RegExp(r'name\s*:\s*'), '')
          .replaceAll(RegExp(r'user_id\s*:\s*\d+'), '')
          .replaceAll(RegExp(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z'), '')
          .replaceAll(RegExp(r'[,\-:]'), ' ')
          .trim();

      if (cleaned.isNotEmpty) return cleaned;
    }

    return null;
  }
}