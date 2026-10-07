import 'package:flutter/foundation.dart';
import '../models/outfit_model.dart';
import '../services/wardrobe_service.dart';

class WardrobeProvider extends ChangeNotifier {
  final WardrobeService wardrobeService;

  List<Outfit> savedOutfits = [];
  bool isLoading = false;
  String? errorMessage;

  WardrobeProvider({required this.wardrobeService});

  int get count => savedOutfits.length;

  bool isSaved(int outfitId) {
    return savedOutfits.any((o) => o.id == outfitId);
  }

  /// ดึงข้อมูลตู้เสื้อผ้าทั้งหมดจาก MySQL
  Future<void> fetchWardrobe(String? token) async {
    if (token == null) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      savedOutfits = await wardrobeService.getWardrobe(token);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// สลับสถานะ บันทึก/ลบ ชุดในตู้เสื้อผ้า
  Future<bool> toggleSave(Outfit outfit, String? token) async {
    if (token == null) return false;

    final currentlySaved = isSaved(outfit.id);

    try {
      if (currentlySaved) {
        // ลบออก
        final success = await wardrobeService.removeFromWardrobe(outfit.id, token);
        if (success) {
          savedOutfits.removeWhere((o) => o.id == outfit.id);
          notifyListeners();
          return false; // ไม่ได้เซฟแล้ว
        }
      } else {
        // เพิ่มเข้าตู้
        final success = await wardrobeService.saveToWardrobe(outfit.id, token);
        if (success) {
          savedOutfits.insert(0, outfit);
          notifyListeners();
          return true; // เซฟสำเร็จ
        }
      }
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
    return currentlySaved;
  }
}
