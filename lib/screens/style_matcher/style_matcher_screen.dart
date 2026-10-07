import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/style_filter_provider.dart';
import '../../providers/outfit_provider.dart';
import '../../widgets/body_shape_selector.dart';
import '../../widgets/occasion_selector.dart';
import '../../widgets/outfit_card.dart';
import '../../config/app_theme.dart';
import '../outfit_detail/outfit_detail_screen.dart';
import '../admin/admin_outfit_form_screen.dart';

class StyleMatcherScreen extends StatefulWidget {
  const StyleMatcherScreen({super.key});

  @override
  State<StyleMatcherScreen> createState() => _StyleMatcherScreenState();
}

class _StyleMatcherScreenState extends State<StyleMatcherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilter();
    });
  }

  /// ฟังก์ชันยิง Request กรองข้อมูลจาก Database ตาม State ปัจจุบัน (Requirement #4)
  void _applyFilter() {
    final filter = context.read<StyleFilterProvider>();
    context.read<OutfitProvider>().fetchMatchedOutfits(
      bodyShape: filter.selectedBodyShape,
      occasion: filter.selectedOccasion,
      colorCategory: filter.selectedColorCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<StyleFilterProvider>();
    final outfitProv = context.watch<OutfitProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('แมทช์สไตล์ของคุณ'),
        actions: [
          if (context.watch<AuthProvider>().isAdmin)
            IconButton(
              tooltip: 'เพิ่มชุดเสื้อผ้าใหม่ (Admin)',
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
              onPressed: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminOutfitFormScreen()),
                );
                if (added == true) {
                  _applyFilter();
                }
              },
            ),
          TextButton(
            onPressed: () {
              final auth = context.read<AuthProvider>();
              final defaultShape = (auth.user != null && auth.user!.defaultBodyShape.isNotEmpty)
                  ? auth.user!.defaultBodyShape
                  : 'Pear';
              filter.resetFilter(defaultShape);
              _applyFilter();
            },
            child: const Text('รีเซ็ต'),
          ),
        ],
      ),
      body: Column(
        children: [
          // กล่องตัวเลือกด้านบน (Filter Section)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              border: Border(bottom: BorderSide(color: AppTheme.borderOf(context))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Requirement #3: ผู้ใช้เลือก รูปร่าง ทำให้ State อัปเดต
                BodyShapeSelector(
                  selectedShape: filter.selectedBodyShape,
                  onShapeSelected: (shape) {
                    filter.setBodyShape(shape);
                    _applyFilter(); // ยิง Request กรองข้อมูลทันที
                  },
                ),
                const SizedBox(height: 14),

                // Requirement #3: ผู้ใช้เลือก สถานที่ ทำให้ State อัปเดต
                OccasionSelector(
                  selectedOccasion: filter.selectedOccasion,
                  onOccasionSelected: (occasion) {
                    filter.setOccasion(occasion);
                    _applyFilter(); // ยิง Request กรองข้อมูลทันที
                  },
                ),
                const SizedBox(height: 12),

                // Status Indicator: แสดง End-to-End Flow ชัดเจน
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightOf(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sync_alt, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'State: [หุ่น: ${filter.selectedBodyShape}] + [สถานที่: ${filter.selectedOccasion}] ➔ API/DB Filtered',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // รายการผลลัพธ์ (Requirement #4: แสดงรายการเสื้อผ้าที่แมทช์จาก Database)
          Expanded(
            child: outfitProv.isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text(
                          'กำลังส่ง Request กรองข้อมูลจาก Database...',
                          style: TextStyle(color: AppTheme.textSecondaryOf(context), fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : outfitProv.matchedOutfits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.style_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              'ไม่พบชุดสำหรับหุ่น ${filter.selectedBodyShape} ในโอกาส ${filter.selectedOccasion}',
                              style: TextStyle(color: AppTheme.textSecondaryOf(context), fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                filter.setOccasion('All');
                                _applyFilter();
                              },
                              child: const Text('ดูชุดทั้งหมด'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: outfitProv.matchedOutfits.length,
                        itemBuilder: (context, index) {
                          final outfit = outfitProv.matchedOutfits[index];
                          return OutfitCard(
                            outfit: outfit,
                            currentBodyShape: filter.selectedBodyShape,
                            heroTagPrefix: 'matcher',
                            onTap: () {
                              outfitProv.selectOutfit(outfit, filter.selectedBodyShape);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OutfitDetailScreen(
                                    outfit: outfit,
                                    bodyShape: filter.selectedBodyShape,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
