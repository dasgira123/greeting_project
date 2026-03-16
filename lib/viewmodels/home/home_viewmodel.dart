import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import '../../domain/entities/contact.dart';
import '../../domain/entities/template.dart';
import '../../domain/entities/contact_category.dart';
import '../../data/interfaces/repositories/icategory_repository.dart';
import '../../data/interfaces/repositories/icontact_repository.dart';
import '../../data/interfaces/repositories/itemplate_repository.dart';
import '../../services/ai_service.dart';

class HomeViewModel extends ChangeNotifier {
  final IContactRepository? contactRepository;
  final ICategoryRepository? categoryRepository;
  final ITemplateRepository? templateRepository;
  final AIService? aiService;

  List<Contact> contacts = [];
  List<ContactCategory> categories = [];
  bool isLoading = false;

  // Dữ liệu template sẽ được tải từ database thay vì mock cứng
  List<Template> templates = [];

  HomeViewModel({
    this.contactRepository, 
    this.categoryRepository,
    this.templateRepository,
    this.aiService,
  }) {
    loadCategories();
    loadContacts();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    if (templateRepository == null) return;
    templates = await templateRepository!.getAllTemplates();
    notifyListeners();
  }

  // Phương thức gọi AI
  Future<List<Map<String, String>>> generateAIGreetings(Contact contact, {String extraNote = ''}) async {
    if (aiService == null) return [];
    
    isLoading = true;
    notifyListeners();
    
    final greetings = await aiService!.generateGreetings(contact, extraNote: extraNote);
    
    isLoading = false;
    notifyListeners();
    
    return greetings;
  }

  // Lưu lời chúc vừa copy vào Database
  Future<void> saveAIGreeting(String text, String category) async {
    if (templateRepository == null) return;
    
    final newTemplate = Template(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      category: category,
      isSystem: false, // Do người dùng sinh ra
      usageCount: 1, // Đã copy là tính dùng 1 lần
    );
    
    await templateRepository!.insertTemplate(newTemplate);
    await loadTemplates(); // Refresh danh sách nội bộ
  }

  Future<void> loadCategories() async {
    if (categoryRepository == null) return;
    categories = await categoryRepository!.getAllCategories();
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    if (categoryRepository == null) return;
    final newCat = ContactCategory(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      name: name
    );
    await categoryRepository!.insertCategory(newCat);
    await loadCategories();
  }

  Future<void> loadContacts() async {
    if (contactRepository == null) return;
    
    isLoading = true;
    notifyListeners();

    contacts = await contactRepository!.getAllContacts();
    
    isLoading = false;
    notifyListeners();
  }

  // Import danh bạ từ điện thoại
  Future<void> importFromDevice(BuildContext context) async {
    if (contactRepository == null) return;

    // 1. Xin quyền
    final status = await fc.FlutterContacts.permissions.request(fc.PermissionType.read);
    if (status == fc.PermissionStatus.granted || status == fc.PermissionStatus.limited) {
      // 2. Mở giao diện chọn 1 người từ danh bạ gốc
      final String? contactId = await fc.FlutterContacts.native.showPicker();
      
      if (contactId != null) {
        // Lấy dữ liệu chi tiết bằng ID
        final fc.Contact? contact = await fc.FlutterContacts.get(
          contactId,
          properties: {fc.ContactProperty.phone},
        );

        if (contact != null) {
          // Lấy SĐT nếu có
          String phone = '';
          if (contact.phones.isNotEmpty) {
            phone = contact.phones.first.number;
          }

          // 3. Mặc định gán category (Có thể hiển thị Dialog cho User chọn sau)
          String defaultCategory = 'Chưa phân loại';

          // Lấy tên hiển thị
          String name = contact.displayName ?? 'Không xác định';

          // 4. Khởi tạo đối tượng Contact
          final newContact = Contact(
            id: DateTime.now().millisecondsSinceEpoch.toString(), // ID tự chế tạm thời
            name: name,
            phone: phone.isNotEmpty ? phone : null,
            category: defaultCategory,
            status: 'Pending',
          );

          // 5. Lưu vào SQLite
          await contactRepository!.insertContact(newContact);
          
          // 6. Cập nhật lại list trên UI
          await loadContacts();
        }
      }
    }
  }

  int get totalContacts => contacts.length;
  int get greetedContacts => contacts.where((c) => c.status != 'Pending').length;

  Future<void> updateContactStatus(String id, String newStatus) async {
    final index = contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      contacts[index].status = newStatus;
      if (contactRepository != null) {
        await contactRepository!.updateContact(contacts[index]);
      }
      notifyListeners();
    }
  }

  Future<void> updateContactCategory(String id, String newCategory) async {
    final index = contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      contacts[index].category = newCategory;
      if (contactRepository != null) {
        await contactRepository!.updateContact(contacts[index]);
      }
      notifyListeners();
    }
  }

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

  String _searchQuery = '';

  void searchContacts(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Map<String, List<Contact>> get groupedContacts {
    Map<String, List<Contact>> groupedData = {};
    
    final filteredContacts = _searchQuery.isEmpty 
        ? contacts 
        : contacts.where((contact) {
            final nameMatch = contact.name.toLowerCase().contains(_searchQuery.toLowerCase());
            final phoneMatch = contact.phone != null && contact.phone!.toLowerCase().contains(_searchQuery.toLowerCase());
            return nameMatch || phoneMatch;
          }).toList();

    for (var contact in filteredContacts) {
      if (!groupedData.containsKey(contact.category)) {
        groupedData[contact.category] = [];
      }
      groupedData[contact.category]!.add(contact);
    }
    return groupedData;
  }
}