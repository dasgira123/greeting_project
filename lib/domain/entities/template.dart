class Template {
  final String id;
  String text;
  String category;
  final bool isSystem;
  int usageCount;
  bool isFavorite;
  String? userId;

  Template({
    required this.id,
    required this.text,
    required this.category,
    this.isSystem = false,
    this.usageCount = 0,
    this.isFavorite = false,
    this.userId,
  });
}