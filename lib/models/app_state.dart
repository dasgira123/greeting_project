import 'package:flutter/material.dart';

class Contact {
  final String id;
  final String name;
  final String category;
  String status; // Bỏ chữ 'final' để có thể cập nhật trạng thái

  Contact({required this.id, required this.name, required this.category, required this.status});
}

class Template {
  final String id;
  final String text;
  final String category;

  Template({required this.id, required this.text, required this.category});
}

// Lớp quản lý dữ liệu toàn cục
class AppState extends ChangeNotifier {
  List<Contact> contacts = [
    Contact(id: '1', name: 'Ông Bà Nội', category: 'FAMILY', status: 'Called'),
    Contact(id: '2', name: 'Ba Mẹ', category: 'FAMILY', status: 'Called'),
    Contact(id: '3', name: 'Anh Hai', category: 'FAMILY', status: 'Messaged'),
    Contact(id: '4', name: 'Chị Tư', category: 'FAMILY', status: 'Pending'),
    Contact(id: '5', name: 'Em họ Tí', category: 'FAMILY', status: 'Pending'),
  ];

  List<Template> templates = [
    Template(id: '1', text: "Chúc mừng năm mới! Kính chúc quý đối tác và gia đình một năm mới An Khang Thịnh Vượng, Vạn Sự Như Ý.", category: 'Formal'),
    Template(id: '2', text: "Nhân dịp Tết Nguyên Đán, em xin chúc anh/chị dồi dào sức khỏe, hạnh phúc và thành công rực rỡ.", category: 'Formal'),
    Template(id: '3', text: "Chúc mừng năm mới! Tiền vào như nước, tiền ra nhỏ giọt. Sức khỏe dồi dào, vạn sự như ý!", category: 'Funny'),
    Template(id: '4', text: "Tết đến xuân về, chúc gia đình mình luôn tràn đầy tiếng cười, yêu thương và gắn kết.", category: 'Heartfelt'),
  ];

  // Tính toán số lượng
  int get totalContacts => contacts.length;
  int get greetedContacts => contacts.where((c) => c.status != 'Pending').length;

  // Hàm cập nhật trạng thái
  void updateContactStatus(String id, String newStatus) {
    final index = contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      contacts[index].status = newStatus;
      notifyListeners(); // Báo cho các màn hình khác cập nhật UI
    }
  }
}

// Khởi tạo biến toàn cục để các màn hình đều truy cập được
final appState = AppState();