import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greeting_project/models/app_state.dart';

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;
  const ContactDetailScreen({super.key, required this.contact});

  void _markAsGreeted(BuildContext context, String newStatus) {
    appState.updateContactStatus(contact.id, newStatus);

    // Hiển thị Banner xanh lá như trong ảnh thiết kế
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[50],
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Successfully Greeted! Updated on checklist.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          duration: const Duration(seconds: 2),
        )
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
                  Text(contact.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Text(contact.category, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                  _buildGreetingCard(context, "Tết đến xuân về, chúc sức khỏe dồi dào, vạn sự bình an."),
                  const SizedBox(height: 12),
                  _buildGreetingCard(context, "Năm mới chúc gia đình mình luôn tràn đầy tiếng cười và hạnh phúc."),
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

  Widget _buildGreetingCard(BuildContext context, String text) {
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
                  label: const Text('sao chép lời chúc '),
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