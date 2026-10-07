import 'package:flutter/foundation.dart';

class StyleFilterProvider extends ChangeNotifier {
  // ค่าเริ่มต้น
  String _selectedBodyShape = 'Pear';
  String _selectedOccasion = 'Cafe';
  String _selectedColorCategory = 'All'; // 'All', 'wealth', 'work', 'love'

  String get selectedBodyShape => _selectedBodyShape;
  String get selectedOccasion => _selectedOccasion;
  String get selectedColorCategory => _selectedColorCategory;

  /// อัปเดต State รูปร่าง
  void setBodyShape(String shape) {
    if (_selectedBodyShape != shape) {
      _selectedBodyShape = shape;
      notifyListeners();
    }
  }

  /// อัปเดต State สถานที่/โอกาส
  void setOccasion(String occasion) {
    if (_selectedOccasion != occasion) {
      _selectedOccasion = occasion;
      notifyListeners();
    }
  }

  /// อัปเดต State หมวดสีมงคล
  void setColorCategory(String category) {
    if (_selectedColorCategory != category) {
      _selectedColorCategory = category;
      notifyListeners();
    }
  }

  /// รีเซ็ตเป็นค่าเริ่มต้น
  void resetFilter([String defaultShape = 'Pear']) {
    _selectedBodyShape = defaultShape;
    _selectedOccasion = 'Cafe';
    _selectedColorCategory = 'All';
    notifyListeners();
  }
}
