import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/style_filter_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                        'แก้ไขข้อมูลส่วนตัว',
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
                    'เลือกลักษณะรูปร่างเริ่มต้นของคุณ:',
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
                          // ซิงค์ไปยัง StyleFilterProvider ด้วย
                          filter.setBodyShape(selectedShape);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('อัปเดตข้อมูลผู้ใช้ลง MySQL สำเร็จ!'),
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
    final wardrobe = context.watch<WardrobeProvider>();
    final user = auth.user;
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์ผู้ใช้งาน (Profile)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ส่วนหัวโปรไฟล์
            Container(
              padding: const EdgeInsets.all(20),
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
                        radius: 42,
                        backgroundColor: AppTheme.primaryLightOf(context),
                        child: Text(
                          (user?.fullName.isNotEmpty == true) ? user!.fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield, size: 16, color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'ผู้ใช้งาน StyleMe',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAdmin ? AppTheme.primaryColor : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.person,
                          size: 14,
                          color: isAdmin ? Colors.white : Colors.grey.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAdmin ? 'ผู้ดูแลระบบ (Admin)' : 'สมาชิกทั่วไป (Member)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isAdmin ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLightOf(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.accessibility_new, size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          'หุ่นเริ่มต้น: ${user?.defaultBodyShape ?? "Pear"}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
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
            const SizedBox(height: 16),

            // สถิติส่วนตัว (Stats)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceOf(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderOf(context)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryColor, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          '${wardrobe.count}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryOf(context),
                          ),
                        ),
                        Text(
                          'ชุดในตู้เสื้อผ้า',
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceOf(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderOf(context)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.stars_outlined, color: AppTheme.secondaryColor, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          user?.defaultBodyShape ?? 'Pear',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryOf(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'รูปร่างประจำตัว',
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                    content: const Text('คุณต้องการออกจากระบบ StyleMe หรือไม่?'),
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
              label: const Text('ออกจากระบบ'),
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
}
