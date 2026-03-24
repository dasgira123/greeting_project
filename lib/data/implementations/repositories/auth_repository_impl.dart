import '../../interfaces/repositories/auth_repository.dart';
import '../../../domain/entities/user.dart';
import '../api/auth_api.dart';
import '../mapper/auth_mapper.dart';
import '../../dtos/login/login_request_dto.dart';
import '../../dtos/login/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api;
  User? _currentUser;

  AuthRepositoryImpl(this._api);

  @override
  Future<User?> login(String phone, String password) async {
    final response = await _api.login(LoginRequestDto(phone: phone, password: password));
    if (response.success && response.user != null) {
      _currentUser = AuthMapper.toEntity(response.user!);
      return _currentUser;
    }
    throw Exception(response.message);
  }

  @override
  Future<User?> register({required String fullName, required String phone, required String password, String? dob}) async {
    final userDto = UserDto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      phone: phone,
      password: password,
      fullName: fullName,
      dob: dob,
    );
    final response = await _api.register(userDto);
    if (response.success && response.user != null) {
      _currentUser = AuthMapper.toEntity(response.user!);
      return _currentUser;
    }
    throw Exception(response.message);
  }

  @override
  Future<User?> updateProfile(String id, String fullName, String? dob) async {
    final response = await _api.updateProfile(id, fullName, dob);
    if (response.success && response.user != null) {
      _currentUser = AuthMapper.toEntity(response.user!);
      return _currentUser;
    }
    throw Exception(response.message);
  }

  @override
  Future<User?> updatePassword(String id, String oldPassword, String newPassword) async {
    final response = await _api.updatePassword(id, oldPassword, newPassword);
    if (response.success && response.user != null) {
      _currentUser = AuthMapper.toEntity(response.user!);
      return _currentUser;
    }
    throw Exception(response.message);
  }

  @override
  Future<User?> updateAvatar(String id, String avatarPath) async {
    final response = await _api.updateAvatar(id, avatarPath);
    if (response.success && response.user != null) {
      _currentUser = AuthMapper.toEntity(response.user!);
      return _currentUser;
    }
    throw Exception(response.message);
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<bool> checkPhoneExists(String phone) async {
    return await _api.checkPhoneExists(phone);
  }
}
