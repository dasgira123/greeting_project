import 'package:flutter/material.dart';
import '../../domain/entities/contact_category.dart';
import '../../data/interfaces/repositories/icategory_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final ICategoryRepository? categoryRepository;

  List<ContactCategory> categories = [];

  CategoryViewModel({this.categoryRepository}) {
    loadCategories();
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

  Future<void> deleteCategoryByName(String name) async {
    if (categoryRepository == null) return;
    try {
      final categoryToDelete = categories.firstWhere((c) => c.name == name);
      await categoryRepository!.deleteCategory(categoryToDelete.id);
            
      await loadCategories();
    } catch (e) {
      debugPrint("Error deleting category: $e");
    }
  }
}
