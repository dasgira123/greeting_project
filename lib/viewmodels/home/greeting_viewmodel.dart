import 'package:flutter/material.dart';
import 'package:greeting_project/domain/entities/user.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/template.dart';
import '../../data/interfaces/repositories/itemplate_repository.dart';
import '../../services/ai_service.dart';
import '../auth/auth_viewmodel.dart';

class GreetingViewModel extends ChangeNotifier {
  final ITemplateRepository? templateRepository;
  final AIService? aiService;

  List<Template> templates = [];
  bool isLoading = false;
  String _searchQuery = '';
  User? _currentUser;
  String? _userId;

  GreetingViewModel({this.templateRepository, this.aiService}) {
    loadTemplates();
  }

  void updateAuth(AuthViewModel auth) {
    if (_userId != auth.currentUser?.id || _currentUser?.dob != auth.currentUser?.dob) {
      _currentUser = auth.currentUser;
      _userId = _currentUser?.id;
      loadTemplates();
    }
  }

  Future<void> loadTemplates() async {
    if (templateRepository == null) return;
    templates = await templateRepository!.getAllTemplates(_userId);
    notifyListeners();
  }

  void searchTemplates(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Template> getFilteredTemplates({required String filter, bool favoritesOnly = false}) {
    List<Template> result = templates;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      result = result.where((t) => t.text.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Favorites only
    if (favoritesOnly) {
      result = result.where((t) => t.isFavorite).toList();
      return result;
    }

    // Category filter
    const standardCategories = ['Trang trọng', 'Hài hước', 'Chân thành'];
    if (filter == 'Tất cả') {
      return result;
    } else if (filter == 'Khác') {
      return result.where((t) => !standardCategories.contains(t.category)).toList();
    } else {
      return result.where((t) => t.category == filter).toList();
    }
  }

  Future<List<Map<String, String>>> generateAIGreetings(Contact contact, {String extraNote = ''}) async {
    if (aiService == null) return [];
    
    isLoading = true;
    notifyListeners();
    
    int? senderBirthYear;
    if (_currentUser?.dob != null) {
      try {
        final parts = _currentUser!.dob!.split('/');
        if (parts.length == 3) {
          senderBirthYear = int.parse(parts[2]);
        } else if (parts.length == 1 && parts[0].length == 4) {
          senderBirthYear = int.parse(parts[0]);
        }
      } catch (e) {}
    }
    
    final greetings = await aiService!.generateGreetings(contact, extraNote: extraNote, senderBirthYear: senderBirthYear);
    
    isLoading = false;
    notifyListeners();
    
    return greetings;
  }

  Future<void> saveAIGreeting(String text, String category) async {
    if (templateRepository == null) return;
    if (_userId == null) throw Exception("Bạn cần đăng nhập để lưu lời chúc mới.");
    
    final newTemplate = Template(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      category: category,
      isSystem: false,
      usageCount: 1,
      userId: _userId,
    );
    
    await templateRepository!.insertTemplate(newTemplate);
    await loadTemplates();
  }

  Future<void> addCustomTemplate(String text, String category) async {
    if (templateRepository == null) return;
    if (_userId == null) throw Exception("Bạn cần đăng nhập để tạo lời chúc mới.");

    final newTemplate = Template(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      category: category,
      isSystem: false,
      usageCount: 0,
      userId: _userId,
    );

    await templateRepository!.insertTemplate(newTemplate);
    await loadTemplates();
  }

  Future<void> editTemplate(String id, String newText, String newCategory) async {
    if (templateRepository == null) return;
    if (_userId == null) throw Exception("Chỉ tài khoản sở hữu mới có quyền chỉnh sửa.");

    final index = templates.indexWhere((t) => t.id == id);
    if (index != -1) {
      if (templates[index].userId != _userId) throw Exception("Không có quyền chỉnh sửa lời chúc của hệ thống hoặc người khác.");
      templates[index].text = newText;
      templates[index].category = newCategory;
      await templateRepository!.updateTemplate(templates[index]);
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String id) async {
    if (templateRepository == null) return;
    if (_userId == null) throw Exception("Vui lòng đăng nhập để có thể yêu thích mẫu chúc.");

    final index = templates.indexWhere((t) => t.id == id);
    if (index != -1) {
      final newValue = !templates[index].isFavorite;
      await templateRepository!.toggleFavorite(id, _userId!, newValue);
      templates[index].isFavorite = newValue;
      notifyListeners();
    }
  }

  Future<void> deleteTemplate(String id) async {
    if (templateRepository == null) return;
    if (_userId == null) throw Exception("Chưa đăng nhập.");
    
    final t = templates.firstWhere((t) => t.id == id);
    if (t.userId != _userId) throw Exception("Không thể xóa mẫu của hệ thống hoặc người khác.");

    await templateRepository!.deleteTemplate(id);
    templates.removeWhere((x) => x.id == id);
    notifyListeners();
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
}
