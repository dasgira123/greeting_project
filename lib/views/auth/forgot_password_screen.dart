import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/implementations/api/auth_api.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  final _api = AuthApi();
  bool _isLoading = false;

  int _step = 0; // 0: Phone, 1: OTP, 2: New Password
  String _generatedOtp = '';
  String _confirmedPhone = '';
  bool _isPasswordVisible = false;

  Timer? _timer;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
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
        content: Text('SMS: Mã OTP của bạn là $_generatedOtp', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 15),
        action: SnackBarAction(label: 'ĐÓNG', textColor: Colors.white, onPressed: () {}),
      ),
    );
  }

  void _onSendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số điện thoại')));
      return;
    }
    
    setState(() => _isLoading = true);
    final exists = await _api.checkPhoneExists(phone);
    setState(() => _isLoading = false);

    if (exists && mounted) {
      _confirmedPhone = phone;
      _generatedOtp = (Random().nextInt(900000) + 100000).toString();
      setState(() => _step = 1);
      _startResendTimer();
      
      // Giả lập gửi SMS
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SMS: Mã OTP của bạn là $_generatedOtp', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 15),
          action: SnackBarAction(label: 'ĐÓNG', textColor: Colors.white, onPressed: () {}),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại không tồn tại trong hệ thống!'), backgroundColor: Colors.red),
      );
    }
  }

  void _onVerifyOtp() {
    if (_otpCtrl.text.trim() == _generatedOtp) {
      setState(() => _step = 2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã OTP không chính xác!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    }
  }

  void _onResetPassword() async {
    final newPass = _newPassCtrl.text;
    if (newPass.isEmpty || _confirmPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền mật khẩu!')));
      return;
    }
    if (newPass != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu xác nhận không khớp!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    final success = await _api.resetPassword(_confirmedPhone, newPass);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công! Bạn có thể đăng nhập ngay.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText && !_isPasswordVisible,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
         hintText: hint,
         hintStyle: const TextStyle(color: Colors.white54),
         prefixIcon: Icon(icon, color: Colors.amber),
         suffixIcon: obscureText 
            ? IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
         filled: true,
         fillColor: Colors.black.withOpacity(0.2),
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC62828),
      appBar: AppBar(
        title: const Text('Quên Mật Khẩu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(bottom: -50, right: -50, child: Icon(Icons.shield_outlined, size: 250, color: Colors.white.withOpacity(0.05))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    if (_step == 0) {
      return Column(
        children: [
          const SizedBox(height: 32),
          const Text('Nhập số điện thoại đã đăng ký, hệ thống sẽ gửi OTP dạng 6 số qua SMS cho bạn.', style: TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          _buildTextField('Số điện thoại', Icons.phone_android, _phoneCtrl, keyboardType: TextInputType.phone),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _onSendOtp,
              child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.red))
                : const Text('Gửi OTP', style: TextStyle(color: Color(0xFFB71C1C), fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      );
    } else if (_step == 1) {
      return Column(
        children: [
          const SizedBox(height: 32),
          Text('Một mã OTP đã được gửi đến:\n$_confirmedPhone', style: const TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          _buildTextField('Mã OTP (6 chữ số)', Icons.lock_clock, _otpCtrl, keyboardType: TextInputType.number),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _onVerifyOtp,
              child: const Text('Xác minh', style: TextStyle(color: Color(0xFFB71C1C), fontSize: 16, fontWeight: FontWeight.bold)),
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
        ],
      );
    } else {
      return Column(
        children: [
          const SizedBox(height: 32),
          const Text('Nhập mật khẩu mới cho tài khoản của bạn.', style: TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          _buildTextField('Mật khẩu mới', Icons.lock, _newPassCtrl, obscureText: true),
          const SizedBox(height: 16),
          _buildTextField('Xác nhận mật khẩu', Icons.lock_outline, _confirmPassCtrl, obscureText: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _onResetPassword,
              child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                : const Text('Thay đổi mật khẩu', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      );
    }
  }
}
