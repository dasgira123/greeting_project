import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/entities/contact.dart';

class AIService {
  // Thay thế bằng API Key thật của Google AI Studio (Gemini)
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  final GenerativeModel _model;

  AIService() : _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
    generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  /// Gọi Gemini API sinh ra 3 câu chúc với 3 phong cách khác biệt.
  Future<List<Map<String, String>>> generateGreetings(Contact contact, {String extraNote = '', int? senderBirthYear}) async {
    final prompt = '''
Bạn là chuyên gia viết lời chúc Tết Nguyên Đán Việt Nam.
Hãy viết chính xác 3 câu chúc Tết dành cho:
- Tên người nhận: ${contact.name}
- Mối quan hệ: ${contact.category}
${senderBirthYear != null ? "- THÔNG TIN NGƯỜI GỬI: Sinh năm $senderBirthYear. Bạn HÃY TỰ ĐỘNG CÂN NHẮC VÀ ĐIỀU CHỈNH CÁCH XƯNG HÔ, NGÔN TỪ sao cho PHÙ HỢP TUYỆT ĐỐI VỚI ĐỘ TUỔI THẾ HỆ CỦA NGƯỜI GỬI (Ví dụ: Gen Z dùng từ trending hài hước, thế hệ trưởng thành dùng từ đĩnh đạc, sâu sắc)." : ""}
${extraNote.isNotEmpty ? "- Chú ý thêm: $extraNote" : ""}

Yêu cầu:
Viết 3 câu chúc độc lập, MỖI CÂU ĐẠI DIỆN CHO MỘT PHONG CÁCH trong 3 phong cách sau:
1. "Trang trọng" (Lịch sự, nghiêm túc)
2. "Hài hước" (Vui nhộn, phá cách, gen Z)
3. "Chân thành" (Ấm áp, tình cảm)

Luật bắt buộc:
1. Bạn BẮT BUỘC chỉ trả về 1 mảng JSON hợp lệ, KHÔNG ĐƯỢC CÓ BẤT KỲ VĂN BẢN NÀO KHÁC BÊN NGOÀI.
2. KHÔNG DÙNG DẤU NGOẶC KÉP BÊN TRONG NỘI DUNG LỜI CHÚC (Ví dụ: "flex", "vip"). Nếu cần nhấn mạnh, hãy dùng dấu nháy đơn ('flex'). Cấm tuyệt đối làm gãy cấu trúc JSON.
3. Mỗi phần tử JSON phải là một Object có 2 key: "text" chứa lời chúc, và "style" chứa tên Phong cách.

Ví dụ định dạng trả về:
[
  {"text": "Năm mới kính chúc Sếp vạn sự như ý...", "style": "Trang trọng"},
  {"text": "Chúc mày năm mới tiền đè chết người, làm việc kiểu 'flex' nha...", "style": "Hài hước"},
  {"text": "Năm mới bình an nhé bạn của tôi...", "style": "Chân thành"}
]
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        String cleanedText = text.replaceAll('```json', '').replaceAll('```JSON', '').replaceAll('```', '').trim();

        final List<dynamic> jsonList = jsonDecode(cleanedText);
        return jsonList.map((e) => {
          "text": e["text"].toString(),
          "style": e["style"].toString()
        }).toList();
      }
      return _getFallbacks(contact);
    } catch (e) {
      print("Lỗi khi sinh lời chúc AI: $e");
      return [
        {"text": "Lỗi kết nối AI: $e", "style": "Lỗi"},
        {"text": "Hãy kiểm tra lại mạng Internet hoặc API Key.", "style": "Lỗi"},
        {"text": "Đảm bảo bạn đã cấp quyền Mạng trên thiết bị giả lập.", "style": "Lỗi"}
      ];
    }
  }

  List<Map<String, String>> _getFallbacks(Contact contact) {
    return [
      {"text": "Kính chúc ${contact.name} một năm mới an khang thịnh vượng, vạn sự như ý.", "style": "Trang trọng"},
      {"text": "Năm mới chúc ${contact.name} tiền vào như nước sông Đà, tiền ra nhỏ giọt như cà phê phin!", "style": "Hài hước"},
      {"text": "Mong ${contact.name} sang năm mới luôn giữ nụ cười và sớm vượt qua khó khăn nhé.", "style": "Chân thành"}
    ];
  }
}
