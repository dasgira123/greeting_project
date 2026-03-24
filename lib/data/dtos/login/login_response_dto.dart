import 'user_dto.dart';

class LoginResponseDto {
  final bool success;
  final String message;
  final UserDto? user;

  LoginResponseDto({
    required this.success,
    required this.message,
    this.user,
  });
}
