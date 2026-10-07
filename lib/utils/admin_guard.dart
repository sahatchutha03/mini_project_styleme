import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

/// ฟังก์ชันปฏิเสธการเข้าถึงส่วน Admin และเด้งผู้ใช้กลับหน้า Login ทันที
Future<void> rejectAndRedirectToLogin(
  BuildContext context, {
  String message = 'ไม่สามารถเข้าใช้งานในส่วนนี้ได้',
}) async {
  final auth = Provider.of<AuthProvider>(context, listen: false);

  // ล็อกเอาท์ผู้ใช้เพื่อความปลอดภัย ล้าง Session ทั้งหมด
  await auth.logout();

  if (!context.mounted) return;

  // แจ้งเตือนข้อความปฏิเสธการเข้าถึง
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.block, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.dangerColor,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  // เด้งกลับไปยังหน้า Login ทันที และล้าง History ของ Route ทั้งหมด
  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => LoginScreen(accessDeniedMessage: message),
    ),
    (route) => false,
  );
}

/// Widget สำหรับครอบ Screen Admin (Route Guard) เพื่อป้องกันไม่ให้ผู้ใช้ทั่วไปเข้าถึงได้
class AdminGuard extends StatefulWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  State<AdminGuard> createState() => _AdminGuardState();
}

class _AdminGuardState extends State<AdminGuard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (!auth.isAdmin) {
        rejectAndRedirectToLogin(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAdmin) {
      // แสดงหน้าปฏิเสธการเข้าถึงเพื่อความปลอดภัย ไม่แสดงข้อมูล Admin ใดๆ
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.gpp_bad_rounded, size: 72, color: AppTheme.dangerColor),
                SizedBox(height: 16),
                Text(
                  'ไม่สามารถเข้าใช้งานในส่วนนี้ได้',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dangerColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'เฉพาะผู้ดูแลระบบ (Admin) เท่านั้น กำลังนำคุณกลับไปหน้าเข้าสู่ระบบ...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
