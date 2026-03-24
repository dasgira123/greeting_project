class User {
  final String id;
  final String phone;
  final String fullName;
  final String? dob;
  final String? avatarPath;

  User({
    required this.id,
    required this.phone,
    required this.fullName,
    this.dob,
    this.avatarPath,
  });
}
