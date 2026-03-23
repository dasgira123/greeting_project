import 'package:flutter/material.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/template.dart';
import '../../data/interfaces/repositories/itemplate_repository.dart';
import '../../services/ai_service.dart';

class GreetingViewModel extends ChangeNotifier {
  final ITemplateRepository? templateRepository;
  final AIService? aiService;

  List<Template> templates = [];
  bool isLoading = false;
  String _searchQuery = '';

  GreetingViewModel({this.templateRepository, this.aiService}) {
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    if (templateRepository == null) return;
    templates = await templateRepository!.getAllTemplates();
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

  // Lưu lời chúc vừa copy vào Database (từ AI)
  Future<void> saveAIGreeting(String text, String category) async {
    if (templateRepository == null) return;
    
    final newTemplate = Template(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      category: category,
      isSystem: false,
      usageCount: 1,
    );
    
    await templateRepository!.insertTemplate(newTemplate);
    await loadTemplates();
  }

  // Thêm lời chúc thủ công
  Future<void> addCustomTemplate(String text, String category) async {
    if (templateRepository == null) return;

    final newTemplate = Template(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      category: category,
      isSystem: false,
      usageCount: 0,
    );

    await templateRepository!.insertTemplate(newTemplate);
    await loadTemplates();
  }

  // Chỉnh sửa lời chúc
  Future<void> editTemplate(String id, String newText, String newCategory) async {
    if (templateRepository == null) return;

    final index = templates.indexWhere((t) => t.id == id);
    if (index != -1) {
      templates[index].text = newText;
      templates[index].category = newCategory;
      await templateRepository!.updateTemplate(templates[index]);
      notifyListeners();
    }
  }

  // Bật/tắt yêu thích
  Future<void> toggleFavorite(String id) async {
    if (templateRepository == null) return;

    final index = templates.indexWhere((t) => t.id == id);
    if (index != -1) {
      templates[index].isFavorite = !templates[index].isFavorite;
      await templateRepository!.updateTemplate(templates[index]);
      notifyListeners();
    }
  }

  Future<void> deleteTemplate(String id) async {
    if (templateRepository == null) return;
    await templateRepository!.deleteTemplate(id);
    templates.removeWhere((t) => t.id == id);
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
