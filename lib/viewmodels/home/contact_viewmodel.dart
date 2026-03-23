import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import '../../domain/entities/contact.dart';
import '../../data/interfaces/repositories/icontact_repository.dart';

class ContactViewModel extends ChangeNotifier {
  final IContactRepository? contactRepository;

  List<Contact> contacts = [];
  bool isLoading = false;
  String _searchQuery = '';

  ContactViewModel({this.contactRepository}) {
    loadContacts();
  }

  Future<void> loadContacts() async {
    if (contactRepository == null) return;
    
    isLoading = true;
    notifyListeners();

    contacts = await contactRepository!.getAllContacts();
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> importFromDevice(BuildContext context) async {
    if (contactRepository == null) return;

    final status = await fc.FlutterContacts.permissions.request(fc.PermissionType.read);
    if (status == fc.PermissionStatus.granted || status == fc.PermissionStatus.limited) {
      final String? contactId = await fc.FlutterContacts.native.showPicker();
      
      if (contactId != null) {
        final fc.Contact? contact = await fc.FlutterContacts.get(
          contactId,
          properties: {fc.ContactProperty.phone},
        );

        if (contact != null) {
          String phone = '';
          if (contact.phones.isNotEmpty) {
            phone = contact.phones.first.number;
          }

          String defaultCategory = 'Chưa phân loại';
          String name = contact.displayName ?? 'Không xác định';

          final newContact = Contact(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            phone: phone.isNotEmpty ? phone : null,
            category: defaultCategory,
            status: 'Pending',
          );

          await contactRepository!.insertContact(newContact);
          await loadContacts();
        }
      }
    }
  }

  int get totalContacts => contacts.length;
  int get greetedContacts => contacts.where((c) => c.status != 'Pending').length;

  Future<void> deleteContact(String id) async {
    if (contactRepository == null) return;
    await contactRepository!.deleteContact(id);
    contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> updateContactStatus(String id, String newStatus) async {
    final index = contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      contacts[index].status = newStatus;
      if (contactRepository != null) {
        await contactRepository!.updateContact(contacts[index]);
      }
      notifyListeners();
    }
  }

  Future<void> updateContactCategory(String id, String newCategory) async {
    final index = contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      contacts[index].category = newCategory;
      if (contactRepository != null) {
        await contactRepository!.updateContact(contacts[index]);
      }
      notifyListeners();
    }
  }

  void searchContacts(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Map<String, List<Contact>> get groupedContacts {
    Map<String, List<Contact>> groupedData = {};
    
    final filteredContacts = _searchQuery.isEmpty 
        ? contacts 
        : contacts.where((contact) {
            final nameMatch = contact.name.toLowerCase().contains(_searchQuery.toLowerCase());
            final phoneMatch = contact.phone != null && contact.phone!.toLowerCase().contains(_searchQuery.toLowerCase());
            return nameMatch || phoneMatch;
          }).toList();

    for (var contact in filteredContacts) {
      if (!groupedData.containsKey(contact.category)) {
        groupedData[contact.category] = [];
      }
      groupedData[contact.category]!.add(contact);
    }
    return groupedData;
  }

  Future<void> resetCategoryToDefault(String oldCategory) async {
    if (contactRepository == null) return;
    bool hasChanges = false;
    for (var contact in contacts.where((c) => c.category == oldCategory)) {
      contact.category = 'Chưa phân loại';
      await contactRepository!.updateContact(contact);
      hasChanges = true;
    }
    if (hasChanges) {
      await loadContacts();
    }
  }
}
