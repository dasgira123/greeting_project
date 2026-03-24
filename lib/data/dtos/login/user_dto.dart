class UserDto {
  final String id;
  final String phone;
  final String password;
  final String fullName;
  final String? dob;
  final String? avatarPath;

  UserDto({
    required this.id,
    required this.phone,
    required this.password,
    required this.fullName,
    this.dob,
    this.avatarPath,
  });

  factory UserDto.fromMap(Map<String, dynamic> map) {
    return UserDto(
      id: map['id'] as String,
      phone: map['phone'] as String,
      password: map['password'] as String,
      fullName: map['full_name'] as String,
      dob: map['dob'] as String?,
      avatarPath: map['avatar_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone': phone,
      'password': password,
      'full_name': fullName,
      'dob': dob,
      'avatar_path': avatarPath,
    };
  }
}
