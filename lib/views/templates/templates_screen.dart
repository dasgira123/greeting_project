import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/template.dart';
import '../../viewmodels/home/greeting_viewmodel.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> with SingleTickerProviderStateMixin {
  String selectedFilter = 'Tất cả';
  bool _favoritesOnly = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _favoritesOnly = _tabController.index == 1;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Shared dialog style helpers ──────────────────────────────
  static const _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
  );
  static const _inputFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1.5),
  );

  void _showAddTemplateDialog() {
    final textCtrl = TextEditingController();
    String selectedCategory = 'Chân thành';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thêm lời chúc mới',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: textCtrl,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Nhập nội dung lời chúc...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    border: _inputBorder,
                    enabledBorder: _inputBorder,
                    focusedBorder: _inputFocusedBorder,
                    contentPadding: EdgeInsets.all(10),
                    isDense: true,
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  decoration: const InputDecoration(
                    labelText: 'Phân loại',
                    labelStyle: TextStyle(fontSize: 12),
                    border: _inputBorder,
                    enabledBorder: _inputBorder,
                    focusedBorder: _inputFocusedBorder,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  items: ['Trang trọng', 'Hài hước', 'Chân thành', 'Khác']
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hủy', style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final text = textCtrl.text.trim();
                        if (text.isNotEmpty) {
                          context.read<GreetingViewModel>().addCustomTemplate(text, selectedCategory);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã thêm lời chúc mới!'), backgroundColor: Colors.green),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                      child: const Text('Thêm', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditTemplateDialog(Template template) {
    final textCtrl = TextEditingController(text: template.text);
    String selectedCategory = template.category;
    const validCategories = ['Trang trọng', 'Hài hước', 'Chân thành', 'Khác'];
    if (!validCategories.contains(selectedCategory)) {
      selectedCategory = 'Khác';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chỉnh sửa lời chúc',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: textCtrl,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Nội dung lời chúc...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    border: _inputBorder,
                    enabledBorder: _inputBorder,
                    focusedBorder: _inputFocusedBorder,
                    contentPadding: EdgeInsets.all(10),
                    isDense: true,
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  decoration: const InputDecoration(
                    labelText: 'Phân loại',
                    labelStyle: TextStyle(fontSize: 12),
                    border: _inputBorder,
                    enabledBorder: _inputBorder,
                    focusedBorder: _inputFocusedBorder,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  items: validCategories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hủy', style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final text = textCtrl.text.trim();
                        if (text.isNotEmpty) {
                          context.read<GreetingViewModel>().editTemplate(template.id, text, selectedCategory);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã cập nhật lời chúc!'), backgroundColor: Colors.blue),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                      child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GreetingViewModel>();
    final filteredTemplates = viewModel.getFilteredTemplates(
      filter: selectedFilter,
      favoritesOnly: _favoritesOnly,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mẫu lời chúc',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                const Text('Tìm ra lời chúc phù hợp cho người quan trọng của bạn.',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),

                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFFD32F2F),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFFD32F2F),
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Tất cả'),
                    Tab(icon: Icon(Icons.favorite, size: 16), text: 'Yêu thích'),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Category filter chips (only in "Tất cả" tab)
          if (!_favoritesOnly)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Tất cả', 'Trang trọng', 'Hài hước', 'Chân thành', 'Khác'].map((filter) {
                    bool isSelected = selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text(filter,
                            style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selected: isSelected,
                        selectedColor: const Color(0xFFD32F2F),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                        ),
                        onSelected: (_) => setState(() => selectedFilter = filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // List
          Expanded(
            child: filteredTemplates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_favoritesOnly ? Icons.favorite_border : Icons.notes,
                            size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text(
                          _favoritesOnly
                              ? 'Chưa có lời chúc yêu thích nào.\nBấm ❤️ để lưu lại!'
                              : 'Không có lời chúc nào.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) => _buildTemplateCard(filteredTemplates[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTemplateDialog,
        backgroundColor: const Color(0xFFD32F2F),
        icon: const Icon(Icons.add, color: Colors.white, size: 18),
        label: const Text('Thêm lời chúc',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildTemplateCard(Template template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: template.isFavorite ? Colors.red.withOpacity(0.35) : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: badge + action icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: template.isSystem ? Colors.blue[50] : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  template.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    color: template.isSystem ? Colors.blue[700] : Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Action icons row (compact)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!template.isSystem)
                    const Icon(Icons.auto_awesome, color: Colors.orange, size: 14),
                  _iconBtn(
                    template.isFavorite ? Icons.favorite : Icons.favorite_border,
                    template.isFavorite ? Colors.red : Colors.grey[400]!,
                    () => context.read<GreetingViewModel>().toggleFavorite(template.id),
                  ),
                  if (!template.isSystem) ...[
                    _iconBtn(Icons.edit_outlined, Colors.blueGrey,
                        () => _showEditTemplateDialog(template)),
                    _iconBtn(Icons.delete_outline, Colors.redAccent, () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xóa lời chúc?', style: TextStyle(fontSize: 15)),
                          content: const Text('Mẫu lời chúc này sẽ bị xóa vĩnh viễn.',
                              style: TextStyle(fontSize: 13)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Hủy', style: TextStyle(fontSize: 13))),
                            TextButton(
                              onPressed: () {
                                context.read<GreetingViewModel>().deleteTemplate(template.id);
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã xóa mẫu lời chúc')),
                                );
                              },
                              child: const Text('Xóa',
                                  style: TextStyle(color: Colors.red, fontSize: 13)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  _iconBtn(Icons.copy, Colors.grey[400]!, () {
                    Clipboard.setData(ClipboardData(text: template.text)).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã sao chép!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    });
                  }),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Quote text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('"',
                  style: TextStyle(
                      fontSize: 18, height: 0.9, color: Colors.red.withOpacity(0.45), fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  template.text,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.black87, height: 1.45, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}