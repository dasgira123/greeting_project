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
        : (selectedFilter == 'Khác' 
            ? viewModel.templates.where((t) => !['Trang trọng', 'Hài hước', 'Chân thành'].contains(t.category)).toList()
            : viewModel.templates.where((t) => t.category == selectedFilter).toList());

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
                children: [
                  'Tất cả', 
                  'Trang trọng', 
                  'Hài hước', 
                  'Chân thành', 
                  'Khác' // Để hứng những template người dùng tự lưu với category dị
                ].map((filter) {
                  bool isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      selected: isSelected,
                      selectedColor: const Color(0xFFD32F2F),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)),
                      onSelected: (selected) {
                        setState(() => selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

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
                              decoration: BoxDecoration(color: template.isSystem ? Colors.blue[50] : Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                template.category.toUpperCase(), 
                                style: TextStyle(
                                  fontSize: 10, 
                                  color: template.isSystem ? Colors.blue[700] : Colors.orange.shade800, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ),
                            Row(
                              children: [
                                if (!template.isSystem)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.auto_awesome, color: Colors.orange, size: 16),
                                  ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: template.text)).then((_) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Đã copy lời chúc từ bộ sưu tập!'),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 1),
                                      ));
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('"', style: TextStyle(fontSize: 24, height: 0.8, color: Colors.red.withOpacity(0.5), fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                template.text, 
                                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87, height: 1.5, fontSize: 15)
                              ),
                            ),
                          ],
                        ),
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