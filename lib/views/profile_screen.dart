import 'package:flutter/material.dart';
import 'package:greeting_project/models/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.red[50],
                child: const Text('NV', style: TextStyle(fontSize: 32, color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              const Text('Nguyễn Văn A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Chúc mừng năm mới 2026!', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              // Bảng thống kê
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    // Lắng nghe sự thay đổi của appState
                    ListenableBuilder(
                      listenable: appState,
                      builder: (context, child) {
                        return _buildStatRow('TIẾN ĐỘ LỜI CHÚC', '${appState.greetedContacts}/${appState.totalContacts}', Colors.red);
                      },
                    ),
                    const Divider(height: 30),
                    _buildStatRow('NGÀY CÒN LẠI ĐẾN TẾT', '6 Days', Colors.amber[700]!),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 12)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor, fontSize: 18)),
      ],
    );
  }
}