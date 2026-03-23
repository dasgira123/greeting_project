import '../../../domain/entities/template.dart';

abstract class ITemplateRepository {
  Future<List<Template>> getAllTemplates(String? userId);
  Future<List<Template>> getSystemTemplates(String? userId);
  Future<List<Template>> getCustomTemplates(String? userId);
  Future<void> insertTemplate(Template template, {bool isSystem = false});
  Future<void> updateTemplate(Template template);
  Future<void> deleteTemplate(String id);
  Future<void> toggleFavorite(String templateId, String userId, bool isFavorite);
}
