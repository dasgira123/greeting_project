  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:greeting_project/models/app_state.dart';

  class ContactDetailScreen extends StatefulWidget {
    final Contact contact;
    const ContactDetailScreen({super.key, required this.contact});

    @override
    State<ContactDetailScreen> createState() => _ContactDetailScreenState();
  }

  class _ContactDetailScreenState extends State<ContactDetailScreen> {
    late String _currentCategory;

    @override
    void initState() {
      super.initState();
      // Khởi tạo thẻ danh mục hiện tại từ dữ liệu contact truyền vào
      _currentCategory = widget.contact.category;
    }

    void _markAsGreeted(BuildContext context, String newStatus) {
      appState.updateContactStatus(widget.contact.id, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[50],
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Chúc tết thành công!',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Lấy màu sắc tương ứng với từng thẻ
    Color _getCategoryColor(String category) {
      switch (category.toLowerCase()) {
        case 'gia đình':
          return Colors.orange;
        case 'đồng nghiệp':
          return Colors.purple;
        case 'bạn bè':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    // Lấy biểu tượng tương ứng với từng thẻ
    IconData _getCategoryIcon(String category) {
      switch (category.toLowerCase()) {
        case 'gia đình':
          return Icons.family_restroom;
        case 'đồng nghiệp':
          return Icons.work;
        case 'bạn bè':
          return Icons.group;
        default:
          return Icons.label;
      }
    }

    // Hiển thị Bottom Sheet để chọn/đổi thẻ phân loại
    void _showCategoryPicker() {
      final List<String> categories = ['Gia đình', 'Đồng nghiệp', 'Bạn bè'];

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Phân loại nhóm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...categories.map((category) {
                  final isSelected = _currentCategory == category;
                  return ListTile(
                    leading: Icon(_getCategoryIcon(category), color: _getCategoryColor(category)),
                    title: Text(category),
                    trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                    onTap: () {
                      setState(() {
                        _currentCategory = category;
                      });

                      // 🛠 ĐÃ SỬA: Gọi hàm cập nhật category trong appState
                      appState.updateContactCategory(widget.contact.id, category);

                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFFD32F2F),
              expandedHeight: 220,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(widget.contact.name,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),

                    // Nhãn phân loại (Có thể bấm vào để đổi)
                    GestureDetector(
                      onTap: _showCategoryPicker,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(_currentCategory).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getCategoryIcon(_currentCategory), size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(_currentCategory,
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 6),
                            const Icon(Icons.edit, size: 12, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _markAsGreeted(context, 'Gọi điện'),
                            child: _buildActionButton(Icons.phone, 'Gọi điện ngay', 'PHONE / FACETIME', Colors.green),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _markAsGreeted(context, 'Gửi tin nhắn'),
                            child: _buildActionButton(Icons.chat_bubble_outline, 'Gửi tin nhắn', 'SMS / ZALO', Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: const [
                        Icon(Icons.smart_toy, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Gợi ý từ AI', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    //Tự động render danh sách câu chúc dựa trên _currentCategory
                    ...appState.getSuggestionsForCategory(_currentCategory).map((template) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildGreetingCard(template.text),
                      );
                    }).toList(),

                  ],
                ),
              ),
            )
          ],
        ),
      );
    }

    Widget _buildActionButton(IconData icon, String title, String subtitle, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      );
    }

    Widget _buildGreetingCard(String text) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87, height: 1.5)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text)).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép!')));
                      });
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Sao chép lời chúc'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black54,
                      side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
  }