import '../local/app_database.dart';
import '../../dtos/login/user_dto.dart';
import '../../dtos/login/login_request_dto.dart';
import '../../dtos/login/login_response_dto.dart';

class AuthApi {
  final AppDatabase _db = AppDatabase.instance;

  Future<LoginResponseDto> login(LoginRequestDto request) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'phone = ? AND password = ?', // Lưu ý: thực tế nên mã hóa hash!
      whereArgs: [request.phone, request.password],
    );

    if (maps.isNotEmpty) {
      return LoginResponseDto(
        success: true,
        message: 'Đăng nhập thành công',
        user: UserDto.fromMap(maps.first),
      );
    } else {
      return LoginResponseDto(
        success: false,
        message: 'Số điện thoại hoặc mật khẩu không đúng',
      );
    }
  }

  Future<LoginResponseDto> register(UserDto userDto) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('users', where: 'phone = ?', whereArgs: [userDto.phone]);
    if (maps.isNotEmpty) return LoginResponseDto(success: false, message: 'Số điện thoại đã được đăng ký');
    await db.insert('users', userDto.toMap());
    return LoginResponseDto(success: true, message: 'Đăng ký thành công', user: userDto);
  }

  Future<LoginResponseDto> updateProfile(String id, String fullName, String? dob) async {
    final db = await _db.database;
    await db.update('users', {'full_name': fullName, 'dob': dob}, where: 'id = ?', whereArgs: [id]);
    final List<Map<String, dynamic>> maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return LoginResponseDto(success: true, message: 'Cập nhật thành công', user: UserDto.fromMap(maps.first));
    return LoginResponseDto(success: false, message: 'Lỗi cập nhật');
  }

  Future<LoginResponseDto> updatePassword(String id, String oldPassword, String newPassword) async {
    final db = await _db.database;
    final maps = await db.query('users', where: 'id = ? AND password = ?', whereArgs: [id, oldPassword]);
    if (maps.isEmpty) return LoginResponseDto(success: false, message: 'Mật khẩu cũ không chính xác');
    await db.update('users', {'password': newPassword}, where: 'id = ?', whereArgs: [id]);
    final updatedMaps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return LoginResponseDto(success: true, message: 'Đổi mật khẩu thành công', user: UserDto.fromMap(updatedMaps.first));
  }

  Future<bool> checkPhoneExists(String phone) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('users', where: 'phone = ?', whereArgs: [phone]);
    return maps.isNotEmpty;
  }

  Future<bool> resetPassword(String phone, String newPassword) async {
    final db = await _db.database;
    int count = await db.update('users', {'password': newPassword}, where: 'phone = ?', whereArgs: [phone]);
    return count > 0;
  }

  Future<LoginResponseDto> updateAvatar(String id, String avatarPath) async {
    final db = await _db.database;
    await db.update('users', {'avatar_path': avatarPath}, where: 'id = ?', whereArgs: [id]);
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return LoginResponseDto(success: true, message: 'Đổi ảnh đại diện thành công', user: UserDto.fromMap(maps.first));
    return LoginResponseDto(success: false, message: 'Lỗi cập nhật');
  }
}
