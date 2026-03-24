import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  String? _selectedDob;
  String? _newAvatarPath;
  String? _currentAvatarPath;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthViewModel>();
    _nameCtrl = TextEditingController(text: auth.currentUser?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: auth.currentUser?.phone ?? '');
    _selectedDob = auth.currentUser?.dob;
    _currentAvatarPath = auth.currentUser?.avatarPath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime initialDate = DateTime(2000, 1, 1);
    if (_selectedDob != null) {
      try {
        final parts = _selectedDob!.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } catch (e) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFB71C1C)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
       try {
         final appDir = await getApplicationDocumentsDirectory();
         final ext = image.path.contains('.') ? image.path.split('.').last : 'jpg';
         final fileName = 'avatar_${context.read<AuthViewModel>().currentUser?.id ?? 'user'}_${DateTime.now().millisecondsSinceEpoch}.$ext';
         final savedFile = await File(image.path).copy('${appDir.path}/$fileName');
         
         setState(() {
            _newAvatarPath = savedFile.path;
         });
       } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi lưu ảnh: $e')));
         }
       }
    }
  }

  void _onSave() async {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập họ tên')));
      return;
    }

    final auth = context.read<AuthViewModel>();
    final success = await auth.updateProfile(_nameCtrl.text, _selectedDob);
    
    if (success && mounted) {
      if (_newAvatarPath != null) {
         await auth.updateAvatar(_newAvatarPath!);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật hồ sơ thành công!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } else if (mounted) {
      final msg = auth.errorMessage ?? 'Lỗi cập nhật. Vui lòng thử lại.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  Widget _buildField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: TextStyle(color: readOnly ? Colors.white60 : Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NGÀY SINH', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDob ?? 'Chọn ngày sinh',
                  style: TextStyle(color: _selectedDob == null ? Colors.white60 : Colors.white, fontSize: 16),
                ),
                const Icon(Icons.calendar_today, color: Colors.white60, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFC62828),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Chỉnh Sửa Hồ Sơ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(top: -50, right: -50, child: Icon(Icons.celebration, size: 250, color: Colors.white.withOpacity(0.05))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Avatar in EditScreen
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            backgroundImage: _newAvatarPath != null
                                ? FileImage(File(_newAvatarPath!))
                                : (_currentAvatarPath != null && File(_currentAvatarPath!).existsSync()
                                    ? FileImage(File(_currentAvatarPath!))
                                    : null) as ImageProvider?,
                            child: (_newAvatarPath == null && (_currentAvatarPath == null || !File(_currentAvatarPath!).existsSync()))
                                ? Icon(Icons.person, size: 40, color: Colors.white.withOpacity(0.85))
                                : null,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Color(0xFFC62828), size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('AI sẽ dùng độ tuổi của bạn để gợi ý các lời chúc có phong cách và xưng hô phù hợp nhất!', style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  _buildField('Họ và tên', _nameCtrl),
                  _buildField('Số điện thoại', _phoneCtrl, readOnly: true),
                  _buildDateSelector(),
                  
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: auth.isLoading ? null : _onSave,
                      child: auth.isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.red))
                        : const Text('Lưu Thay Đổi', style: TextStyle(color: Color(0xFFB71C1C), fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
