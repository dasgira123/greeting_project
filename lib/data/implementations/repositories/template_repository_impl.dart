import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/template.dart';
import '../../dtos/template_dto.dart';
import '../../interfaces/repositories/itemplate_repository.dart';
import '../local/app_database.dart';
import '../mapper/template_mapper.dart';

class TemplateRepositoryImpl implements ITemplateRepository {
  final TemplateMapper _mapper = TemplateMapper();

  Future<Database> get _db async => await AppDatabase.instance.database;

  @override
  Future<List<Template>> getAllTemplates(String? userId) async {
    final db = await _db;
    final String joinCondition = userId != null ? 'AND uf.user_id = ?' : 'AND 1=0';
    final String whereCondition = userId != null ? 'WHERE t.is_system = 1 OR t.user_id = ?' : 'WHERE t.is_system = 1';
    final List<dynamic> bindings = userId != null ? [userId, userId] : [];

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, 
             CASE WHEN uf.template_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
      FROM templates t
      LEFT JOIN user_favorites uf ON t.id = uf.template_id $joinCondition
      $whereCondition
    ''', bindings);

    return maps.map((map) => _mapper.fromDtoToEntity(TemplateDto.fromMap(map))).toList();
  }

  @override
  Future<List<Template>> getSystemTemplates(String? userId) async {
    final db = await _db;
    final String joinCondition = userId != null ? 'AND uf.user_id = ?' : 'AND 1=0';
    final List<dynamic> bindings = userId != null ? [userId] : [];

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, 
             CASE WHEN uf.template_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
      FROM templates t
      LEFT JOIN user_favorites uf ON t.id = uf.template_id $joinCondition
      WHERE t.is_system = 1
    ''', bindings);

    return maps.map((map) => _mapper.fromDtoToEntity(TemplateDto.fromMap(map))).toList();
  }

  @override
  Future<List<Template>> getCustomTemplates(String? userId) async {
    if (userId == null) return [];
    final db = await _db;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, 
             CASE WHEN uf.template_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
      FROM templates t
      LEFT JOIN user_favorites uf ON t.id = uf.template_id AND uf.user_id = ?
      WHERE t.is_system = 0 AND t.user_id = ?
    ''', [userId, userId]);

    return maps.map((map) => _mapper.fromDtoToEntity(TemplateDto.fromMap(map))).toList();
  }

  @override
  Future<void> insertTemplate(Template template, {bool isSystem = false}) async {
    final db = await _db;
    final dto = _mapper.fromEntityToDto(template);
    final map = dto.toMap();
    map['is_system'] = isSystem ? 1 : 0;
    
    // We don't insert is_favorite into templates table anymore (handled by junction)
    // But to avoid sqlite errors if the column exists, we can leave it.
    await db.insert('templates', map, conflictAlgorithm: ConflictAlgorithm.replace);
    
    if (template.isFavorite && template.userId != null) {
      await toggleFavorite(template.id, template.userId!, true);
    }
  }

  @override
  Future<void> updateTemplate(Template template) async {
    final db = await _db;
    final dto = _mapper.fromEntityToDto(template);
    final map = dto.toMap();
    map.remove('is_system');
    map.remove('is_favorite'); // Handled by toggleFavorite

    await db.update(
      'templates',
      map,
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final db = await _db;
    await db.delete('templates', where: 'id = ?', whereArgs: [id]);
    // user_favorites relies on ON DELETE CASCADE, so it cleans up automatically.
  }

  @override
  Future<void> toggleFavorite(String templateId, String userId, bool isFavorite) async {
    final db = await _db;
    if (isFavorite) {
      await db.insert(
        'user_favorites', 
        {'user_id': userId, 'template_id': templateId}, 
        conflictAlgorithm: ConflictAlgorithm.ignore
      );
    } else {
      await db.delete(
        'user_favorites', 
        where: 'user_id = ? AND template_id = ?', 
        whereArgs: [userId, templateId]
      );
    }
  }
}
