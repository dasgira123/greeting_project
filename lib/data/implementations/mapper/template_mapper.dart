import '../../../domain/entities/template.dart';
import '../../dtos/template_dto.dart';
import '../../interfaces/mapper/imapper.dart';

class TemplateMapper implements IMapper<TemplateDto, Template> {
  @override
  Template fromDtoToEntity(TemplateDto dto) {
    return Template(
      id: dto.id,
      text: dto.text,
      category: dto.category,
      isSystem: dto.isSystem == 1,
      usageCount: dto.usageCount,
      isFavorite: dto.isFavorite == 1,
      userId: dto.userId,
    );
  }

  @override
  TemplateDto fromEntityToDto(Template entity) {
    return TemplateDto(
      id: entity.id,
      text: entity.text,
      category: entity.category,
      isSystem: entity.isSystem ? 1 : 0,
      usageCount: entity.usageCount,
      isFavorite: entity.isFavorite ? 1 : 0,
      userId: entity.userId,
    );
  }
}
