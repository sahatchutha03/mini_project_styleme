import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:min_project_styleme/models/user_model.dart';
import 'package:min_project_styleme/providers/auth_provider.dart';
import 'package:min_project_styleme/services/auth_service.dart';
import 'package:min_project_styleme/utils/admin_guard.dart';
import 'package:min_project_styleme/screens/auth/login_screen.dart';
import 'package:min_project_styleme/screens/admin/admin_nav_screen.dart';
import 'package:min_project_styleme/providers/admin_provider.dart';
import 'package:min_project_styleme/services/admin_service.dart';
import 'package:min_project_styleme/providers/outfit_provider.dart';
import 'package:min_project_styleme/services/outfit_service.dart';
import 'package:min_project_styleme/providers/theme_provider.dart';
import 'package:min_project_styleme/providers/style_filter_provider.dart';

void main() {
  group('Admin System Tests', () {
    test('User model identifies admin role correctly', () {
      final adminUser = User(
        id: 1,
        email: 'admin@styleme.com',
        fullName: 'Admin User',
        role: 'admin',
      );

      final normalUser = User(
        id: 2,
        email: 'user@styleme.com',
        fullName: 'Normal User',
        role: 'user',
      );

      expect(adminUser.isAdmin, isTrue);
      expect(normalUser.isAdmin, isFalse);
    });

    test('User fromJson parses role correctly and defaults to user', () {
      final jsonAdmin = {
        'id': 10,
        'email': 'admin2@styleme.com',
        'fullName': 'Admin Two',
        'defaultBodyShape': 'Hourglass',
        'role': 'admin',
      };

      final parsedAdmin = User.fromJson(jsonAdmin);
      expect(parsedAdmin.isAdmin, isTrue);
      expect(parsedAdmin.role, equals('admin'));

      final jsonNormal = {
        'id': 11,
        'email': 'normal@styleme.com',
        'fullName': 'Normal Person',
      };

      final parsedNormal = User.fromJson(jsonNormal);
      expect(parsedNormal.isAdmin, isFalse);
      expect(parsedNormal.role, equals('user'));
    });

    test('User toJson preserves role field', () {
      final user = User(
        id: 99,
        email: 'test@styleme.com',
        fullName: 'Test Admin',
        role: 'admin',
      );

      final json = user.toJson();
      expect(json['role'], equals('admin'));
    });

    testWidgets('AdminGuard blocks non-admin and shows access denied message', (WidgetTester tester) async {
      final authProvider = AuthProvider(authService: AuthService());
      authProvider.user = User(
        id: 2,
        email: 'normal@test.com',
        fullName: 'Normal User',
        role: 'user',
      );
      authProvider.token = 'mock-user-token';

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(
            home: AdminGuard(
              child: Text('Protected Admin Content'),
            ),
          ),
        ),
      );

      // Should show access denied message and not show admin content
      expect(find.text('ไม่สามารถเข้าใช้งานในส่วนนี้ได้'), findsOneWidget);
      expect(find.text('Protected Admin Content'), findsNothing);
    });

    testWidgets('AdminGuard allows admin user to access content', (WidgetTester tester) async {
      final authProvider = AuthProvider(authService: AuthService());
      authProvider.user = User(
        id: 1,
        email: 'admin@test.com',
        fullName: 'Admin User',
        role: 'admin',
      );
      authProvider.token = 'mock-admin-token';

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(
            home: AdminGuard(
              child: Text('Protected Admin Content'),
            ),
          ),
        ),
      );

      expect(find.text('Protected Admin Content'), findsOneWidget);
      expect(find.text('ไม่สามารถเข้าใช้งานในส่วนนี้ได้'), findsNothing);
    });

    testWidgets('LoginScreen displays access denied banner when redirected', (WidgetTester tester) async {
      final authProvider = AuthProvider(authService: AuthService());

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(
            home: LoginScreen(
              accessDeniedMessage: 'ไม่สามารถเข้าใช้งานในส่วนนี้ได้',
            ),
          ),
        ),
      );

      // Should display warning banner
      expect(find.text('ไม่สามารถเข้าใช้งานในส่วนนี้ได้'), findsOneWidget);
    });

    testWidgets('AdminNavScreen displays only control center and admin profile without consumer tabs', (WidgetTester tester) async {
      final authProvider = AuthProvider(authService: AuthService());
      authProvider.user = User(
        id: 1,
        email: 'admin@styleme.com',
        fullName: 'Admin User',
        role: 'admin',
      );
      authProvider.token = 'mock-admin-token';

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider(adminService: AdminService())),
            ChangeNotifierProvider<OutfitProvider>(create: (_) => OutfitProvider(outfitService: OutfitService())),
            ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
            ChangeNotifierProvider<StyleFilterProvider>(create: (_) => StyleFilterProvider()),
          ],
          child: const MaterialApp(
            home: AdminNavScreen(),
          ),
        ),
      );

      // Verify Admin navigation bar items
      expect(find.text('ส่วนควบคุมระบบ (Control)'), findsOneWidget);
      expect(find.text('ประวัติส่วนตัว (Profile)'), findsOneWidget);

      // Verify that consumer user tabs do NOT exist
      expect(find.text('หน้าแรก'), findsNothing);
      expect(find.text('แมทช์สไตล์'), findsNothing);
      expect(find.text('ตู้เสื้อผ้า'), findsNothing);
    });
  });
}
