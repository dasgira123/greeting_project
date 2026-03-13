class Contact {
  final String id;
  final String name;
  String category; // Không dùng final để có thể cập nhật
  String status;

  Contact({
    required this.id,
    required this.name,
    required this.category,
    required this.status
  });
}