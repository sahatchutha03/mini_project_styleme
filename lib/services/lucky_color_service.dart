import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/lucky_color_model.dart';

class LuckyColorService {
  /// ดึงข้อมูลสีมงคลประจำวันจากฐานข้อมูล styleme_app ผ่าน API
  Future<DailyLuckyColor> getTodayLuckyColors() async {
    final response = await http
        .get(
          Uri.parse(ApiConfig.todayLuckyColors),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return DailyLuckyColor.fromJson(data['data'] ?? data);
    }

    throw Exception('ไม่สามารถดึงข้อมูลสีมงคลจากเซิร์ฟเวอร์ได้ (${response.statusCode})');
  }

  /// ดึงข้อมูลสีมงคลครบทั้ง 7 วัน
  Future<List<DailyLuckyColor>> getAllLuckyColors() async {
    final response = await http
        .get(
          Uri.parse(ApiConfig.luckyColorsAll),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data is List) ? data : (data['data'] as List? ?? []);
      return list.map((item) => DailyLuckyColor.fromJson(item as Map<String, dynamic>)).toList();
    }

    throw Exception('ไม่สามารถดึงข้อมูลสีมงคลทั้งหมดได้');
  }
}
