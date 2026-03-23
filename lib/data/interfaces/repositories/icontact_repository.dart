import '../../../domain/entities/contact.dart';

abstract class IContactRepository {
  Future<List<Contact>> getAllContacts();
  Future<Contact?> getContactById(int id);
  Future<void> insertContact(Contact contact);
  Future<void> updateContact(Contact contact);
  Future<void> deleteContact(String id);
}
