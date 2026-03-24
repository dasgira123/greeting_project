import '../../../domain/entities/user.dart';

abstract class AuthRepository {
  Future<User?> login(String phone, String password);
  Future<User?> register({required String fullName, required String phone, required String password});
  Future<User?> updateProfile(String id, String fullName, String? dob);
  Future<User?> updatePassword(String id, String oldPassword, String newPassword);
  Future<User?> updateAvatar(String id, String avatarPath);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> checkPhoneExists(String phone);
}
