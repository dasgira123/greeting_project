class TemplateDto {
  final String id;
  final String text;
  final String category;
  final int isSystem;
  final int usageCount;
  final int isFavorite;

  TemplateDto({
    required this.id,
    required this.text,
    required this.category,
    this.isSystem = 0,
    this.usageCount = 0,
    this.isFavorite = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'is_system': isSystem,
      'usage_count': usageCount,
      'is_favorite': isFavorite,
    };
  }

  factory TemplateDto.fromMap(Map<String, dynamic> map) {
    return TemplateDto(
      id: map['id'] as String,
      text: map['text'] as String,
      category: map['category'] as String,
      isSystem: map['is_system'] as int,
      usageCount: map['usage_count'] as int,
      isFavorite: (map['is_favorite'] ?? 0) as int,
    );
  }
}
