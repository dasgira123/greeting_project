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
  Future<List<Template>> getAllTemplates() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query('templates');

    return maps.map((map) {
      final dto = TemplateDto.fromMap(map);
      return _mapper.fromDtoToEntity(dto);
    }).toList();
  }

  @override
  Future<List<Template>> getSystemTemplates() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'templates',
      where: 'is_system = ?',
      whereArgs: [1],
    );

    return maps.map((map) {
      final dto = TemplateDto.fromMap(map);
      return _mapper.fromDtoToEntity(dto);
    }).toList();
  }

  @override
  Future<List<Template>> getCustomTemplates() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'templates',
      where: 'is_system = ?',
      whereArgs: [0],
    );

    return maps.map((map) {
      final dto = TemplateDto.fromMap(map);
      return _mapper.fromDtoToEntity(dto);
    }).toList();
  }

  @override
  Future<void> insertTemplate(Template template, {bool isSystem = false}) async {
    final db = await _db;
    final dto = _mapper.fromEntityToDto(template);
    final map = dto.toMap();
    map['is_system'] = isSystem ? 1 : 0; // Ghi đè trạng thái hệ thống

    await db.insert('templates', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateTemplate(Template template) async {
    final db = await _db;
    final dto = _mapper.fromEntityToDto(template);
    final map = dto.toMap();
    // Remove is_system to avoid overwriting it unintentionally
    map.remove('is_system');

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
    await db.delete(
      'templates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
