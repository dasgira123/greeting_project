import 'package:flutter/material.dart';
import 'package:greeting_project/viewmodels/home/contact_viewmodel.dart';
import 'package:greeting_project/views/widgets/contact_card.dart';
import 'package:greeting_project/views/widgets/progress_card.dart';
import 'package:greeting_project/utils/category_helper.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thay đổi 1: Màu nền trắng tinh tế hơn thay vì xám
      backgroundColor: Colors.white,
      body: Consumer<ContactViewModel>(
        builder: (context, viewModel, child) {
          int total = viewModel.totalContacts;
          int greeted = viewModel.greetedContacts;
          double progress = total == 0 ? 0 : greeted / total;

          final groupedData = viewModel.groupedContacts;
          final categories = groupedData.keys.toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // Chỉnh padding gọn hơn
            children: [
              const Text(
                'Danh Bạ Chúc Tết',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ProgressCard(greeted: greeted, total: total, progress: progress),

              const SizedBox(height: 24),

              // TextField thiết kế bo tròn với viền đỏ mờ (Giống ảnh mẫu)
              TextField(
                onChanged: (value) => viewModel.searchContacts(value),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm trong danh bạ...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50], // Nền hơi xám nhẹ
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Bo tròn sâu hơn
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFD32F2F)), // Viền đỏ khi focus
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ...categories.map((category) {
                final contactsInCategory = groupedData[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                                fontSize: 16, // Chỉnh size chữ phù hợp hơn
                                fontWeight: FontWeight.bold,
                                color: CategoryHelper.getColor(category) // Màu linh hoạt
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${contactsInCategory.length})',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    ...contactsInCategory.map((contact) => ContactCard(contact: contact)).toList(),

                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<ContactViewModel>().importFromDevice(context);
        },
        backgroundColor: const Color(0xFFD32F2F),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Từ danh bạ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}