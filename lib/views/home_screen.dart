import 'package:flutter/material.dart';
import 'package:greeting_project/models/app_state.dart';
import 'package:greeting_project/views/widgets/contact_card.dart';
import 'package:greeting_project/views/widgets/progress_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        // Tính toán tiến độ
        int total = appState.totalContacts;
        int greeted = appState.greetedContacts;
        double progress = total == 0 ? 0 : greeted / total;

        // Gom nhóm dữ liệu
        Map<String, List<Contact>> groupedData = {};
        for (var contact in appState.contacts) {
          if (!groupedData.containsKey(contact.category)) {
            groupedData[contact.category] = [];
          }
          groupedData[contact.category]!.add(contact);
        }
        final categories = groupedData.keys.toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Gọi Widget Tiến độ đã tách
            ProgressCard(greeted: greeted, total: total, progress: progress),

            const SizedBox(height: 20),

            // Thanh Tìm kiếm
            TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm trong danh bạ...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Danh sách phân loại
            ...categories.map((category) {
              final contactsInCategory = groupedData[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề nhóm
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          category,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800]),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${contactsInCategory.length})',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Gọi Widget Thẻ Liên Hệ đã tách
                  ...contactsInCategory.map((contact) => ContactCard(contact: contact)).toList(),

                  const SizedBox(height: 10),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }
}