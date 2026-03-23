import '../../../domain/entities/contact.dart';
import '../../dtos/contact_dto.dart';
import '../../interfaces/mapper/imapper.dart';

class ContactMapper implements IMapper<ContactDto, Contact> {
  @override
  Contact fromDtoToEntity(ContactDto dto) {
    return Contact(
      id: dto.id,
      name: dto.name,
      phone: dto.phone,
      category: dto.category,
      status: dto.status,
    );
  }

  @override
  ContactDto fromEntityToDto(Contact entity) {
    return ContactDto(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      category: entity.category,
      status: entity.status,
    );
  }
}
