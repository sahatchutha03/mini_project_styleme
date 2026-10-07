import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/style_filter_provider.dart';
import '../config/app_theme.dart';

import 'home/home_screen.dart';
import 'style_matcher/style_matcher_screen.dart';
import 'wardrobe/wardrobe_screen.dart';
import 'profile/profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลตู้เสื้อผ้าตอนเข้าแอป
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null && auth.user!.defaultBodyShape.isNotEmpty) {
        context.read<StyleFilterProvider>().setBodyShape(auth.user!.defaultBodyShape);
      }
      context.read<WardrobeProvider>().fetchWardrobe(auth.token);
    });
  }

  final List<Widget> _pages = const [
    HomeScreen(),
    StyleMatcherScreen(),
    WardrobeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();

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
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.primaryColor),
            label: 'หน้าแรก',
          ),
          const NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
            label: 'แมทช์สไตล์',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('${wardrobe.count}'),
              isLabelVisible: wardrobe.count > 0,
              backgroundColor: AppTheme.secondaryColor,
              child: const Icon(Icons.checkroom_outlined),
            ),
            selectedIcon: Badge(
              label: Text('${wardrobe.count}'),
              isLabelVisible: wardrobe.count > 0,
              backgroundColor: AppTheme.secondaryColor,
              child: const Icon(Icons.checkroom, color: AppTheme.primaryColor),
            ),
            label: 'ตู้เสื้อผ้า',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryColor),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}
