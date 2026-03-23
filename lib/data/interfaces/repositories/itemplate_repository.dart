import '../../../domain/entities/template.dart';

abstract class ITemplateRepository {
  Future<List<Template>> getAllTemplates();
  Future<List<Template>> getSystemTemplates();
  Future<List<Template>> getCustomTemplates();
  Future<void> insertTemplate(Template template, {bool isSystem = false});
  Future<void> updateTemplate(Template template);
  Future<void> deleteTemplate(String id);
}
