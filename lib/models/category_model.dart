class CategoryModel {
  final int id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? json['category_name'] ?? '').toString(),
    );
  }
}