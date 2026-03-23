class GreetingDto {
  final String id;
  final String contactId;
  final String? templateId;
  final String templateText;
  final String method;
  final int sentAtEpoch;

  GreetingDto({
    required this.id,
    required this.contactId,
    this.templateId,
    required this.templateText,
    required this.method,
    required this.sentAtEpoch,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contact_id': contactId,
      'template_id': templateId,
      'template_text': templateText,
      'method': method,
      'sent_at_epoch': sentAtEpoch,
    };
  }

  factory GreetingDto.fromMap(Map<String, dynamic> map) {
    return GreetingDto(
      id: map['id'] as String,
      contactId: map['contact_id'] as String,
      templateId: map['template_id'] as String?,
      templateText: map['template_text'] as String,
      method: map['method'] as String,
      sentAtEpoch: map['sent_at_epoch'] as int,
    );
  }
}
