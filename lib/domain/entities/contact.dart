class Contact {
  final String id;
  final String name;
  final String? phone; 
  String category;
  String status;

  Contact({
    required this.id,
    required this.name,
    this.phone,
    required this.category,
    required this.status,
  });
}