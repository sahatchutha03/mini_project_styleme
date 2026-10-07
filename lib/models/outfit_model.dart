import 'styling_tip_model.dart';

class OutfitItem {
  final String category; // 'Top', 'Bottom', 'Shoes', 'Accessory'
  final String name;
  final String colorName;
  final String colorHex;

  OutfitItem({
    required this.category,
    required this.name,
    required this.colorName,
    required this.colorHex,
  });

  factory OutfitItem.fromJson(Map<String, dynamic> json) {
    return OutfitItem(
      category: json['category'] ?? '',
      name: json['name'] ?? '',
      colorName: json['colorName'] ?? json['color_name'] ?? '',
      colorHex: json['colorHex'] ?? json['color_hex'] ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'name': name,
      'colorName': colorName,
      'colorHex': colorHex,
    };
  }
}

class Outfit {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String occasion; // 'Office', 'Cafe', 'Dinner', 'Street', 'Beach'
  final List<String> bodyShapes; // ['Pear', 'Hourglass', ...]
  final String colorCategory; // 'work', 'wealth', 'love'
  final String colorName;
  final String colorHex;
  final int matchScore; // e.g. 96 (%)
  final List<OutfitItem> items;
  final Map<String, StylingTip> stylingTips; // Key is bodyShape (e.g. 'Pear')

  Outfit({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.occasion,
    required this.bodyShapes,
    required this.colorCategory,
    required this.colorName,
    required this.colorHex,
    required this.matchScore,
    required this.items,
    required this.stylingTips,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    List<OutfitItem> itemsList = rawItems.map((e) => OutfitItem.fromJson(e)).toList();

    var rawTips = json['stylingTips'] as Map<String, dynamic>? ?? {};
    Map<String, StylingTip> tipsMap = {};
    rawTips.forEach((key, value) {
      tipsMap[key] = StylingTip.fromJson(value);
    });

    var rawShapes = json['bodyShapes'] as List? ?? [];
    List<String> shapesList = rawShapes.map((e) => e.toString()).toList();

    return Outfit(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      occasion: json['occasion'] ?? 'Cafe',
      bodyShapes: shapesList,
      colorCategory: json['colorCategory'] ?? json['color_category'] ?? 'work',
      colorName: json['colorName'] ?? json['color_name'] ?? '',
      colorHex: json['colorHex'] ?? json['color_hex'] ?? '#6B4EE6',
      matchScore: json['matchScore'] is int ? json['matchScore'] : int.tryParse(json['matchScore'].toString()) ?? 90,
      items: itemsList,
      stylingTips: tipsMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'occasion': occasion,
      'bodyShapes': bodyShapes,
      'colorCategory': colorCategory,
      'colorName': colorName,
      'colorHex': colorHex,
      'matchScore': matchScore,
      'items': items.map((e) => e.toJson()).toList(),
      'stylingTips': stylingTips.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  /// ดึงคำแนะนำสำหรับรูปร่างที่ระบุ ถ้าไม่มี ให้คืนคำแนะนำค่าเริ่มต้น
  StylingTip getTipForBodyShape(String bodyShape) {
    if (stylingTips.containsKey(bodyShape)) {
      return stylingTips[bodyShape]!;
    }
    if (stylingTips.isNotEmpty) {
      return stylingTips.values.first;
    }
    return StylingTip(
      id: 0,
      bodyShape: bodyShape,
      tipTitle: 'เคล็ดลับการแมทช์ลุคนี้',
      tipContent: 'เลือกเครื่องประดับโทนสีมงคล และปรับทรงเสื้อผ้าให้สมส่วนกับสรีระ',
      highlightFeature: 'สมดุลสัดส่วน',
      luckyColorSynergy: 'สวมใส่โทนสีนี้ช่วยเพิ่มความมั่นใจตลอดวัน',
    );
  }
}
