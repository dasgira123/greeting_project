import 'package:flutter/material.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/template.dart';

class HomeViewModel extends ChangeNotifier {
  // Dữ liệu giả lập
  List<Contact> contacts = [
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
      notifyListeners();
    }
  }

  // Hàm cập nhật thẻ phân loại
  void updateContactCategory(String id, String newCategory) {
    final index = contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      contacts[index].category = newCategory;
      notifyListeners();
    }
  }

  // Hàm hỗ trợ lấy câu chúc
  List<Template> getSuggestionsForCategory(String contactCategory) {
    if (contactCategory == 'Gia đình') {
      return templates.where((t) => t.category == 'Chân thành').toList();
    } else if (contactCategory == 'Đồng nghiệp') {
      return templates.where((t) => t.category == 'Lịch sự').toList();
    } else if (contactCategory == 'Bạn bè') {
      return templates.where((t) => t.category == 'Hài hước').toList();
    }
    return templates;
  }

  // THÊM MỚI: Hàm gom nhóm dữ liệu danh bạ theo Category
  Map<String, List<Contact>> get groupedContacts {
    Map<String, List<Contact>> groupedData = {};
    for (var contact in contacts) {
      if (!groupedData.containsKey(contact.category)) {
        groupedData[contact.category] = [];
      }
      groupedData[contact.category]!.add(contact);
    }
    return groupedData;
  }
}