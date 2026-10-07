import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/outfit_model.dart';
import '../../widgets/personalized_tip_card.dart';
import '../../config/app_theme.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/outfit_provider.dart';
import '../admin/admin_outfit_form_screen.dart';

class OutfitDetailScreen extends StatefulWidget {
  final Outfit outfit;
  final String bodyShape;

  const OutfitDetailScreen({
    super.key,
    required this.outfit,
    required this.bodyShape,
  });

  @override
  State<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends State<OutfitDetailScreen> {
  late String _activeShape;

  @override
  void initState() {
    super.initState();
    _activeShape = widget.bodyShape;
  }

  @override
  Widget build(BuildContext context) {
    final outfit = widget.outfit;
    // ดึง Tip เฉพาะบุคคลสำหรับรูปร่างที่เลือก
    final tip = outfit.getTipForBodyShape(_activeShape);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ส่วนหัว SliverAppBar พร้อมรูปภาพขนาดเต็ม
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'outfit-image-${outfit.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      outfit.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.checkroom, size: 80, color: Colors.grey),
                      ),
                    ),
                    // Gradient overlay ให้ข้อความและปุ่มอ่านง่าย
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                    // ข้อมูลลอยบนรูป
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  'Match ${outfit.matchScore}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  outfit.occasion,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            outfit.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Consumer2<WardrobeProvider, AuthProvider>(
                builder: (context, wardrobeProv, authProv, _) {
                  final isSavedInWardrobe = wardrobeProv.isSaved(outfit.id);
                  final isAdmin = authProv.isAdmin;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAdmin) ...[
                        IconButton(
                          tooltip: 'แก้ไขชุดนี้ (Admin)',
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminOutfitFormScreen(outfit: outfit),
                              ),
                            );
                            if (updated == true && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'ลบชุดนี้ (Admin)',
                          icon: const Icon(Icons.delete_outline, color: Colors.white),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('ยืนยันลบชุดเสื้อผ้า'),
                                content: Text('คุณต้องการลบ "${outfit.title}" ออกจากระบบหรือไม่?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('ยกเลิก'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      final token = authProv.token;
                                      if (token != null) {
                                        final ok = await context.read<OutfitProvider>().deleteOutfit(token, outfit.id);
                                        if (context.mounted && ok) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('ลบชุดเสื้อผ้าออกจากระบบสำเร็จ'),
                                              backgroundColor: AppTheme.successColor,
                                            ),
                                          );
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
                                    child: const Text('ลบ', style: TextStyle(color: AppTheme.dangerColor)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      IconButton(
                        tooltip: isSavedInWardrobe ? 'ลบออกจากตู้' : 'บันทึกลงตู้',
                        icon: Icon(
                          isSavedInWardrobe ? Icons.bookmark : Icons.bookmark_border,
                          color: isSavedInWardrobe ? AppTheme.accentColor : Colors.white,
                        ),
                        onPressed: () async {
                          final saved = await wardrobeProv.toggleSave(outfit, authProv.token);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  saved
                                      ? 'บันทึก "${outfit.title}" ลงตู้เสื้อผ้าแล้ว'
                                      : 'ลบออกจากตู้เสื้อผ้าแล้ว',
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          // รายละเอียดเนื้อหา
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // คำอธิบายภาพรวม
                  Text(
                    outfit.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryOf(context),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🌟 Requirement #5: แสดงคำแนะนำการแต่งตัว (Styling Tips) แบบเฉพาะบุคคล
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'คำแนะนำการแต่งตัวเฉพาะบุคคล',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryOf(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'คำนวณและวิเคราะห์ตามลักษณะสรีระของคุณโดยเฉพาะ:',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryOf(context)),
                  ),
                  const SizedBox(height: 12),

                  // กล่องคำแนะนำเฉพาะบุคคล
                  PersonalizedTipCard(
                    tip: tip,
                    bodyShape: _activeShape,
                  ),

                  const SizedBox(height: 16),

                  // ตัวเลือกทดลองสลับดูมุมมองคำแนะนำของหุ่นอื่น (สำหรับทดสอบ)
                  Row(
                    children: [
                      const Text(
                        'ลองดูคำแนะนำหุ่นอื่น:',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['Pear', 'Hourglass', 'Apple', 'Rectangle', 'Inverted Triangle'].map((shape) {
                              final isSelected = shape == _activeShape;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(shape),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    if (val) {
                                      setState(() {
                                        _activeShape = shape;
                                      });
                                    }
                                  },
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white : AppTheme.textPrimaryOf(context),
                                  ),
                                  selectedColor: AppTheme.primaryColor,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ชิ้นส่วนเสื้อผ้าที่ประกอบกัน (Outfit Pieces Breakdown)
                  Text(
                    'ชิ้นส่วนเสื้อผ้าในลุคนี้ (Pieces Breakdown)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...outfit.items.map((item) {
                    final itemColor = Color(
                      int.parse('FF${item.colorHex.replaceAll('#', '')}', radix: 16),
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceOf(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderOf(context)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLightOf(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_getCategoryIcon(item.category), color: AppTheme.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimaryOf(context),
                                  ),
                                ),
                                Text(
                                  'หมวด: ${item.category}',
                                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context)),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: itemColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.colorName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondaryOf(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  // ปุ่ม Action ท้ายหน้า
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('คัดลอกลิงก์แชร์สไตล์แล้ว')),
                            );
                          },
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('แชร์ลุคนี้'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('เลือกสไตล์นี้'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'top':
        return Icons.dry_cleaning;
      case 'bottom':
        return Icons.shopping_bag_outlined;
      case 'shoes':
        return Icons.skateboarding_outlined;
      case 'accessory':
        return Icons.watch_outlined;
      default:
        return Icons.checkroom;
    }
  }
}
