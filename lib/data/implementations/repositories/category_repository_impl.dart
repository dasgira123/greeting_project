import 'package:sqflite/sqflite.dart';
import '../../interfaces/repositories/icategory_repository.dart';
import '../../../domain/entities/contact_category.dart';
import '../local/app_database.dart';
import '../../dtos/category_dto.dart';
import '../mapper/category_mapper.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  final CategoryMapper _mapper = CategoryMapper();

  Future<Database> get _db async => await AppDatabase.instance.database;

  @override
  Future<List<ContactCategory>> getAllCategories() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query('categories');

    return maps.map((map) {
      final dto = CategoryDto.fromMap(map);
      return _mapper.fromDtoToEntity(dto);
    }).toList();
  }

  @override
  Future<ContactCategory?> getCategoryById(String id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final dto = CategoryDto.fromMap(maps.first);
      return _mapper.fromDtoToEntity(dto);
    }
    return null;
  }

  @override
  Future<void> insertCategory(ContactCategory category) async {
    final db = await _db;
    final dto = _mapper.fromEntityToDto(category);
    await db.insert(
      'categories',
      dto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateCategory(ContactCategory category) async {
    final db = await _db;
    final dto = _mapper.fromEntityToDto(category);
    await db.update(
      'categories',
      dto.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await _db;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
