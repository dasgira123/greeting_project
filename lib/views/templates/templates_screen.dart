import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/template.dart';
import '../../viewmodels/home/home_viewmodel.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  String selectedFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    // THAY ĐỔI: Lấy dữ liệu ViewModel qua Provider
    final viewModel = context.watch<HomeViewModel>();

    List<Template> filteredTemplates = selectedFilter == 'Tất cả'
        ? viewModel.templates
        : viewModel.templates.where((t) => t.category == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mẫu lời chúc', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tìm ra lời chúc phù hợp cho người quan trọng của bạn.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Tất cả', 'Lịch sự', 'Hài hước', 'Chân thành'].map((filter) {
                  bool isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                      selected: isSelected,
                      selectedColor: const Color(0xFFD32F2F),
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        setState(() => selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: filteredTemplates.length,
                itemBuilder: (context, index) {
                  final template = filteredTemplates[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
                              child: Text(template.category.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.blue[700], fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.grey),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: template.text)).then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
                                });
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('"${template.text}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87, height: 1.5)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}