import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  /// สมัครสมาชิกใหม่ (ยิงตรงไปยัง Backend serverapi_ts -> Database styleme_app)
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String defaultBodyShape,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.register),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'fullName': fullName,
              'defaultBodyShape': defaultBodyShape,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201 || data['status'] == 'ok') {
        return {
          'status': 'ok',
          'token': data['token'],
          'user': User.fromJson(data['user']),
        };
      }

      throw Exception(data['message']?.toString() ?? 'การสมัครสมาชิกล้มเหลว');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('หมดเวลาเชื่อมต่อ Server กรุณาตรวจสอบว่า Backend Server เปิดอยู่');
      }
      rethrow;
    }
  }

  /// เข้าสู่ระบบ (ยิงตรงไปยัง Backend serverapi_ts -> Database styleme_app)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || data['status'] == 'ok') {
        return {
          'status': 'ok',
          'token': data['token'],
          'user': User.fromJson(data['user']),
        };
      }

      throw Exception(data['message']?.toString() ?? 'เข้าสู่ระบบไม่สำเร็จ');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('หมดเวลาเชื่อมต่อ Server กรุณาตรวจสอบว่า Backend Server เปิดอยู่');
      }
      rethrow;
    }
  }

  /// ดึงข้อมูลโปรไฟล์ผู้ใช้ปัจจุบัน
  Future<User> getProfile(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.profile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['status'] == 'ok') {
      return User.fromJson(data['user']);
    }

    throw Exception(data['message']?.toString() ?? 'ไม่สามารถดึงข้อมูลโปรไฟล์ได้');
  }

  /// อัปเดตข้อมูลส่วนตัวของผู้ใช้ (ชื่อ, รูปร่าง) บันทึกลง MySQL
  Future<User> updateProfile({
    required String token,
    required String fullName,
    required String defaultBodyShape,
  }) async {
    final response = await http.put(
      Uri.parse(ApiConfig.profile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fullName': fullName,
        'bodyShape': defaultBodyShape,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['status'] == 'ok') {
      return User.fromJson(data['user']);
    }

    throw Exception(data['message']?.toString() ?? 'อัปเดตข้อมูลไม่สำเร็จ');
  }
}

