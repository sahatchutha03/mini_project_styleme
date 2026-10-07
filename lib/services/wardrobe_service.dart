import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/outfit_model.dart';

class WardrobeService {
  static String get wardrobeUrl => '${ApiConfig.baseUrl}/api/wardrobe';

  /// ดึงชุดเสื้อผ้าทั้งหมดในตู้ของผู้ใช้
  Future<List<Outfit>> getWardrobe(String token) async {
    final response = await http
        .get(
          Uri.parse(wardrobeUrl),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data['data'] as List? ?? []);
      return list.map((item) => Outfit.fromJson(item as Map<String, dynamic>)).toList();
    }

    throw Exception('ไม่สามารถดึงข้อมูลตู้เสื้อผ้าได้ (${response.statusCode})');
  }

  /// บันทึกชุดลงตู้เสื้อผ้า
  Future<bool> saveToWardrobe(int outfitId, String token) async {
    final response = await http
        .post(
          Uri.parse(wardrobeUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'outfitId': outfitId}),
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    return data['status'] == 'ok';
  }

  /// ลบชุดออกจากตู้เสื้อผ้า
  Future<bool> removeFromWardrobe(int outfitId, String token) async {
    final response = await http
        .delete(
          Uri.parse('$wardrobeUrl/$outfitId'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    return data['status'] == 'ok';
  }

  /// ตรวจสอบว่าชุดนี้อยู่ในตู้หรือไม่
  Future<bool> checkIsSaved(int outfitId, String token) async {
    final response = await http
        .get(
          Uri.parse('$wardrobeUrl/check/$outfitId'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isSaved'] == true;
    }
    return false;
  }
}
