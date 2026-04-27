class TransactionModel {
  final int id;
  final int categoryId;
  final String type;
  final int amount;
  final String description;
  final String date;
  final String? categoryName;

  TransactionModel({
    required this.id,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.categoryName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      categoryId: int.tryParse(json['category_id'].toString()) ?? 0,
      type: (json['type'] ?? 'expense').toString(),
      amount: int.tryParse(json['amount'].toString()) ?? 0,
      description: (json['description'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      categoryName: json['category']?['name']?.toString(),
    );
  }
}