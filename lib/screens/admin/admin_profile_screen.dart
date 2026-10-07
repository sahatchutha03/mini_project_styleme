import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/style_filter_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  void _showEditProfileDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final filter = context.read<StyleFilterProvider>();
    final user = auth.user;

    final nameController = TextEditingController(text: user?.fullName ?? '');
    String selectedShape = user?.defaultBodyShape ?? 'Pear';

    final shapes = [
      {'key': 'Pear', 'label': 'ลูกแพร์ (Pear)'},
      {'key': 'Hourglass', 'label': 'นาฬิกาทราย (Hourglass)'},
      {'key': 'Apple', 'label': 'แอปเปิ้ล (Apple)'},
      {'key': 'Rectangle', 'label': 'ทรงตรง (Rectangle)'},
      {'key': 'Inverted Triangle', 'label': 'สามเหลี่ยมคว่ำ (Inverted)'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'แก้ไขข้อมูลส่วนตัวผู้ดูแลระบบ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryOf(context),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อ-นามสกุล',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ลักษณะรูปร่าง:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedShape,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.accessibility_new_outlined),
                    ),
                    items: shapes.map((s) {
                      return DropdownMenuItem(
                        value: s['key'],
                        child: Text(s['label']!),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedShape = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final newName = nameController.text.trim();
                      if (newName.isEmpty) return;

                      final success = await auth.updateProfile(newName, selectedShape);
                      if (context.mounted) {
                        if (success) {
                          filter.setBodyShape(selectedShape);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('อัปเดตข้อมูลส่วนตัวสำเร็จ!'),
                              backgroundColor: AppTheme.successColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(auth.errorMessage ?? 'อัปเดตไม่สำเร็จ'),
                              backgroundColor: AppTheme.dangerColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('บันทึกการเปลี่ยนแปลง'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final adminProv = context.watch<AdminProvider>();
    final user = auth.user;
    final stats = adminProv.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์ผู้ดูแลระบบ (Admin Profile)'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ส่วนหัวโปรไฟล์แอดมิน
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderOf(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppTheme.primaryLightOf(context),
                        child: Text(
                          (user?.fullName.isNotEmpty == true) ? user!.fullName[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield, size: 18, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.fullName ?? 'ผู้ดูแลระบบ StyleMe',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Badge ผู้ดูแลระบบ
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'ผู้ดูแลระบบสูงสุด (System Admin)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _showEditProfileDialog(context),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('แก้ไขข้อมูลส่วนตัว'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // การ์ดแสดงประวัติและข้อมูลส่วนตัว
            Container(
              padding: const EdgeInsets.all(20),
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
                      const Icon(Icons.badge_outlined, color: AppTheme.primaryColor, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'ประวัติและข้อมูลบัญชี',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryOf(context),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildProfileRow('รหัสผู้ดูแลระบบ (ID)', '#${user?.id ?? 0}'),
                  _buildProfileRow('ชื่อ-นามสกุล', user?.fullName ?? '-'),
                  _buildProfileRow('อีเมลที่ใช้งาน', user?.email ?? '-'),
                  _buildProfileRow('สิทธิ์การเข้าถึง', 'เต็มรูปแบบ (เพิ่ม / ลบ / แก้ไข)'),
                  _buildProfileRow('สถานะบัญชี', 'พร้อมใช้งาน (Active)'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // การ์ดสถิติการดูแลระบบ
            if (stats != null)
              Container(
                padding: const EdgeInsets.all(20),
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
                        const Icon(Icons.insights_outlined, color: AppTheme.primaryColor, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'สถิติการดูแลระบบ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryOf(context),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem('ชุดในระบบ', '${stats['totalOutfits'] ?? 0} ชุด', Icons.checkroom),
                        ),
                        Expanded(
                          child: _buildStatItem('สมาชิกทั้งหมด', '${stats['totalUsers'] ?? 0} คน', Icons.people),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // การตั้งค่าโหมดกลางคืน (Dark Mode Switch)
            Consumer<ThemeProvider>(
              builder: (context, themeProv, _) {
                return Material(
                  color: AppTheme.surfaceOf(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AppTheme.borderOf(context)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLightOf(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          themeProv.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'โหมดกลางคืน (Dark Mode)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textPrimaryOf(context),
                        ),
                      ),
                      subtitle: Text(
                        themeProv.isDarkMode ? 'ธีมสีมืด (Midnight Plum)' : 'ธีมสีสว่าง (Soft Lilac)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryOf(context),
                        ),
                      ),
                      value: themeProv.isDarkMode,
                      activeThumbColor: AppTheme.secondaryColor,
                      onChanged: (val) {
                        themeProv.toggleTheme(val);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // ปุ่มออกจากระบบ
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('ยืนยันออกจากระบบ'),
                    content: const Text('คุณต้องการออกจากระบบผู้ดูแลระบบ StyleMe หรือไม่?'),
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
              icon: const Icon(Icons.logout),
              label: const Text('ออกจากระบบผู้ดูแลระบบ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: AppTheme.dangerColor,
                elevation: 0,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryOf(context)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLightOf(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context)),
          ),
        ],
      ),
    );
  }
}
