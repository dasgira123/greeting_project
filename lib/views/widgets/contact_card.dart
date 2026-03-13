import 'package:flutter/material.dart';
import '../../domain/entities/contact.dart';
import '../contact/contact_detail_screen.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;

  const ContactCard({super.key, required this.contact});

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Called' ? Colors.green : (status == 'Messaged' ? Colors.blue : Colors.grey);
    IconData icon = status == 'Called' ? Icons.phone_in_talk : (status == 'Messaged' ? Icons.message : Icons.access_time);
    // Viết hoa chữ cái đầu cho trạng thái
    String displayStatus = status == 'Called' ? 'Called' : (status == 'Messaged' ? 'Messaged' : 'Pending');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20), // Bo tròn sâu hơn
        border: Border.all(color: color.withOpacity(0.3)), // Viền nhạt hơn
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(displayStatus, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB), // Nền xám rất nhẹ, nhìn sang hơn Card trắng
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)), // Viền xám mờ
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactDetailScreen(contact: contact)),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Colors.orange[50],
          // Thay đổi icon để giống ảnh mẫu hơn
          child: const Icon(Icons.person, color: Colors.orange),
        ),
        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 4), // Cách tên ra một chút
            child: _buildStatusBadge(contact.status),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ),
    );
  }
}