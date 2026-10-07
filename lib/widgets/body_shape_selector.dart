import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class BodyShapeOption {
  final String key;
  final String titleTh;
  final String subtitle;
  final IconData icon;

  const BodyShapeOption({
    required this.key,
    required this.titleTh,
    required this.subtitle,
    required this.icon,
  });
}

class BodyShapeSelector extends StatelessWidget {
  final String selectedShape;
  final ValueChanged<String> onShapeSelected;

  const BodyShapeSelector({
    super.key,
    required this.selectedShape,
    required this.onShapeSelected,
  });

  static const List<BodyShapeOption> options = [
    BodyShapeOption(
      key: 'Pear',
      titleTh: 'ลูกแพร์ (Pear)',
      subtitle: 'สะโพกกว้างกว่าช่วงไหล่',
      icon: Icons.accessibility_new,
    ),
    BodyShapeOption(
      key: 'Hourglass',
      titleTh: 'นาฬิกาทราย (Hourglass)',
      subtitle: 'ไหล่และสะโพกสมดุล เอวคอดชัด',
      icon: Icons.hourglass_empty,
    ),
    BodyShapeOption(
      key: 'Apple',
      titleTh: 'แอปเปิ้ล (Apple)',
      subtitle: 'ช่วงตัวและหน้าอกเด่น ขาเพรียว',
      icon: Icons.circle_outlined,
    ),
    BodyShapeOption(
      key: 'Rectangle',
      titleTh: 'ทรงตรง (Rectangle)',
      subtitle: 'สัดส่วนบนล่างเท่ากัน ไร้ส่วนเว้า',
      icon: Icons.crop_portrait,
    ),
    BodyShapeOption(
      key: 'Inverted Triangle',
      titleTh: 'สามเหลี่ยมคว่ำ (Inverted)',
      subtitle: 'ช่วงไหล่กว้างกว่าสะโพก',
      icon: Icons.change_history,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_pin, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              '1. รูปร่างของคุณ (Body Shape)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final opt = options[index];
              final isSelected = opt.key == selectedShape;

              return InkWell(
                onTap: () => onShapeSelected(opt.key),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceOf(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.borderOf(context),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            opt.icon,
                            color: isSelected ? Colors.white : AppTheme.primaryColor,
                            size: 24,
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        opt.titleTh,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textPrimaryOf(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        opt.subtitle,
                        style: TextStyle(
                          color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppTheme.textSecondaryOf(context),
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
