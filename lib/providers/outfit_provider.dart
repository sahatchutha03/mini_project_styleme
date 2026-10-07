import 'package:flutter/foundation.dart';
import '../models/outfit_model.dart';
import '../models/styling_tip_model.dart';
import '../services/outfit_service.dart';

class OutfitProvider extends ChangeNotifier {
  final OutfitService outfitService;

  List<Outfit> matchedOutfits = [];
  Outfit? selectedOutfit;
  StylingTip? currentPersonalizedTip;

  bool isLoading = false;
  String? errorMessage;

  OutfitProvider({required this.outfitService});

  /// ส่ง Request กรองข้อมูลและรับรายการเสื้อผ้าที่แมทช์กันจาก Database / API
  Future<void> fetchMatchedOutfits({
    String? bodyShape,
    String? occasion,
    String? colorCategory,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      matchedOutfits = await outfitService.getMatchedOutfits(
        bodyShape: bodyShape,
        occasion: occasion,
        colorCategory: colorCategory,
      );
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// เลือกชุดและเตรียมคำแนะนำ Styling Tips แบบเฉพาะบุคคลตามรูปร่าง
  void selectOutfit(Outfit outfit, String bodyShape) {
    selectedOutfit = outfit;
    currentPersonalizedTip = outfit.getTipForBodyShape(bodyShape);
    notifyListeners();
  }

  /// ดึงรายละเอียดชุดเพิ่มเติมและคำแนะนำแบบเฉพาะบุคคล
  Future<void> loadOutfitDetail(int outfitId, String bodyShape) async {
    isLoading = true;
    notifyListeners();

    try {
      selectedOutfit = await outfitService.getOutfitDetail(outfitId, bodyShape: bodyShape);
      currentPersonalizedTip = selectedOutfit?.getTipForBodyShape(bodyShape);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// เพิ่มชุดใหม่ (Admin)
  Future<bool> createOutfit(String token, Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newOutfit = await outfitService.createOutfit(token, data);
      matchedOutfits.insert(0, newOutfit);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// แก้ไขชุด (Admin)
  Future<bool> updateOutfit(String token, int id, Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updated = await outfitService.updateOutfit(token, id, data);
      final idx = matchedOutfits.indexWhere((o) => o.id == id);
      if (idx != -1) {
        matchedOutfits[idx] = updated;
      }
      if (selectedOutfit?.id == id) {
        selectedOutfit = updated;
      }
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ลบชุด (Admin)
  Future<bool> deleteOutfit(String token, int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await outfitService.deleteOutfit(token, id);
      matchedOutfits.removeWhere((o) => o.id == id);
      if (selectedOutfit?.id == id) {
        selectedOutfit = null;
      }
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
