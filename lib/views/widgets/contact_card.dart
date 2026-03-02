import 'package:flutter/material.dart';
import 'package:greeting_project/models/app_state.dart';
import 'package:greeting_project/views/contact_detail_screen.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;

  const ContactCard({super.key, required this.contact});

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Called' ? Colors.green : (status == 'Messaged' ? Colors.blue : Colors.grey);
    IconData icon = status == 'Called' ? Icons.phone_in_talk : (status == 'Messaged' ? Icons.message : Icons.access_time);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactDetailScreen(contact: contact)),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Colors.orange[50],
          child: const Icon(Icons.person_outline, color: Colors.orange),
        ),
        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: _buildStatusBadge(contact.status),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}