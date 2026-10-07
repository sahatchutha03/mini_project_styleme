import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AdminService {
  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// ดึงข้อมูลสถิติภาพรวมและการทำงานของระบบ
  Future<Map<String, dynamic>> getDashboardStats(String token) async {
    final response = await http
        .get(Uri.parse(ApiConfig.adminStats), headers: _headers(token))
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['status'] == 'ok') {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['message']?.toString() ?? 'ดึงข้อมูลสถิติไม่สำเร็จ');
  }

  /// ดึงรายชื่อผู้ใช้งานทั้งหมดในระบบ
  Future<List<Map<String, dynamic>>> getAllUsers(String token, {String? search}) async {
    final uri = Uri.parse(ApiConfig.adminUsers).replace(
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    final response = await http.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['status'] == 'ok') {
      final list = data['data'] as List? ?? [];
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    throw Exception(data['message']?.toString() ?? 'ดึงรายชื่อผู้ใช้ไม่สำเร็จ');
  }

  /// เปลี่ยนบทบาทของผู้ใช้งาน (admin / user)
  Future<void> updateUserRole(String token, int userId, String role) async {
    final response = await http
        .put(
          Uri.parse(ApiConfig.adminUserRole(userId)),
          headers: _headers(token),
          body: jsonEncode({'role': role}),
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['message']?.toString() ?? 'เปลี่ยนบทบาทผู้ใช้ไม่สำเร็จ');
    }
  }

  /// ลบผู้ใช้งานออกจากระบบ
  Future<void> deleteUser(String token, int userId) async {
    final response = await http
        .delete(Uri.parse(ApiConfig.adminDeleteUser(userId)), headers: _headers(token))
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['message']?.toString() ?? 'ลบผู้ใช้ไม่สำเร็จ');
    }
  }

  /// ดึงข้อมูลสีมงคลทั้ง 7 วัน
  Future<List<Map<String, dynamic>>> getAllLuckyColors(String token) async {
    final response = await http
        .get(Uri.parse(ApiConfig.adminLuckyColors), headers: _headers(token))
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['status'] == 'ok') {
      final list = data['data'] as List? ?? [];
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    throw Exception(data['message']?.toString() ?? 'ดึงข้อมูลสีมงคลไม่สำเร็จ');
  }

  /// แก้ไขข้อมูลสีมงคลประจำวัน
  Future<void> updateLuckyColor(String token, int id, Map<String, dynamic> updateData) async {
    final response = await http
        .put(
          Uri.parse(ApiConfig.adminLuckyColor(id)),
          headers: _headers(token),
          body: jsonEncode(updateData),
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['message']?.toString() ?? 'แก้ไขข้อมูลสีมงคลไม่สำเร็จ');
    }
  }

  /// ตรวจสอบและทำความสะอาด จัดระเบียบฐานข้อมูล (Cleanup Orphans)
  Future<Map<String, dynamic>> cleanSystemOrphans(String token) async {
    final response = await http
        .post(Uri.parse(ApiConfig.adminCleanup), headers: _headers(token))
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['status'] == 'ok') {
      return data;
    }
    throw Exception(data['message']?.toString() ?? 'จัดระเบียบฐานข้อมูลไม่สำเร็จ');
  }
}
