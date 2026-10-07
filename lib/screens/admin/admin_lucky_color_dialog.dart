import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

class AdminLuckyColorDialog extends StatefulWidget {
  final Map<String, dynamic> colorData;

  const AdminLuckyColorDialog({super.key, required this.colorData});

  @override
  State<AdminLuckyColorDialog> createState() => _AdminLuckyColorDialogState();
}

class _AdminLuckyColorDialogState extends State<AdminLuckyColorDialog> {
  late TextEditingController _workColorCtrl;
  late TextEditingController _workHexCtrl;
  late TextEditingController _wealthColorCtrl;
  late TextEditingController _wealthHexCtrl;
  late TextEditingController _loveColorCtrl;
  late TextEditingController _loveHexCtrl;
  late TextEditingController _unluckyColorCtrl;
  late TextEditingController _unluckyHexCtrl;
  late TextEditingController _adviceCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.colorData;
    _workColorCtrl = TextEditingController(text: d['work_color']?.toString() ?? '');
    _workHexCtrl = TextEditingController(text: d['work_hex']?.toString() ?? '#F59E0B');
    _wealthColorCtrl = TextEditingController(text: d['wealth_color']?.toString() ?? '');
    _wealthHexCtrl = TextEditingController(text: d['wealth_hex']?.toString() ?? '#8B5CF6');
    _loveColorCtrl = TextEditingController(text: d['love_color']?.toString() ?? '');
    _loveHexCtrl = TextEditingController(text: d['love_hex']?.toString() ?? '#3B82F6');
    _unluckyColorCtrl = TextEditingController(text: d['unlucky_color']?.toString() ?? '');
    _unluckyHexCtrl = TextEditingController(text: d['unlucky_hex']?.toString() ?? '#EF4444');
    _adviceCtrl = TextEditingController(text: d['advice']?.toString() ?? '');
  }

  @override
  void dispose() {
    _workColorCtrl.dispose();
    _workHexCtrl.dispose();
    _wealthColorCtrl.dispose();
    _wealthHexCtrl.dispose();
    _loveColorCtrl.dispose();
    _loveHexCtrl.dispose();
    _unluckyColorCtrl.dispose();
    _unluckyHexCtrl.dispose();
    _adviceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().token;
    final adminProv = context.read<AdminProvider>();
    final id = widget.colorData['id'];

    setState(() => _isSaving = true);

    final payload = {
      'work_color': _workColorCtrl.text.trim(),
      'work_hex': _workHexCtrl.text.trim(),
      'wealth_color': _wealthColorCtrl.text.trim(),
      'wealth_hex': _wealthHexCtrl.text.trim(),
      'love_color': _loveColorCtrl.text.trim(),
      'love_hex': _loveHexCtrl.text.trim(),
      'unlucky_color': _unluckyColorCtrl.text.trim(),
      'unlucky_hex': _unluckyHexCtrl.text.trim(),
      'advice': _adviceCtrl.text.trim(),
    };

    final ok = await adminProv.updateLuckyColor(token, id, payload);

    if (mounted) {
      setState(() => _isSaving = false);
      if (ok) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อัปเดตข้อมูลสีมงคลของ ${widget.colorData['day_title']} สำเร็จ!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminProv.errorMessage ?? 'อัปเดตไม่สำเร็จ'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayTitle = widget.colorData['day_title'] ?? 'สีมงคล';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppTheme.surfaceOf(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'แก้ไขสีมงคล $dayTitle',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  _buildColorField('สีเสริมการงาน (Work)', _workColorCtrl, _workHexCtrl),
                  const SizedBox(height: 10),
                  _buildColorField('สีเสริมการเงิน (Wealth)', _wealthColorCtrl, _wealthHexCtrl),
                  const SizedBox(height: 10),
                  _buildColorField('สีเสริมความรัก (Love)', _loveColorCtrl, _loveHexCtrl),
                  const SizedBox(height: 10),
                  _buildColorField('สีกาลกิณีที่ควรเลี่ยง', _unluckyColorCtrl, _unluckyHexCtrl),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _adviceCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'คำแนะนำสไตล์ลิสต์ประจำวัน',
                      hintText: 'เทคนิคการแต่งตัวหรือแมทช์สีวันนี้...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ยกเลิก'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('บันทึก'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorField(String label, TextEditingController nameCtrl, TextEditingController hexCtrl) {
    Color previewColor;
    try {
      previewColor = Color(int.parse(hexCtrl.text.trim().replaceFirst('#', '0xFF')));
    } catch (_) {
      previewColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: previewColor, radius: 8),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'ชื่อสี', isDense: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: hexCtrl,
                  decoration: const InputDecoration(labelText: 'Hex code', isDense: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
