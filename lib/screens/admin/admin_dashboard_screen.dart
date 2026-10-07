import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/outfit_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/outfit_provider.dart';
import 'admin_outfit_form_screen.dart';
import 'admin_lucky_color_dialog.dart';
import '../../utils/admin_guard.dart';

class AdminDashboardScreen extends StatefulWidget {
  final bool showBackButton;

  const AdminDashboardScreen({super.key, this.showBackButton = true});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _outfitSearchCtrl = TextEditingController();
  final TextEditingController _userSearchCtrl = TextEditingController();

  String _selectedOccasionFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (!auth.isAdmin) {
        rejectAndRedirectToLogin(context);
        return;
      }
      _refreshAllData();
    });
  }

  void _refreshAllData() {
    final token = context.read<AuthProvider>().token;
    final adminProv = context.read<AdminProvider>();
    final outfitProv = context.read<OutfitProvider>();

    adminProv.fetchStats(token);
    adminProv.fetchUsers(token);
    adminProv.fetchLuckyColors(token);
    outfitProv.fetchMatchedOutfits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _outfitSearchCtrl.dispose();
    _userSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleToggleUserRole(String? token, int userId, String currentRole, String fullName) async {
    final admin = context.read<AdminProvider>();
    final ok = await admin.toggleUserRole(token, userId, currentRole);
    if (!mounted) return;
    if (ok) {
      final newRole = currentRole == 'admin' ? 'User' : 'Admin';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เปลี่ยนสิทธิ์ผู้ใช้ "$fullName" เป็น $newRole สำเร็จ'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _handleDeleteUser(String? token, int userId) async {
    final admin = context.read<AdminProvider>();
    final ok = await admin.deleteUser(token, userId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบผู้ใช้งานสำเร็จ'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAdmin) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.gpp_bad_rounded, size: 72, color: AppTheme.dangerColor),
                SizedBox(height: 16),
                Text(
                  'ไม่สามารถเข้าใช้งานในส่วนนี้ได้',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dangerColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'เฉพาะผู้ดูแลระบบ (Admin) เท่านั้น กำลังนำคุณกลับไปหน้าเข้าสู่ระบบ...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: const Text('แผงควบคุมระบบ (Admin Panel)'),
        actions: [
          IconButton(
            tooltip: 'รีเฟรชข้อมูล',
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAllData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryOf(context),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'ภาพรวมระบบ'),
            Tab(icon: Icon(Icons.checkroom_outlined), text: 'จัดการเสื้อผ้า'),
            Tab(icon: Icon(Icons.people_outline), text: 'จัดการผู้ใช้'),
            Tab(icon: Icon(Icons.palette_outlined), text: 'สีมงคลประจำวัน'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildOutfitsTab(),
          _buildUsersTab(),
          _buildLuckyColorsTab(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_tabController.index == 1) {
            return FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มชุดเสื้อผ้าใหม่'),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminOutfitFormScreen()),
                );
                if (result == true) {
                  _refreshAllData();
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ==========================================
  // TAB 1: ภาพรวมระบบ (System Overview)
  // ==========================================
  Widget _buildOverviewTab() {
    final admin = context.watch<AdminProvider>();
    final stats = admin.stats;

    if (admin.isLoadingStats && stats == null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
            const SizedBox(height: 12),
            Text(admin.errorMessage ?? 'ไม่สามารถดึงข้อมูลสถิติได้'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _refreshAllData, child: const Text('ลองใหม่อีกครั้ง')),
          ],
        ),
      );
    }

    final totalOutfits = stats['totalOutfits'] ?? 0;
    final totalUsers = stats['totalUsers'] ?? 0;
    final totalAdmins = stats['totalAdmins'] ?? 0;
    final totalWardrobe = stats['totalWardrobeSaves'] ?? 0;
    final occasionCounts = (stats['occasionCounts'] as List? ?? []);
    final health = stats['systemHealth'] as Map<String, dynamic>? ?? {};

    return RefreshIndicator(
      onRefresh: () async => _refreshAllData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stat Metrics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _buildMetricCard(
                title: 'ชุดเสื้อผ้าทั้งหมด',
                value: '$totalOutfits',
                unit: 'ชุด',
                icon: Icons.checkroom,
                color: AppTheme.primaryColor,
              ),
              _buildMetricCard(
                title: 'ผู้ใช้งานในระบบ',
                value: '$totalUsers',
                unit: 'คน',
                icon: Icons.people,
                color: Colors.blue.shade600,
              ),
              _buildMetricCard(
                title: 'ผู้ดูแลระบบ (Admin)',
                value: '$totalAdmins',
                unit: 'คน',
                icon: Icons.admin_panel_settings,
                color: Colors.orange.shade700,
              ),
              _buildMetricCard(
                title: 'บันทึกลงตู้เสื้อผ้า',
                value: '$totalWardrobe',
                unit: 'ครั้ง',
                icon: Icons.inventory_2,
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // System Health & Database Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderOf(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'สถานะความพร้อมของระบบ (System Health)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textPrimaryOf(context),
                            ),
                          ),
                          Text(
                            'ฐานข้อมูล: ${health['database'] ?? "Connected"} | Node: ${health['nodeVersion'] ?? "v20"}',
                            style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('ONLINE', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // System Cleanliness & Cleanup Trigger
                Row(
                  children: [
                    const Icon(Icons.cleaning_services_outlined, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'การจัดการความเรียบร้อยของระบบ:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: admin.isOperating
                          ? null
                          : () async {
                              final token = context.read<AuthProvider>().token;
                              final res = await admin.cleanupSystem(token);
                              if (!mounted) return;
                              if (res != null) {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Row(
                                      children: [
                                        Icon(Icons.verified, color: AppTheme.successColor),
                                        SizedBox(width: 8),
                                        Text('ระบบเรียบร้อยสมบูรณ์'),
                                      ],
                                    ),
                                    content: Text(
                                      '${res['message']}\n\n'
                                      '• ชุดเสื้อผ้าคงเหลือ: ${res['currentIntegrity']?['totalOutfits']} ชุด\n'
                                      '• ชิ้นส่วนเสื้อผ้า: ${res['currentIntegrity']?['totalClothingItems']} ชิ้น\n'
                                      '• Styling Tips: ${res['currentIntegrity']?['totalStylingTips']} รายการ\n'
                                      '• สมาชิกทั้งหมด: ${res['currentIntegrity']?['totalUsers']} คน\n'
                                      '• ความสัมพันธ์ตู้เสื้อผ้า: ${res['currentIntegrity']?['totalWardrobeEntries']} รายการ',
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ตกลง')),
                                    ],
                                  ),
                                );
                              }
                            },
                      icon: admin.isOperating
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.auto_fix_high, size: 16),
                      label: const Text('จัดระเบียบฐานข้อมูล'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Occasion Distribution
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderOf(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'สัดส่วนชุดเสื้อผ้าแยกตามโอกาส (Occasion Breakdown)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 12),
                ...occasionCounts.map((occ) {
                  final name = occ['occasion'] ?? 'Other';
                  final count = occ['count'] ?? 0;
                  final pct = totalOutfits > 0 ? (count / totalOutfits) : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('$count ชุด (${(pct * 100).toStringAsFixed(1)}%)',
                                style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: AppTheme.borderOf(context),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context), fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: จัดการเสื้อผ้า (Clothes / Outfits)
  // ==========================================
  Widget _buildOutfitsTab() {
    final outfitProv = context.watch<OutfitProvider>();
    final outfits = outfitProv.matchedOutfits;

    final search = _outfitSearchCtrl.text.trim().toLowerCase();
    final filtered = outfits.where((o) {
      final matchOccasion = _selectedOccasionFilter == 'All' || o.occasion == _selectedOccasionFilter;
      final matchSearch = search.isEmpty ||
          o.title.toLowerCase().contains(search) ||
          o.colorName.toLowerCase().contains(search) ||
          o.items.any((i) => i.name.toLowerCase().contains(search));
      return matchOccasion && matchSearch;
    }).toList();

    return Column(
      children: [
        // Search & Filter header
        Container(
          padding: const EdgeInsets.all(12),
          color: AppTheme.surfaceOf(context),
          child: Column(
            children: [
              TextField(
                controller: _outfitSearchCtrl,
                decoration: InputDecoration(
                  hintText: 'ค้นหาชุดเสื้อผ้า (ชื่อ, ชิ้นส่วน, สี)...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _outfitSearchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() => _outfitSearchCtrl.clear());
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Cafe', 'Office', 'Dinner', 'Street', 'Beach'].map((occ) {
                    final isSel = _selectedOccasionFilter == occ;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(occ == 'All' ? 'ทั้งหมด' : occ, style: const TextStyle(fontSize: 11)),
                        selected: isSel,
                        selectedColor: AppTheme.primaryLightOf(context),
                        checkmarkColor: AppTheme.primaryColor,
                        onSelected: (val) {
                          if (val) setState(() => _selectedOccasionFilter = occ);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Count info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'พบทั้งหมด ${filtered.length} ชุด',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondaryOf(context)),
              ),
              if (outfitProv.isLoading)
                const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
        ),

        // Outfits List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('ไม่พบชุดเสื้อผ้าที่ตรงกับเงื่อนไข'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _outfitSearchCtrl.clear();
                            _selectedOccasionFilter = 'All';
                          });
                        },
                        child: const Text('ล้างตัวกรอง'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final outfit = filtered[index];
                    return _buildOutfitAdminCard(outfit);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOutfitAdminCard(Outfit outfit) {
    final token = context.read<AuthProvider>().token;
    final outfitProv = context.read<OutfitProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Row(
        children: [
          // Thumbnail Image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: SizedBox(
              width: 100,
              height: 120,
              child: Image.network(
                outfit.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLightOf(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          outfit.occasion,
                          style: const TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Match ${outfit.matchScore}%',
                        style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outfit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ชิ้นส่วน: ${outfit.items.length} ชิ้น | คำแนะนำ: ${outfit.stylingTips.length} หุ่น',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(int.tryParse(outfit.colorHex.replaceFirst('#', '0xFF')) ?? 0xFF7A1CAC),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(outfit.colorName, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                tooltip: 'แก้ไขชุด',
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryColor),
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminOutfitFormScreen(outfit: outfit),
                    ),
                  );
                  if (updated == true) {
                    _refreshAllData();
                  }
                },
              ),
              IconButton(
                tooltip: 'ลบชุด',
                icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.dangerColor),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('ยืนยันการลบชุดเสื้อผ้า'),
                      content: Text('คุณต้องการลบ "${outfit.title}" ออกจากฐานข้อมูลหรือไม่?\nการกระทำนี้ไม่สามารถย้อนกลับได้'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            if (token != null) {
                              final ok = await outfitProv.deleteOutfit(token, outfit.id);
                              if (!mounted) return;
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('ลบชุดเสื้อผ้าออกจากระบบสำเร็จ'),
                                    backgroundColor: AppTheme.successColor,
                                  ),
                                );
                                _refreshAllData();
                              }
                            }
                          },
                          child: const Text('ลบชุดนี้', style: TextStyle(color: AppTheme.dangerColor)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: จัดการผู้ใช้งาน (Users Management)
  // ==========================================
  Widget _buildUsersTab() {
    final admin = context.watch<AdminProvider>();
    final currentUserId = context.read<AuthProvider>().user?.id;
    final token = context.read<AuthProvider>().token;

    final users = admin.users;
    final search = _userSearchCtrl.text.trim().toLowerCase();
    final filtered = users.where((u) {
      final name = (u['fullName'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      return search.isEmpty || name.contains(search) || email.contains(search);
    }).toList();

    return Column(
      children: [
        // Search Header
        Container(
          padding: const EdgeInsets.all(12),
          color: AppTheme.surfaceOf(context),
          child: TextField(
            controller: _userSearchCtrl,
            decoration: InputDecoration(
              hintText: 'ค้นหาผู้ใช้ (ชื่อ, อีเมล)...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ผู้ใช้งานทั้งหมด ${filtered.length} คน',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondaryOf(context)),
              ),
              if (admin.isLoadingUsers)
                const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('ไม่พบข้อมูลผู้ใช้งาน'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final u = filtered[index];
                    final isMe = u['id'] == currentUserId;
                    final role = (u['role'] ?? 'user').toString();
                    final isAdmin = role == 'admin';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceOf(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isMe ? AppTheme.primaryColor.withValues(alpha: 0.6) : AppTheme.borderOf(context),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isAdmin ? AppTheme.primaryColor : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            radius: 20,
                            child: Text(
                              (u['fullName']?.toString().isNotEmpty == true) ? u['fullName'][0].toUpperCase() : 'U',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        u['fullName'] ?? 'ผู้ใช้',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppTheme.textPrimaryOf(context),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryLightOf(context),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('คุณ', style: TextStyle(fontSize: 10, color: AppTheme.primaryColor)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  u['email'] ?? '',
                                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryOf(context)),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isAdmin ? Colors.purple.shade50 : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isAdmin ? 'ADMIN' : 'USER',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isAdmin ? AppTheme.primaryColor : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'หุ่น: ${u['bodyShape'] ?? "Pear"} | ตู้: ${u['wardrobeCount'] ?? 0} ชุด',
                                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Action Buttons
                          PopupMenuButton<String>(
                            tooltip: 'จัดการสิทธิ์/ผู้ใช้',
                            icon: const Icon(Icons.more_vert),
                            onSelected: (val) {
                              if (val == 'toggleRole') {
                                _handleToggleUserRole(token, u['id'], role, u['fullName'] ?? 'ผู้ใช้');
                              } else if (val == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('ยืนยันลบผู้ใช้งาน'),
                                    content: Text('คุณต้องการลบผู้ใช้ "${u['fullName']}" ออกจากระบบหรือไม่?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          _handleDeleteUser(token, u['id']);
                                        },
                                        child: const Text('ลบ', style: TextStyle(color: AppTheme.dangerColor)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                value: 'toggleRole',
                                child: Row(
                                  children: [
                                    Icon(
                                      isAdmin ? Icons.person_outline : Icons.shield_outlined,
                                      size: 18,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(isAdmin ? 'ปรับเป็นสมาชิกทั่วไป (User)' : 'ตั้งเป็นผู้ดูแลระบบ (Admin)'),
                                  ],
                                ),
                              ),
                              if (!isMe)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: AppTheme.dangerColor),
                                      SizedBox(width: 8),
                                      Text('ลบผู้ใช้นี้ออกจากระบบ', style: TextStyle(color: AppTheme.dangerColor)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 4: จัดการสีมงคล (Lucky Colors)
  // ==========================================
  Widget _buildLuckyColorsTab() {
    final admin = context.watch<AdminProvider>();
    final colors = admin.luckyColors;

    if (admin.isLoadingColors && colors.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final item = colors[index];
        final dayTitle = item['day_title'] ?? item['day_of_week'] ?? 'วัน';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceOf(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderOf(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny_outlined, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        dayTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryOf(context),
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('แก้ไข', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AdminLuckyColorDialog(colorData: item),
                      );
                    },
                  ),
                ],
              ),
              const Divider(height: 20),
              _buildColorPillRow('งาน (Work)', item['work_color'], item['work_hex']),
              const SizedBox(height: 6),
              _buildColorPillRow('เงิน (Wealth)', item['wealth_color'], item['wealth_hex']),
              const SizedBox(height: 6),
              _buildColorPillRow('รัก (Love)', item['love_color'], item['love_hex']),
              const SizedBox(height: 6),
              _buildColorPillRow('เลี่ยง (Unlucky)', item['unlucky_color'], item['unlucky_hex'], isWarning: true),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightOf(context).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.tips_and_updates_outlined, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['advice'] ?? '',
                        style: TextStyle(fontSize: 12, color: AppTheme.textPrimaryOf(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorPillRow(String label, dynamic colorName, dynamic colorHex, {bool isWarning = false}) {
    Color dotColor;
    try {
      dotColor = Color(int.parse((colorHex ?? '#999999').toString().replaceFirst('#', '0xFF')));
    } catch (_) {
      dotColor = Colors.grey;
    }

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isWarning ? AppTheme.dangerColor : AppTheme.textSecondaryOf(context),
            ),
          ),
        ),
        CircleAvatar(backgroundColor: dotColor, radius: 6),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            colorName?.toString() ?? '-',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
