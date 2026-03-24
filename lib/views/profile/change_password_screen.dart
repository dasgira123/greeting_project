import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  
  bool _oldVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')));
      return;
    }
    if (_newPassCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xác nhận mật khẩu mới không khớp')));
      return;
    }

    final auth = context.read<AuthViewModel>();
    final success = await auth.updatePassword(_oldPassCtrl.text, _newPassCtrl.text);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else if (mounted) {
      final msg = auth.errorMessage ?? 'Lỗi cập nhật. Vui lòng thử lại.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  Widget _buildField(String label, TextEditingController controller, bool isVisible, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white54), onPressed: onToggle),
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
        title: const Text('Đổi Mật Khẩu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(bottom: -50, left: -50, child: Icon(Icons.shield_outlined, size: 250, color: Colors.white.withOpacity(0.05))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildField('Mật khẩu hiện tại', _oldPassCtrl, _oldVisible, () => setState(() => _oldVisible = !_oldVisible)),
                  _buildField('Mật khẩu mới', _newPassCtrl, _newVisible, () => setState(() => _newVisible = !_newVisible)),
                  _buildField('Xác nhận mật khẩu mới', _confirmCtrl, _confirmVisible, () => setState(() => _confirmVisible = !_confirmVisible)),
                  
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
                        : const Text('Thay Đổi', style: TextStyle(color: Color(0xFFB71C1C), fontSize: 16, fontWeight: FontWeight.bold)),
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
