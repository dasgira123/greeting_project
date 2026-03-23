class ContactCategory {
  final String id;
  final String name;
  final bool isDefault;

  ContactCategory({
    required this.id,
    required this.name,
    this.isDefault = false,
  });
}
