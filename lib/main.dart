import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'services/auth_service.dart';
import 'services/lucky_color_service.dart';
import 'services/outfit_service.dart';
import 'services/wardrobe_service.dart';
import 'services/admin_service.dart';

import 'providers/auth_provider.dart';
import 'providers/lucky_color_provider.dart';
import 'providers/style_filter_provider.dart';
import 'providers/outfit_provider.dart';
import 'providers/wardrobe_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/admin_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/main_nav_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_outfit_form_screen.dart';
import 'screens/admin/admin_nav_screen.dart';
import 'utils/admin_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StyleMeApp());
}

class StyleMeApp extends StatelessWidget {
  const StyleMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<LuckyColorService>(create: (_) => LuckyColorService()),
        Provider<OutfitService>(create: (_) => OutfitService()),
        Provider<WardrobeService>(create: (_) => WardrobeService()),
        Provider<AdminService>(create: (_) => AdminService()),

        // Providers (State Management)
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(
            authService: ctx.read<AuthService>(),
          )..restoreSession(),
        ),
        ChangeNotifierProvider<LuckyColorProvider>(
          create: (ctx) => LuckyColorProvider(
            luckyColorService: ctx.read<LuckyColorService>(),
          ),
        ),
        ChangeNotifierProvider<StyleFilterProvider>(
          create: (_) => StyleFilterProvider(),
        ),
        ChangeNotifierProvider<OutfitProvider>(
          create: (ctx) => OutfitProvider(
            outfitService: ctx.read<OutfitService>(),
          ),
        ),
        ChangeNotifierProvider<WardrobeProvider>(
          create: (ctx) => WardrobeProvider(
            wardrobeService: ctx.read<WardrobeService>(),
          ),
        ),
        ChangeNotifierProvider<AdminProvider>(
          create: (ctx) => AdminProvider(
            adminService: ctx.read<AdminService>(),
          ),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, child) {
          return MaterialApp(
            title: 'StyleMe: The Perfect Fit',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProv.themeMode,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/admin': (context) => const AdminGuard(child: AdminDashboardScreen()),
              '/admin/dashboard': (context) => const AdminGuard(child: AdminDashboardScreen()),
              '/admin/outfit': (context) => const AdminGuard(child: AdminOutfitFormScreen()),
            },
          );
        },
      ),
    );
  }
}

/// Widget สำหรับตรวจสอบสถานะ Auth State (JWT Token)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // ถ้ามี JWT Token ใน State
    // - ถ้าเป็น Admin: แสดงหน้าจอสำหรับ Admin โดยเฉพาะ (ส่วนควบคุม เพิ่ม/ลบ/แก้ไข และ ประวัติส่วนตัว โปรไฟล์)
    // - ถ้าเป็น User: แสดงหน้าจอสำหรับผู้ใช้ทั่วไป (หน้าแรก, แมทช์สไตล์, ตู้เสื้อผ้า, โปรไฟล์)
    if (auth.isAuthenticated) {
      if (auth.isAdmin) {
        return const AdminNavScreen();
      }
      return const MainNavScreen();
    }

    return const LoginScreen();
  }
}
