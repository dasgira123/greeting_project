import 'package:flutter/material.dart';

class Contact {
  final String id;
  final String name;
  String category; // Bỏ chữ 'final' để có thể cập nhật phân loại
  String status;

  Contact({required this.id, required this.name, required this.category, required this.status});
}

class Template {
  final String id;
  final String text;
  final String category; // Ví dụ: 'Formal' (Trang trọng), 'Funny' (Hài hước), 'Heartfelt' (Chân thành)

  Template({required this.id, required this.text, required this.category});
}

// Lớp quản lý dữ liệu toàn cục
class AppState extends ChangeNotifier {
  List<Contact> contacts = [
    // Đã cập nhật category mẫu sang tiếng Việt để khớp với UI
    Contact(id: '1', name: 'Ông Bà Nội', category: 'Gia đình', status: 'Called'),
    Contact(id: '2', name: 'Ba Mẹ', category: 'Gia đình', status: 'Called'),
    Contact(id: '3', name: 'Sếp Nguyễn', category: 'Đồng nghiệp', status: 'Messaged'),
    Contact(id: '4', name: 'Chị Tư', category: 'Gia đình', status: 'Pending'),
    Contact(id: '5', name: 'Thằng Tí', category: 'Bạn bè', status: 'Pending'),
  ];

  List<Template> templates = [
    Template(id: '1', text: "Chúc mừng năm mới! Kính chúc quý đối tác và gia đình một năm mới An Khang Thịnh Vượng, Vạn Sự Như Ý.", category: 'Lịch sự'),
    Template(id: '2', text: "Nhân dịp Tết Nguyên Đán, em xin chúc anh/chị dồi dào sức khỏe, hạnh phúc và thành công rực rỡ.", category: 'Lịch sự'),
    Template(id: '3', text: "Năm mới chúc mày tiền vào như nước, tiền ra nhỏ giọt. Sức khỏe dồi dào, vạn sự như ý nhé!", category: 'Hài hước'),
    Template(id: '4', text: "Tết đến xuân về, chúc gia đình mình luôn tràn đầy tiếng cười, yêu thương và gắn kết.", category: 'Chân thành'),
    Template(id: '5', text: "Năm mới chúc bố mẹ luôn mạnh khỏe, bình an và sống lâu trăm tuổi cùng con cháu.", category: 'Chân thành'),
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

  // MỚI: Hàm cập nhật thẻ phân loại (Gia đình, Đồng nghiệp, Bạn bè)
  void updateContactCategory(String id, String newCategory) {
    final index = contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      contacts[index].category = newCategory;
      notifyListeners(); // Cập nhật lại UI ở mọi nơi dùng AppState
    }
  }

  // MỚI: Hàm hỗ trợ AI lấy câu chúc phù hợp với từng nhóm
  List<Template> getSuggestionsForCategory(String contactCategory) {
    if (contactCategory == 'Gia đình') {
      return templates.where((t) => t.category == 'Heartfelt').toList();
    } else if (contactCategory == 'Đồng nghiệp') {
      return templates.where((t) => t.category == 'Formal').toList();
    } else if (contactCategory == 'Bạn bè') {
      return templates.where((t) => t.category == 'Funny').toList();
    }
    // Mặc định trả về tất cả nếu không khớp
    return templates;
  }
}

// Khởi tạo biến toàn cục để các màn hình đều truy cập được
final appState = AppState();