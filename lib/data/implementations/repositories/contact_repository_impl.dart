import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/contact.dart';
import '../../dtos/contact_dto.dart';
import '../../interfaces/repositories/icontact_repository.dart';
import '../local/app_database.dart';
import '../mapper/contact_mapper.dart';

class ContactRepositoryImpl implements IContactRepository {
  final ContactMapper _mapper = ContactMapper();
  
  Future<Database> get _db async => await AppDatabase.instance.database;

  @override
  Future<List<Contact>> getAllContacts() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query('contacts');
    
    return maps.map((map) {
      final dto = ContactDto.fromMap(map);
      return _mapper.fromDtoToEntity(dto);
    }).toList();
  }

  @override
  Future<Contact?> getContactById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id.toString()],
    );

    if (maps.isNotEmpty) {
      final dto = ContactDto.fromMap(maps.first);
      return _mapper.fromDtoToEntity(dto);
    }
    return null;
  }

  @override
  Future<void> insertContact(Contact contact) async {
    final db = await _db;
    final dto = _mapper.fromEntityToDto(contact);
    await db.insert('contacts', dto.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateContact(Contact contact) async {
    final db = await _db;
    final dto = _mapper.fromEntityToDto(contact);
    await db.update(
      'contacts',
      dto.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  @override
  Future<void> deleteContact(String id) async {
    final db = await _db;
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
