import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lucky_color_provider.dart';
import '../../providers/outfit_provider.dart';
import '../../providers/style_filter_provider.dart';
import '../../widgets/lucky_color_card.dart';
import '../../widgets/outfit_card.dart';
import '../../config/app_theme.dart';
import '../style_matcher/style_matcher_screen.dart';
import '../outfit_detail/outfit_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Requirement #2: หน้า Home Screen ดึงข้อมูล สีมงคลประจำวัน จาก API ได้ทันที
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final filter = context.read<StyleFilterProvider>();
      if (auth.user != null && auth.user!.defaultBodyShape.isNotEmpty) {
        filter.setBodyShape(auth.user!.defaultBodyShape);
      }
      context.read<LuckyColorProvider>().fetchTodayLuckyColors();
      final effectiveShape = (auth.user != null && auth.user!.defaultBodyShape.isNotEmpty)
          ? auth.user!.defaultBodyShape
          : filter.selectedBodyShape;
      context.read<OutfitProvider>().fetchMatchedOutfits(
        bodyShape: effectiveShape,
        occasion: filter.selectedOccasion,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final luckyColorProv = context.watch<LuckyColorProvider>();
    final outfitProv = context.watch<OutfitProvider>();
    final filterProv = context.watch<StyleFilterProvider>();

    final user = auth.user;
    final userBodyShape = (user != null && user.defaultBodyShape.isNotEmpty)
        ? user.defaultBodyShape
        : filterProv.selectedBodyShape;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLightOf(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.checkroom, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('StyleMe', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppTheme.textSecondaryOf(context)),
            tooltip: 'ออกจากระบบ',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('ยืนยันออกจากระบบ'),
                  content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('ยกเลิก'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        auth.logout();
                      },
                      child: const Text('ออกจากระบบ', style: TextStyle(color: AppTheme.dangerColor)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await luckyColorProv.fetchTodayLuckyColors();
          await outfitProv.fetchMatchedOutfits(
            bodyShape: userBodyShape,
            occasion: filterProv.selectedOccasion,
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ข้อความทักทายผู้ใช้
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สวัสดี, ${user?.fullName ?? "คุณลูกค้า"} ✨',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryOf(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'หุ่นของคุณ: $userBodyShape • วันนี้ใส่สีอะไรดี?',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryOf(context),
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryLightOf(context),
                    child: Text(
                      (user?.fullName.isNotEmpty == true) ? user!.fullName[0] : 'S',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // การ์ดสีมงคลประจำวัน (Requirement #2)
              if (luckyColorProv.isLoading)
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('กำลังดึงข้อมูลสีมงคลจาก API...', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                )
              else if (luckyColorProv.todayColors != null)
                LuckyColorCard(data: luckyColorProv.todayColors!)
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.dangerColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          luckyColorProv.errorMessage ?? 'ไม่สามารถดึงข้อมูลสีมงคลได้',
                          style: const TextStyle(color: AppTheme.dangerColor, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () => luckyColorProv.fetchTodayLuckyColors(),
                        child: const Text('ลองใหม่'),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // ปุ่ม Banner เรียกหน้า Style Matcher
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StyleMatcherScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceOf(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderOf(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLightOf(context),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.tune, color: AppTheme.primaryColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ค้นหาสไตล์ที่แมทช์ (Style Matcher)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryOf(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'เลือกลักษณะรูปร่าง & สถานที่ เพื่อดึงชุดที่เหมาะกับคุณ',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryColor),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // รายการชุดแนะนำที่แมทช์กับตัวเลือกปัจจุบัน
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'สไตล์แนะนำสำหรับคุณ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StyleMatcherScreen()),
                      );
                    },
                    child: const Text('ปรับตัวกรอง'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (outfitProv.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (outfitProv.matchedOutfits.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('ไม่พบชุดที่ตรงกับเงื่อนไข ลองเลือกรูปร่างหรือสถานที่อื่นดูนะ'),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: outfitProv.matchedOutfits.length,
                  itemBuilder: (context, index) {
                    final outfit = outfitProv.matchedOutfits[index];
                    return OutfitCard(
                      outfit: outfit,
                      currentBodyShape: userBodyShape,
                      heroTagPrefix: 'home',
                      onTap: () {
                        outfitProv.selectOutfit(outfit, userBodyShape);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OutfitDetailScreen(
                              outfit: outfit,
                              bodyShape: userBodyShape,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
