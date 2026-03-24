import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/register_viewmodel.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../home/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  int _step = 0;
  String _generatedOtp = '';

  Timer? _timer;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendCooldown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOtp() {
    if (_resendCooldown > 0) return;
    _generatedOtp = (Random().nextInt(900000) + 100000).toString();
    _startResendTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SMS: Mã OTP đăng ký của bạn là $_generatedOtp', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 15),
        action: SnackBarAction(label: 'ĐÓNG', textColor: Colors.white, onPressed: () {}),
      ),
    );
  }

  void _onSendOtp() async {
    final viewModel = context.read<RegisterViewModel>();
    viewModel.setFullName(_nameCtrl.text);
    viewModel.setPhone(_phoneCtrl.text);
    viewModel.setPassword(_passCtrl.text);
    viewModel.setConfirmPassword(_confirmCtrl.text);
    
    final isValid = await viewModel.checkBeforeOtp();
    if (isValid && mounted) {
      _generatedOtp = (Random().nextInt(900000) + 100000).toString();
      setState(() => _step = 1);
      _startResendTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SMS: Mã OTP đăng ký của bạn là $_generatedOtp', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 15),
          action: SnackBarAction(label: 'ĐÓNG', textColor: Colors.white, onPressed: () {}),
        ),
      );
    } else if (viewModel.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!), backgroundColor: Colors.red),
      );
    }
  }

  void _onRegisterFinal() async {
    if (_otpCtrl.text.trim() == _generatedOtp) {
       final viewModel = context.read<RegisterViewModel>();
       final success = await viewModel.register();
       if (success && mounted) {
          await context.read<AuthViewModel>().refreshAuth();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng ký thành công!'), backgroundColor: Colors.green),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
       } else if (viewModel.errorMessage != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(viewModel.errorMessage!), backgroundColor: Colors.red),
          );
       }
    } else {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã OTP không chính xác!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    }
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isPassword = false, bool isVisible = true, VoidCallback? onToggleVisibility, IconData? suffixIcon, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword && !isVisible,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType ?? (label.contains('THOẠI') ? TextInputType.phone : TextInputType.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: onToggleVisibility != null 
              ? IconButton(icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white54), onPressed: onToggleVisibility)
              : (suffixIcon != null ? Icon(suffixIcon, color: Colors.white54) : null),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFB71C1C), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_step == 1) {
               setState(() => _step = 0);
            } else {
               Navigator.pop(context);
            }
          },
        ),
        title: const Text('Tết Đoàn Viên', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: _step == 0 ? _buildInputForm(viewModel) : _buildOtpForm(viewModel),
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm(RegisterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            'Tạo tài khoản mới',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Chào mừng bạn đến với hội xuân 2026',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        const SizedBox(height: 32),

        _buildInputField('Họ và tên', _nameCtrl, suffixIcon: Icons.person),
        _buildInputField('Số điện thoại', _phoneCtrl, suffixIcon: Icons.phone),
        _buildInputField(
          'Mật khẩu', _passCtrl, 
          isPassword: true, 
          isVisible: viewModel.isPasswordVisible, 
          onToggleVisibility: viewModel.togglePasswordVisibility,
        ),
        _buildInputField(
          'Xác nhận mật khẩu', _confirmCtrl, 
          isPassword: true, 
          isVisible: viewModel.isConfirmPasswordVisible, 
          onToggleVisibility: viewModel.toggleConfirmPasswordVisibility,
        ),

        const SizedBox(height: 24),
        
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFB300)]),
            boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ElevatedButton(
            onPressed: viewModel.isLoading ? null : _onSendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: viewModel.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.deepOrange, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Tiếp tục (Nhận OTP)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C))),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Color(0xFFB71C1C), size: 18),
                    ],
                  ),
          ),
        ),
        
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Đã có tài khoản? ', style: TextStyle(color: Colors.white70)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('Đăng nhập', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpForm(RegisterViewModel viewModel) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            'Xác minh Số điện thoại',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'SMS chứa mã OTP 6 số đã được gửi tới ${_phoneCtrl.text}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),

        _buildInputField('Mã OTP', _otpCtrl, suffixIcon: Icons.lock_clock, keyboardType: TextInputType.number),

        const SizedBox(height: 24),
        
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(colors: [Color(0xFF81C784), Color(0xFF43A047)]),
            boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ElevatedButton(
            onPressed: viewModel.isLoading ? null : _onRegisterFinal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: viewModel.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Xác minh và Kích hoạt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.check_circle, color: Colors.white, size: 18),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _resendCooldown > 0 ? null : _resendOtp,
          child: Text(
            _resendCooldown > 0 ? 'Gửi lại OTP sau ${_resendCooldown}s' : 'Gửi lại mã OTP',
            style: TextStyle(
              color: _resendCooldown > 0 ? Colors.white54 : Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ]
     );
  }
}
