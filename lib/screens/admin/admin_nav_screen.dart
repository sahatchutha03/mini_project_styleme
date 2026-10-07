import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'admin_profile_screen.dart';

class AdminNavScreen extends StatefulWidget {
  const AdminNavScreen({super.key});

  @override
  State<AdminNavScreen> createState() => _AdminNavScreenState();
}

class _AdminNavScreenState extends State<AdminNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboardScreen(showBackButton: false),
    AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        elevation: 3,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune, color: AppTheme.primaryColor),
            label: 'ส่วนควบคุมระบบ (Control)',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle, color: AppTheme.primaryColor),
            label: 'ประวัติส่วนตัว (Profile)',
          ),
        ],
      ),
    );
  }
}
