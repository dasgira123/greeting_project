import '../../../domain/entities/user.dart';
import '../../dtos/login/user_dto.dart';

class AuthMapper {
  static User toEntity(UserDto dto) {
    return User(
      id: dto.id,
      phone: dto.phone,
      fullName: dto.fullName,
      dob: dto.dob,
      avatarPath: dto.avatarPath,
    );
  }

  static UserDto toDto(User entity, String password) {
    return UserDto(
      id: entity.id,
      phone: entity.phone,
      password: password,
      fullName: entity.fullName,
      dob: entity.dob,
      avatarPath: entity.avatarPath,
    );
  }
}
