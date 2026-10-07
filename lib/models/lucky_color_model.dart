import 'package:flutter/material.dart';

class ColorItem {
  final String category; // 'work', 'wealth', 'love', 'unlucky'
  final String label; // การงาน, โชคลาภ, ความรัก, กาลกิณี
  final String colorName; // สีเขียว, สีน้ำเงิน
  final String hex; // #10B981
  final IconData icon;

  ColorItem({
    required this.category,
    required this.label,
    required this.colorName,
    required this.hex,
    required this.icon,
  });

  Color get color {
    final hexString = hex.replaceAll('#', '');
    if (hexString.length == 6) {
      return Color(int.parse('FF$hexString', radix: 16));
    }
    return Colors.grey;
  }
}

class DailyLuckyColor {
  final String dayOfWeek;
  final String dayTitle;
  final String thaiDate;
  final ColorItem work;
  final ColorItem wealth;
  final ColorItem love;
  final ColorItem unlucky;
  final String advice;

  DailyLuckyColor({
    required this.dayOfWeek,
    required this.dayTitle,
    required this.thaiDate,
    required this.work,
    required this.wealth,
    required this.love,
    required this.unlucky,
    required this.advice,
  });

  factory DailyLuckyColor.fromJson(Map<String, dynamic> json) {
    return DailyLuckyColor(
      dayOfWeek: json['dayOfWeek'] ?? '',
      dayTitle: json['dayTitle'] ?? '',
      thaiDate: json['thaiDate'] ?? '',
      advice: json['advice'] ?? '',
      work: ColorItem(
        category: 'work',
        label: 'การงาน',
        colorName: json['workColor'] ?? 'เขียว',
        hex: json['workHex'] ?? '#10B981',
        icon: Icons.work_outline,
      ),
      wealth: ColorItem(
        category: 'wealth',
        label: 'โชคลาภ/การเงิน',
        colorName: json['wealthColor'] ?? 'น้ำเงิน/ฟ้า',
        hex: json['wealthHex'] ?? '#3B82F6',
        icon: Icons.monetization_on_outlined,
      ),
      love: ColorItem(
        category: 'love',
        label: 'ความรัก/เสน่ห์',
        colorName: json['loveColor'] ?? 'ชมพู/ส้ม',
        hex: json['loveHex'] ?? '#EC4899',
        icon: Icons.favorite_border,
      ),
      unlucky: ColorItem(
        category: 'unlucky',
        label: 'กาลกิณี (ควรเลี่ยง)',
        colorName: json['unluckyColor'] ?? 'ดำ/ม่วงเข้ม',
        hex: json['unluckyHex'] ?? '#374151',
        icon: Icons.block,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'dayTitle': dayTitle,
      'thaiDate': thaiDate,
      'advice': advice,
      'workColor': work.colorName,
      'workHex': work.hex,
      'wealthColor': wealth.colorName,
      'wealthHex': wealth.hex,
      'loveColor': love.colorName,
      'loveHex': love.hex,
      'unluckyColor': unlucky.colorName,
      'unluckyHex': unlucky.hex,
    };
  }
}
