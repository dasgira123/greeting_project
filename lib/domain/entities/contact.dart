class Contact {
  final String id;
  final String name;
  final String? phone; // Thêm trường SĐT (nullable vì có thể có người chưa lưu sđt)
  String category; // Không dùng final để có thể cập nhật
  String status;

  Contact({
    required this.id,
    required this.name,
    this.phone,
    required this.category,
    required this.status
  });
}