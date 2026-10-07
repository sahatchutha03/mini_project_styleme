import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Base URL สำหรับเชื่อมต่อ Backend serverapi_ts
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 สำหรับ Android Emulator เชื่อมต่อเครื่อง Host
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  // Endpoints
  static String get register => '$baseUrl/api/auth/register';
  static String get login => '$baseUrl/api/auth/login';
  static String get profile => '$baseUrl/api/auth/profile';
  static String get todayLuckyColors => '$baseUrl/api/lucky-colors/today';
  static String get luckyColorsAll => '$baseUrl/api/lucky-colors';
  static String get outfits => '$baseUrl/api/outfits';
  static String outfitDetail(int id) => '$baseUrl/api/outfits/$id';

  // Admin Endpoints
  static String get adminStats => '$baseUrl/api/admin/stats';
  static String get adminUsers => '$baseUrl/api/admin/users';
  static String adminUserRole(int id) => '$baseUrl/api/admin/users/$id/role';
  static String adminDeleteUser(int id) => '$baseUrl/api/admin/users/$id';
  static String get adminLuckyColors => '$baseUrl/api/admin/lucky-colors';
  static String adminLuckyColor(int id) => '$baseUrl/api/admin/lucky-colors/$id';
  static String get adminCleanup => '$baseUrl/api/admin/system/cleanup';
}
