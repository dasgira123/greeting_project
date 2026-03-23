class CategoryDto {
  final String id;
  final String name;
  final int isDefault;

  CategoryDto({
    required this.id,
    required this.name,
    required this.isDefault,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_default': isDefault,
    };
  }

  factory CategoryDto.fromMap(Map<String, dynamic> map) {
    return CategoryDto(
      id: map['id'] as String,
      name: map['name'] as String,
      isDefault: map['is_default'] as int? ?? 0,
    );
  }
}
