import 'package:flutter/foundation.dart';
import '../models/lucky_color_model.dart';
import '../services/lucky_color_service.dart';

class LuckyColorProvider extends ChangeNotifier {
  final LuckyColorService luckyColorService;

  DailyLuckyColor? todayColors;
  bool isLoading = false;
  String? errorMessage;

  LuckyColorProvider({required this.luckyColorService});

  /// ดึงข้อมูลสีมงคลประจำวันจาก API ทันที
  Future<void> fetchTodayLuckyColors() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      todayColors = await luckyColorService.getTodayLuckyColors();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
