import '../../../domain/entities/contact_category.dart';

abstract class ICategoryRepository {
  Future<List<ContactCategory>> getAllCategories();
  Future<ContactCategory?> getCategoryById(String id);
  Future<void> insertCategory(ContactCategory category);
  Future<void> updateCategory(ContactCategory category);
  Future<void> deleteCategory(String id);
}
