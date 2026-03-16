import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Thêm provider
import '../../domain/entities/contact.dart'; // Import entity
import '../../viewmodels/home/home_viewmodel.dart'; // Import ViewModel
import '../../utils/category_helper.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;
  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late String _currentCategory;
  List<Map<String, String>> _aiSuggestions = [];
  bool _isAILoading = false;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.contact.category;
  }

  Future<void> _generateAIGreetings() async {
    setState(() {
      _isAILoading = true;
      _aiSuggestions = [];
    });

    final suggestions = await context.read<HomeViewModel>().generateAIGreetings(
      widget.contact,
    );

    if (mounted) {
      setState(() {
        _aiSuggestions = suggestions;
        _isAILoading = false;
      });
    }
  }

  void _markAsGreeted(BuildContext context, String newStatus) {
    // THAY ĐỔI: Dùng Provider gọi hàm thay vì appState
    context.read<HomeViewModel>().updateContactStatus(widget.contact.id, newStatus);
    setState(() {
      widget.contact.status = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green[50],
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Chúc tết thành công!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleGreetingStatus(bool? isChecked) {
    String newStatus = (isChecked == true) ? 'Called' : 'Pending';

    // THAY ĐỔI: Dùng Provider gọi hàm
    context.read<HomeViewModel>().updateContactStatus(widget.contact.id, newStatus);
    setState(() {
      widget.contact.status = newStatus;
    });

    if (isChecked == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[50],
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Đã đánh dấu hoàn thành!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Removed duplicate Category logic, using CategoryHelper instead

  void _showAddCategoryDialog() {
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm phân loại mới'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              hintText: 'Nhập tên phân loại...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final newCategory = categoryController.text.trim();
                if (newCategory.isNotEmpty) {
                  setState(() { _currentCategory = newCategory; });
                  context.read<HomeViewModel>().updateContactCategory(widget.contact.id, newCategory);
                  context.read<HomeViewModel>().addCategory(newCategory);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCategoryPicker() {
    // Lấy các category hiện có trong db (từ HomeViewModel)
    final List<String> categories = context.read<HomeViewModel>().categories.map((c) => c.name).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Phân loại nhóm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...categories.map((category) {
                        final isSelected = _currentCategory == category;
                        return ListTile(
                          leading: Icon(CategoryHelper.getIcon(category), color: CategoryHelper.getColor(category)),
                          title: Text(category),
                          trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                          onTap: () {
                            setState(() { _currentCategory = category; });
                            context.read<HomeViewModel>().updateContactCategory(widget.contact.id, category);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Color(0xFFD32F2F)),
                title: const Text('Thêm phân loại mới...', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _showAddCategoryDialog();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isGreeted = widget.contact.status != 'Pending';
    // Lấy những system templates có cùng category
    final suggestions = context.read<HomeViewModel>().templates.where((t) => t.category == _currentCategory && t.isSystem).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFD32F2F),
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(Icons.person, size: 45, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.contact.name, 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 26, 
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      )
                    ),
                    GestureDetector(
                      onTap: _showCategoryPicker,
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: CategoryHelper.getColor(_currentCategory).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CategoryHelper.getIcon(_currentCategory), size: 16, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(_currentCategory, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.edit, size: 14, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                          onTap: () => _markAsGreeted(context, 'Called'),
                          child: _buildActionButton(Icons.phone, 'Gọi điện ngay', 'PHONE / FACETIME', Colors.green),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _markAsGreeted(context, 'Messaged'),
                          child: _buildActionButton(Icons.chat_bubble_outline, 'Gửi tin nhắn', 'SMS / ZALO', Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.auto_awesome, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text('Gợi ý từ AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _isAILoading ? null : _generateAIGreetings,
                        icon: _isAILoading 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.refresh, size: 16),
                        label: Text(_aiSuggestions.isEmpty ? 'Tạo ngay' : 'Tạo lại', style: const TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isAILoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Colors.orange),
                    ))
                  else if (_aiSuggestions.isNotEmpty)
                    ..._aiSuggestions.map((suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildGreetingCard(suggestion['text']!, style: suggestion['style']!, isAI: true),
                      );
                    }).toList()
                  else
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: Text('Bấm "Tạo ngay" để AI gợi ý lời chúc dành riêng cho bạn!', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                    ),

                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.collections_bookmark_rounded, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Gợi ý có sẵn theo nhóm', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ...suggestions.map((template) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildGreetingCard(template.text, style: template.category, isSystemCard: true),
                    );
                  }).toList(),

                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: isGreeted ? Colors.green[50] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isGreeted ? Colors.green : Colors.grey.withOpacity(0.3), width: 1.5),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        'Mark as Greeted',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isGreeted ? Colors.green[800] : Colors.black87,
                        ),
                      ),
                      secondary: const Text('🎊', style: TextStyle(fontSize: 24)),
                      value: isGreeted,
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      onChanged: _toggleGreetingStatus,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 30),
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildGreetingCard(String text, {required String style, bool isAI = false, bool isSystemCard = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isAI ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isAI ? Border.all(color: Colors.orange.shade200) : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAI || isSystemCard)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isAI ? Colors.orange.shade100 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isAI ? 'Phong cách: $style' : style.toUpperCase(), 
                style: TextStyle(
                  fontSize: 10, 
                  color: isAI ? Colors.orange.shade900 : Colors.blue.shade700, 
                  fontWeight: FontWeight.bold
                )
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('"', style: TextStyle(fontSize: 32, height: 0.8, color: isAI ? Colors.orange : const Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text, 
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic, 
                    color: Colors.black87, 
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: text)).then((_) {
                  if (isAI) {
                     // Lưu vào CSDL Template mới, thay vì lưu vào liên hệ, chúng ta lưu bằng category là style của câu chúc
                     context.read<HomeViewModel>().saveAIGreeting(text, style);
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép và lưu vào Thư viện lời chúc!')));
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép!')));
                  }
                });
              },
              icon: Icon(Icons.copy_rounded, size: 18, color: isAI ? Colors.orange.shade800 : const Color(0xFFD32F2F)),
              label: Text(isAI ? 'Sao chép & Lưu lại' : 'Sao chép ngay', style: TextStyle(fontWeight: FontWeight.bold, color: isAI ? Colors.orange.shade800 : const Color(0xFFD32F2F))),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAI ? Colors.orange.shade100 : const Color(0xFFFDECEA),
                foregroundColor: isAI ? Colors.orange.shade800 : const Color(0xFFD32F2F),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}