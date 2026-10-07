import 'package:flutter/foundation.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService adminService;

  Map<String, dynamic>? stats;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> luckyColors = [];

  bool isLoadingStats = false;
  bool isLoadingUsers = false;
  bool isLoadingColors = false;
  bool isOperating = false;
  String? errorMessage;

  AdminProvider({required this.adminService});

  /// โหลดข้อมูลภาพรวมระบบ (Dashboard Metrics)
  Future<void> fetchStats(String? token) async {
    if (token == null) return;
    isLoadingStats = true;
    errorMessage = null;
    notifyListeners();

    try {
      stats = await adminService.getDashboardStats(token);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingStats = false;
      notifyListeners();
    }
  }

  /// โหลดรายชื่อผู้ใช้งานทั้งหมด
  Future<void> fetchUsers(String? token, {String? search}) async {
    if (token == null) return;
    isLoadingUsers = true;
    errorMessage = null;
    notifyListeners();

    try {
      users = await adminService.getAllUsers(token, search: search);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingUsers = false;
      notifyListeners();
    }
  }

  /// สลับหรือเปลี่ยนบทบาทของผู้ใช้งาน
  Future<bool> toggleUserRole(String? token, int userId, String currentRole) async {
    if (token == null) return false;
    isOperating = true;
    errorMessage = null;
    notifyListeners();

    final newRole = currentRole == 'admin' ? 'user' : 'admin';
    try {
      await adminService.updateUserRole(token, userId, newRole);
      final idx = users.indexWhere((u) => u['id'] == userId);
      if (idx != -1) {
        users[idx]['role'] = newRole;
      }
      // Re-fetch stats to update totalAdmins count
      fetchStats(token);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isOperating = false;
      notifyListeners();
    }
  }

  /// ลบผู้ใช้งานออกจากระบบ
  Future<bool> deleteUser(String? token, int userId) async {
    if (token == null) return false;
    isOperating = true;
    errorMessage = null;
    notifyListeners();

    try {
      await adminService.deleteUser(token, userId);
      users.removeWhere((u) => u['id'] == userId);
      fetchStats(token);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isOperating = false;
      notifyListeners();
    }
  }

  /// โหลดข้อมูลสีมงคลทั้ง 7 วัน
  Future<void> fetchLuckyColors(String? token) async {
    if (token == null) return;
    isLoadingColors = true;
    errorMessage = null;
    notifyListeners();

    try {
      luckyColors = await adminService.getAllLuckyColors(token);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingColors = false;
      notifyListeners();
    }
  }

  /// แก้ไขข้อมูลสีมงคล
  Future<bool> updateLuckyColor(String? token, int id, Map<String, dynamic> data) async {
    if (token == null) return false;
    isOperating = true;
    errorMessage = null;
    notifyListeners();

    try {
      await adminService.updateLuckyColor(token, id, data);
      await fetchLuckyColors(token);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isOperating = false;
      notifyListeners();
    }
  }

  /// ตรวจสอบและจัดระเบียบฐานข้อมูล (Cleanup Orphans)
  Future<Map<String, dynamic>?> cleanupSystem(String? token) async {
    if (token == null) return null;
    isOperating = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await adminService.cleanSystemOrphans(token);
      await fetchStats(token);
      return res;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isOperating = false;
      notifyListeners();
    }
  }
}
