import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class OccasionOption {
  final String key;
  final String label;
  final IconData icon;

  const OccasionOption({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class OccasionSelector extends StatelessWidget {
  final String selectedOccasion;
  final ValueChanged<String> onOccasionSelected;

  const OccasionSelector({
    super.key,
    required this.selectedOccasion,
    required this.onOccasionSelected,
  });

  static const List<OccasionOption> options = [
    OccasionOption(key: 'Cafe', label: 'คาเฟ่ & ชิลๆ', icon: Icons.local_cafe_outlined),
    OccasionOption(key: 'Office', label: 'ทำงาน (Office)', icon: Icons.business_center_outlined),
    OccasionOption(key: 'Dinner', label: 'ดินเนอร์ / หรูหรา', icon: Icons.wine_bar_outlined),
    OccasionOption(key: 'Street', label: 'สตรีท / ช้อปปิ้ง', icon: Icons.directions_walk_outlined),
    OccasionOption(key: 'Beach', label: 'เที่ยวทะเล / ชายหาด', icon: Icons.beach_access_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.place_outlined, size: 20, color: AppTheme.secondaryColor),
            const SizedBox(width: 8),
            Text(
              '2. สถานที่ / โอกาส (Occasion)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((opt) {
              final isSelected = opt.key == selectedOccasion;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: Icon(
                    opt.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
                  ),
                  label: Text(opt.label),
                  selected: isSelected,
                  onSelected: (_) => onOccasionSelected(opt.key),
                  selectedColor: AppTheme.secondaryColor,
                  backgroundColor: AppTheme.surfaceOf(context),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimaryOf(context),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppTheme.secondaryColor : AppTheme.borderOf(context),
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
