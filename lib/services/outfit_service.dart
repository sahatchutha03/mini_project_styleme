import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/outfit_model.dart';

class OutfitService {
  /// กรองข้อมูลและรับรายการเสื้อผ้าที่แมทช์กันจากฐานข้อมูล styleme_app ผ่าน API
  Future<List<Outfit>> getMatchedOutfits({
    String? bodyShape,
    String? occasion,
    String? colorCategory,
  }) async {
    final queryParams = {
      if (bodyShape != null && bodyShape.isNotEmpty && bodyShape != 'All') 'bodyShape': bodyShape,
      if (occasion != null && occasion.isNotEmpty && occasion != 'All') 'occasion': occasion,
      if (colorCategory != null && colorCategory.isNotEmpty && colorCategory != 'All') 'color': colorCategory,
    };

    final uri = Uri.parse(ApiConfig.outfits).replace(queryParameters: queryParams);
    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data is List) ? data : (data['data'] as List? ?? []);
      return list.map((item) => Outfit.fromJson(item as Map<String, dynamic>)).toList();
    }

    throw Exception('ไม่สามารถดึงข้อมูลชุดเสื้อผ้าจากฐานข้อมูลได้ (${response.statusCode})');
  }

  /// ดึงรายละเอียดชุดเดี่ยวและ Styling Tips จากฐานข้อมูล
  Future<Outfit> getOutfitDetail(int id, {String? bodyShape}) async {
    final uri = Uri.parse(ApiConfig.outfitDetail(id)).replace(
      queryParameters: bodyShape != null ? {'bodyShape': bodyShape} : null,
    );
    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Outfit.fromJson(data['data'] ?? data);
    }

    throw Exception('ไม่สามารถดึงรายละเอียดชุดจากฐานข้อมูลได้');
  }

  /// เพิ่มชุดเสื้อผ้าใหม่ (Admin)
  Future<Outfit> createOutfit(String token, Map<String, dynamic> data) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.outfits),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 10));

    final resData = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Outfit.fromJson(resData['data']);
    }

    throw Exception(resData['message']?.toString() ?? 'เพิ่มชุดเสื้อผ้าไม่สำเร็จ');
  }

  /// แก้ไขข้อมูลชุดเสื้อผ้า (Admin)
  Future<Outfit> updateOutfit(String token, int id, Map<String, dynamic> data) async {
    final response = await http
        .put(
          Uri.parse(ApiConfig.outfitDetail(id)),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 10));

    final resData = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return Outfit.fromJson(resData['data']);
    }

    throw Exception(resData['message']?.toString() ?? 'แก้ไขชุดเสื้อผ้าไม่สำเร็จ');
  }

  /// ลบชุดเสื้อผ้า (Admin)
  Future<void> deleteOutfit(String token, int id) async {
    final response = await http
        .delete(
          Uri.parse(ApiConfig.outfitDetail(id)),
          headers: {
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return;
    }

    final resData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(resData['message']?.toString() ?? 'ลบชุดเสื้อผ้าไม่สำเร็จ');
  }
}
