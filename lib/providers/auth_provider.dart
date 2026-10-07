import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'styleme_jwt_token';
  static const _userKey = 'styleme_user_info';

  final AuthService authService;

  String? token;
  User? user;
  bool isLoading = false;
  String? errorMessage;

  AuthProvider({required this.authService});

  bool get isAuthenticated => token != null && token!.isNotEmpty;
  bool get isAdmin => user?.isAdmin ?? false;

  /// คืนค่า Session จาก SharedPreferences เมื่อเปิดแอป
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);
    final savedUserJson = prefs.getString(_userKey);

    if (savedToken != null && savedUserJson != null) {
      token = savedToken;
      try {
        user = User.fromJson(jsonDecode(savedUserJson) as Map<String, dynamic>);
      } catch (_) {}
      notifyListeners();
    }
  }

  /// เข้าสู่ระบบ
  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await authService.login(email: email, password: password);
      token = res['token'];
      user = res['user'];

      await _saveSession();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// สมัครสมาชิกใหม่
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String defaultBodyShape,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await authService.register(
        email: email,
        password: password,
        fullName: fullName,
        defaultBodyShape: defaultBodyShape,
      );

      token = res['token'];
      user = res['user'];

      await _saveSession();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ออกจากระบบ
  Future<void> logout() async {
    token = null;
    user = null;
    errorMessage = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// อัปเดตข้อมูลส่วนตัวของผู้ใช้ (ชื่อ, รูปร่าง) และบันทึกลง MySQL
  Future<bool> updateProfile(String fullName, String defaultBodyShape) async {
    if (token == null) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await authService.updateProfile(
        token: token!,
        fullName: fullName,
        defaultBodyShape: defaultBodyShape,
      );

      user = updatedUser;
      await _saveSession();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSession() async {
    if (token == null || user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token!);
    await prefs.setString(_userKey, jsonEncode(user!.toJson()));
  }
}
