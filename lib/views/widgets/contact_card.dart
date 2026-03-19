import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/contact.dart';
import '../../viewmodels/home/contact_viewmodel.dart';
import '../contact/contact_detail_screen.dart';
import '../../utils/category_helper.dart';

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
        color: Colors.white, // Nền trắng tính tế
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Bóng thả cực nhẹ
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
          backgroundColor: CategoryHelper.getColor(contact.category).withOpacity(0.15),
          child: Icon(CategoryHelper.getIcon(contact.category), color: CategoryHelper.getColor(contact.category)),
        ),
        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 4), // Cách tên ra một chút
            child: _buildStatusBadge(contact.status),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa liên hệ?'),
                    content: Text('Bạn có chắc chắn muốn xóa "${contact.name}" không?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                      TextButton(
                        onPressed: () {
                          context.read<ContactViewModel>().deleteContact(contact.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa liên hệ')));
                        }, 
                        child: const Text('Xóa', style: TextStyle(color: Colors.red))
                      ),
                    ],
                  ),
                );
              },
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}