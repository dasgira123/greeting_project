import '../../../domain/entities/contact_category.dart';
import '../../dtos/category_dto.dart';
import '../../interfaces/mapper/imapper.dart';

class CategoryMapper implements IMapper<CategoryDto, ContactCategory> {
  @override
  ContactCategory fromDtoToEntity(CategoryDto dto) {
    return ContactCategory(
      id: dto.id,
      name: dto.name,
      isDefault: dto.isDefault == 1,
    );
  }

  @override
  CategoryDto fromEntityToDto(ContactCategory entity) {
    return CategoryDto(
      id: entity.id,
      name: entity.name,
      isDefault: entity.isDefault ? 1 : 0,
    );
  }
}
