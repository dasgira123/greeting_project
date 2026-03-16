class Template {
  final String id;
  final String text;
  final String category;
  final bool isSystem;
  final int usageCount;

  Template({
    required this.id,
    required this.text,
    required this.category,
    this.isSystem = false,
    this.usageCount = 0,
  });
}