import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home/contact_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static int _getDaysUntilTet() {
    final lunarNewYears = [
      DateTime(2026, 2, 17),
      DateTime(2027, 2, 6),
      DateTime(2028, 1, 26),
      DateTime(2029, 2, 13),
      DateTime(2030, 2, 3),
    ];
    final today = DateTime.now();
    for (final tet in lunarNewYears) {
      final diff = tet.difference(DateTime(today.year, today.month, today.day)).inDays;
      if (diff >= 0) return diff;
    }
    return 0;
  }

  static int _nextTetYear() {
    final lunarNewYears = [
      DateTime(2026, 2, 17),
      DateTime(2027, 2, 6),
      DateTime(2028, 1, 26),
      DateTime(2029, 2, 13),
    ];
    final now = DateTime.now();
    for (final tet in lunarNewYears) {
      if (now.isBefore(tet)) return tet.year;
    }
    return DateTime.now().year + 1;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysUntilTet();
    final tetYear = _nextTetYear();
    final Color countdownColor = days == 0
        ? Colors.red
        : days <= 7
            ? const Color(0xFFD32F2F)
            : days <= 30
                ? Colors.orange
                : const Color(0xFFE67E22);

    return Scaffold(
      // Nền kem vàng chủ đề Tết — tách biệt rõ với header đỏ
      backgroundColor: const Color(0xFFFFF5E4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero header banner ────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 48, 0, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFF8B0000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Vòng trang trí vàng bên ngoài avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFDD835), width: 2.5),
                    ),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                      ),
                      child: Icon(Icons.person_outline, size: 46, color: Colors.white.withOpacity(0.85)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Khách',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  // Login button với viền vàng
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chức năng đăng nhập sẽ được thêm sau!')),
                      );
                    },
                    icon: const Icon(Icons.login, size: 15, color: Color(0xFFFDD835)),
                    label: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        color: Color(0xFFFDD835),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFDD835), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Stats cards ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Progress card
                  Consumer<ContactViewModel>(
                    builder: (context, vm, _) {
                      final total = vm.totalContacts;
                      final greeted = vm.greetedContacts;
                      final pct = total == 0 ? 0.0 : greeted / total;
                      return _statsCard(
                        icon: Icons.check_circle_outline,
                        iconColor: const Color(0xFF27AE60),
                        title: 'Tiến độ lời chúc',
                        value: '$greeted / $total người',
                        valueColor: const Color(0xFF27AE60),
                        bottom: Column(
                          children: [
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: Colors.grey[200],
                                color: const Color(0xFF27AE60),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${(pct * 100).toStringAsFixed(0)}% hoàn thành',
                                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Countdown card
                  _statsCard(
                    icon: Icons.celebration_outlined,
                    iconColor: countdownColor,
                    title: days == 0 ? 'Hôm nay là Tết!' : 'Đến Tết $tetYear',
                    value: days == 0 ? '🎉🎊' : '$days ngày',
                    valueColor: countdownColor,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
    Widget? bottom,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
              ),
              Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
            ],
          ),
          if (bottom != null) bottom,
        ],
      ),
    );
  }
}