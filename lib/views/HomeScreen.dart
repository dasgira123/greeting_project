import 'package:flutter/material.dart';
import 'package:greeting_project/models/app_state.dart';
import 'templates_screen.dart';
import 'profile_screen.dart';
import 'contact_detail_screen.dart'; // File số 5 bên dưới



class TetGreetingApp extends StatelessWidget {
  const TetGreetingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tết Greeting',
      theme: ThemeData(
        primaryColor: const Color(0xFFD32F2F),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TemplatesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.calendar_today, color: Colors.amber),
            SizedBox(width: 8),
            Text('Tết Greeting', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: const Text('NV', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFD32F2F),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'TEMPLATES'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    );
  }
}

// ---- HOME SCREEN ----
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Called' ? Colors.green : (status == 'Messaged' ? Colors.blue : Colors.grey);
    IconData icon = status == 'Called' ? Icons.phone_in_talk : (status == 'Messaged' ? Icons.message : Icons.access_time);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: appState,
        builder: (context, child) {
          double progress = appState.totalContacts == 0 ? 0 : appState.greetedContacts / appState.totalContacts;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Thẻ Tiến độ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Năm Mới Sum Vầy!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                          child: Text('${appState.greetedContacts}/${appState.totalContacts} greeted', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Gửi đi lời chúc, nhận lại niềm vui. Hãy lan tỏa yêu thương trong dịp Tết này!', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Thanh Tìm kiếm (Chỉ là UI minh họa)
              TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm trong danh bạ...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // Danh sách
              const Text('Danh Bạ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 10),
              ...appState.contacts.map((contact) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ContactDetailScreen(contact: contact)));
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[50],
                    child: const Icon(Icons.person_outline, color: Colors.orange),
                  ),
                  title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Align(alignment: Alignment.centerLeft, child: _buildStatusBadge(contact.status)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              )).toList(),
            ],
          );
        }
    );
  }
}