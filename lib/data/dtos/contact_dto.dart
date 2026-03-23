class ContactDto {
  final String id;
  final String name;
  final String? phone;
  final String category;
  final String status;
  final int? lastContactedEpoch;

  ContactDto({
    required this.id,
    required this.name,
    this.phone,
    required this.category,
    required this.status,
    this.lastContactedEpoch,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'category': category,
      'status': status,
      'last_contacted_epoch': lastContactedEpoch,
    };
  }

  factory ContactDto.fromMap(Map<String, dynamic> map) {
    return ContactDto(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      category: map['category'] as String,
      status: map['status'] as String,
      lastContactedEpoch: map['last_contacted_epoch'] as int?,
    );
  }
}
