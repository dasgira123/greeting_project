abstract class IMapper<DTO, ENTITY> {
  ENTITY fromDtoToEntity(DTO dto);
  DTO fromEntityToDto(ENTITY entity);
}
