import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/style_filter_provider.dart';
import '../../widgets/outfit_card.dart';
import '../../config/app_theme.dart';
import '../outfit_detail/outfit_detail_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<WardrobeProvider>().fetchWardrobe(auth.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wardrobeProv = context.watch<WardrobeProvider>();
    final filter = context.watch<StyleFilterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ตู้เสื้อผ้าของฉัน (My Wardrobe)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => wardrobeProv.fetchWardrobe(auth.token),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await wardrobeProv.fetchWardrobe(auth.token);
        },
        child: wardrobeProv.isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text('กำลังเปิดตู้เสื้อผ้าของคุณ...', style: TextStyle(color: AppTheme.textSecondaryOf(context))),
                  ],
                ),
              )
            : wardrobeProv.savedOutfits.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLightOf(context),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.checkroom_outlined,
                              size: 72,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'ตู้เสื้อผ้าของคุณยังว่างอยู่',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryOf(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'เมื่อพบสไตล์ที่ชอบ กดไอคอน Bookmark เพื่อบันทึกลงตู้เสื้อผ้าส่วนตัวของคุณได้ทันที',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryOf(context)),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ส่วนสรุปจำนวนชุดในตู้
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLightOf(context),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryColor),
                            const SizedBox(width: 10),
                            Text(
                              'ชุดที่บันทึกไว้ทั้งหมด: ${wardrobeProv.count} ชุด',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // รายการชุดที่บันทึกไว้
                      ...wardrobeProv.savedOutfits.map((outfit) {
                        return Dismissible(
                          key: Key('wardrobe-${outfit.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.dangerColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('ลบออกจากตู้', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.delete_outline, color: Colors.white),
                              ],
                            ),
                          ),
                          onDismissed: (_) {
                            wardrobeProv.toggleSave(outfit, auth.token);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('ลบ "${outfit.title}" ออกจากตู้เสื้อผ้าแล้ว'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: OutfitCard(
                            outfit: outfit,
                            currentBodyShape: filter.selectedBodyShape,
                            heroTagPrefix: 'wardrobe',
                            onTap: () {
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
                          ),
                        );
                      }),
                    ],
                  ),
      ),
    );
  }
}
