import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/login_viewmodel.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../home/main_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final viewModel = context.read<LoginViewModel>();
    viewModel.setPhone(_phoneCtrl.text);
    viewModel.setPassword(_passCtrl.text);
    
    final success = await viewModel.login();
    if (success && mounted) {
      await context.read<AuthViewModel>().refreshAuth();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else if (viewModel.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg_login_tet.png', fit: BoxFit.cover),
          // Background decorations (mock lồng đèn, hoa mai)
          Positioned(
            top: -20, right: -40,
            child: Icon(Icons.wb_sunny, size: 200, color: Colors.yellow.withOpacity(0.1)),
          ),
          Positioned(
            bottom: -50, left: -50,
            child: Icon(Icons.celebration, size: 250, color: Colors.white.withOpacity(0.05)),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Chúc Mừng\nNăm Mới',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.amber,
                        height: 1.2,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tết Nguyên Đán 2026',
                      style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 40),

                    // Glassmorphism Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Số Điện Thoại', style: TextStyle(color: Colors.white, fontSize: 12)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: 'Nhập số điện thoại',
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.9),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              const Text('Mật Khẩu', style: TextStyle(color: Colors.white, fontSize: 12)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passCtrl,
                                obscureText: !viewModel.isPasswordVisible,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: 'Nhập mật khẩu',
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.9),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  suffixIcon: IconButton(
                                    icon: Icon(viewModel.isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                                    onPressed: viewModel.togglePasswordVisibility,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Nút Đăng nhập
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF8F00)]),
                                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: ElevatedButton(
                                  onPressed: viewModel.isLoading ? null : _onLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: viewModel.isLoading
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Đăng Nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B0000))),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24, width: 24,
                                        child: Checkbox(
                                          value: viewModel.rememberMe,
                                          onChanged: viewModel.toggleRememberMe,
                                          fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.amber : Colors.white),
                                          checkColor: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Ghi nhớ đăng nhập', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                                    child: const Text('Quên mật khẩu?', style: TextStyle(color: Colors.amber, fontSize: 13, decoration: TextDecoration.underline, decorationColor: Colors.amber)),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('hoặc', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                                  ),
                                  Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              const Center(child: Text('Chưa có tài khoản?', style: TextStyle(color: Colors.white, fontSize: 13))),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.amber, width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Đăng Ký Ngay', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
