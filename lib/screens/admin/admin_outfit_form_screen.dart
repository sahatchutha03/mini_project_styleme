import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/outfit_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/outfit_provider.dart';
import '../../utils/admin_guard.dart';

class AdminOutfitFormScreen extends StatefulWidget {
  final Outfit? outfit;

  const AdminOutfitFormScreen({super.key, this.outfit});

  @override
  State<AdminOutfitFormScreen> createState() => _AdminOutfitFormScreenState();
}

class _AdminOutfitFormScreenState extends State<AdminOutfitFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _imageUrlController;
  late TextEditingController _colorNameController;
  late TextEditingController _colorHexController;

  String _selectedOccasion = 'Cafe';
  String _selectedColorCategory = 'work';
  int _matchScore = 95;
  final Set<String> _selectedShapes = {'Pear', 'Hourglass', 'Rectangle'};

  final List<Map<String, String>> _clothingItems = [];
  final Map<String, Map<String, String>> _stylingTips = {};

  final List<String> _availableOccasions = ['Cafe', 'Office', 'Dinner', 'Street', 'Beach'];
  final List<String> _allShapes = ['Pear', 'Hourglass', 'Apple', 'Rectangle', 'Inverted Triangle'];
  final List<String> _clothingCategories = ['Top', 'Bottom', 'Shoes', 'Accessory'];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (!auth.isAdmin) {
        rejectAndRedirectToLogin(context);
        return;
      }
    });

    final o = widget.outfit;
    _titleController = TextEditingController(text: o?.title ?? '');
    _descController = TextEditingController(text: o?.description ?? '');
    _imageUrlController = TextEditingController(
      text: o?.imageUrl ?? 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&q=80',
    );
    _colorNameController = TextEditingController(text: o?.colorName ?? 'สีม่วงสดใส');
    _colorHexController = TextEditingController(text: o?.colorHex ?? '#7A1CAC');

    if (o != null) {
      _selectedOccasion = o.occasion;
      _selectedColorCategory = o.colorCategory;
      _matchScore = o.matchScore;
      _selectedShapes.clear();
      _selectedShapes.addAll(o.bodyShapes);

      for (var item in o.items) {
        _clothingItems.add({
          'category': item.category,
          'name': item.name,
          'colorName': item.colorName,
          'colorHex': item.colorHex,
        });
      }

      o.stylingTips.forEach((key, tip) {
        _stylingTips[key] = {
          'tipTitle': tip.tipTitle,
          'tipContent': tip.tipContent,
          'highlightFeature': tip.highlightFeature,
          'luckyColorSynergy': tip.luckyColorSynergy,
        };
      });
    } else {
      // Default items for new outfit
      _clothingItems.addAll([
        {'category': 'Top', 'name': 'เสื้อเชิ้ตคอปกผ้าฝรั่งเศส', 'colorName': 'ขาว', 'colorHex': '#FFFFFF'},
        {'category': 'Bottom', 'name': 'กางเกงสแล็คทรงกระบอกเล็ก', 'colorName': 'ดำ', 'colorHex': '#1E1E1E'},
      ]);
      _populateDefaultTips();
    }
  }

  void _populateDefaultTips() {
    for (var shape in _allShapes) {
      if (!_stylingTips.containsKey(shape)) {
        _stylingTips[shape] = {
          'tipTitle': 'เทคนิคเสริมความมั่นใจ ($shape)',
          'tipContent': 'การเลือกชุดที่มีโครงสร้างชัดเจนช่วยเน้นจุดเด่นของสรีระให้ดูสมส่วนและดูโปร่งสบายตา',
          'highlightFeature': 'ปรับสัดส่วนให้สมดุล',
          'luckyColorSynergy': 'คู่สีมงคลประจำชุดช่วยเสริมความสง่างามตลอดวัน',
        };
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    _colorNameController.dispose();
    _colorHexController.dispose();
    super.dispose();
  }

  void _addClothingItem() {
    setState(() {
      _clothingItems.add({
        'category': 'Top',
        'name': '',
        'colorName': 'สีสุภาพ',
        'colorHex': '#7A1CAC',
      });
    });
  }

  void _removeClothingItem(int index) {
    setState(() {
      _clothingItems.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedShapes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกรูปร่างที่เหมาะสมอย่างน้อย 1 แบบ'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final outfitProv = context.read<OutfitProvider>();
    final token = auth.token;
    if (token == null) return;

    setState(() => _isSaving = true);

    // Prepare payload
    final payload = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'imageUrl': _imageUrlController.text.trim(),
      'occasion': _selectedOccasion,
      'bodyShapes': _selectedShapes.toList(),
      'colorCategory': _selectedColorCategory,
      'colorName': _colorNameController.text.trim(),
      'colorHex': _colorHexController.text.trim(),
      'matchScore': _matchScore,
      'items': _clothingItems.map((item) => {
            'category': item['category'] ?? 'Top',
            'name': (item['name'] ?? '').isEmpty ? 'ชิ้นส่วนเสื้อผ้า' : item['name'],
            'colorName': item['colorName'] ?? 'สีสุภาพ',
            'colorHex': item['colorHex'] ?? '#000000',
          }).toList(),
      'stylingTips': _stylingTips,
    };

    bool success;
    if (widget.outfit == null) {
      success = await outfitProv.createOutfit(token, payload);
    } else {
      success = await outfitProv.updateOutfit(token, widget.outfit!.id, payload);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.outfit == null
                ? 'เพิ่มชุดเสื้อผ้าใหม่เข้าสู่ฐานข้อมูลสำเร็จ!'
                : 'บันทึกการแก้ไขชุดเสื้อผ้าสำเร็จ!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(outfitProv.errorMessage ?? 'บันทึกข้อมูลไม่สำเร็จ'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
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

    final isEditing = widget.outfit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขชุดเสื้อผ้า (Edit)' : 'เพิ่มชุดเสื้อผ้าใหม่ (Add Outfit)'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _submitForm,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check, color: Colors.white),
            label: Text(
              isEditing ? 'บันทึก' : 'เพิ่มชุด',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview Image Card
            _buildImagePreviewSection(),
            const SizedBox(height: 16),

            // Basic Info Section
            _buildSectionCard(
              title: 'ข้อมูลพื้นฐานของชุด',
              icon: Icons.checkroom,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อชุดเสื้อผ้า *',
                    hintText: 'เช่น Minimalist Cream Blazer & Wide Pants',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณาระบุชื่อชุด' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL ลิงก์รูปภาพ *',
                    hintText: 'https://images.unsplash.com/...',
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณาระบุ URL รูปภาพ' : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'คำอธิบายชุดเสื้อผ้า',
                    hintText: 'อธิบายจุดเด่น บรรยากาศ และโทนของชุด...',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Occasion & Filter Settings
            _buildSectionCard(
              title: 'โอกาสและเกณฑ์การแมทช์',
              icon: Icons.tune,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedOccasion,
                  decoration: const InputDecoration(
                    labelText: 'โอกาส / สถานที่ (Occasion) *',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  items: _availableOccasions
                      .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedOccasion = v);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'รูปร่างที่แนะนำสำหรับชุดนี้ (เลือกได้หลายแบบ):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allShapes.map((shape) {
                    final isSelected = _selectedShapes.contains(shape);
                    return FilterChip(
                      label: Text(shape),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryLightOf(context),
                      checkmarkColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryOf(context),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedShapes.add(shape);
                          } else {
                            if (_selectedShapes.length > 1) {
                              _selectedShapes.remove(shape);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('คะแนนความเข้ากัน (Match Score):', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_matchScore%',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _matchScore.toDouble(),
                  min: 70,
                  max: 100,
                  divisions: 30,
                  label: '$_matchScore%',
                  activeColor: AppTheme.primaryColor,
                  onChanged: (val) {
                    setState(() => _matchScore = val.round());
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Color Category & Theme
            _buildSectionCard(
              title: 'หมวดหมู่สีและโทนสีมงคล',
              icon: Icons.palette_outlined,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedColorCategory,
                  decoration: const InputDecoration(
                    labelText: 'หมวดหมู่สีมงคล',
                    prefixIcon: Icon(Icons.auto_awesome),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'work', child: Text('เสริมงาน (Work)')),
                    DropdownMenuItem(value: 'wealth', child: Text('เสริมการเงิน (Wealth)')),
                    DropdownMenuItem(value: 'love', child: Text('เสริมความรัก (Love)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedColorCategory = v);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _colorNameController,
                        decoration: const InputDecoration(
                          labelText: 'ชื่อเฉดสี',
                          hintText: 'เช่น ครีมเบจ, ม่วงไวโอเล็ต',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _colorHexController,
                        decoration: const InputDecoration(
                          labelText: 'Hex Code',
                          hintText: '#7A1CAC',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildColorPresets(),
              ],
            ),
            const SizedBox(height: 16),

            // Clothing Pieces Breakdown
            _buildClothingItemsSection(),
            const SizedBox(height: 16),

            // Styling Tips Section
            _buildStylingTipsSection(),
            const SizedBox(height: 32),

            // Bottom Submit Button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _submitForm,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(
                _isSaving
                    ? 'กำลังบันทึกลงฐานข้อมูล...'
                    : (isEditing ? 'บันทึกการแก้ไขชุดเสื้อผ้า' : 'ยืนยันเพิ่มชุดเสื้อผ้าใหม่'),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreviewSection() {
    final url = _imageUrlController.text.trim();
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text('ไม่พบรูปภาพหรือลิงก์ไม่ถูกต้อง', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
            },
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('ภาพตัวอย่างสด', style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPresets() {
    final presets = [
      {'name': 'Royal Purple', 'hex': '#7A1CAC'},
      {'name': 'Midnight Plum', 'hex': '#2E073F'},
      {'name': 'Soft Lilac', 'hex': '#EBD3F8'},
      {'name': 'Warm Beige', 'hex': '#E8D8C8'},
      {'name': 'Emerald Green', 'hex': '#10B981'},
      {'name': 'Sky Blue', 'hex': '#3B82F6'},
      {'name': 'Coral Pink', 'hex': '#F472B6'},
      {'name': 'Classic Black', 'hex': '#1F2937'},
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: presets.map((p) {
        final hexStr = p['hex']!;
        Color color;
        try {
          color = Color(int.parse(hexStr.replaceFirst('#', '0xFF')));
        } catch (_) {
          color = Colors.grey;
        }
        return ActionChip(
          avatar: CircleAvatar(backgroundColor: color, radius: 8),
          label: Text(p['name']!, style: const TextStyle(fontSize: 11)),
          onPressed: () {
            setState(() {
              _colorNameController.text = p['name']!;
              _colorHexController.text = p['hex']!;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildClothingItemsSection() {
    return _buildSectionCard(
      title: 'ชิ้นส่วนเสื้อผ้า (${_clothingItems.length} ชิ้น)',
      icon: Icons.list_alt,
      trailing: TextButton.icon(
        onPressed: _addClothingItem,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('เพิ่มชิ้นส่วน'),
      ),
      children: [
        if (_clothingItems.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('ยังไม่มีชิ้นส่วนเสื้อผ้า กดปุ่ม "เพิ่มชิ้นส่วน" ด้านบนเพื่อระบุ',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ..._clothingItems.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderOf(context)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: item['category'],
                        decoration: const InputDecoration(labelText: 'ประเภท', isDense: true),
                        items: _clothingCategories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => item['category'] = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: item['name'],
                        decoration: const InputDecoration(labelText: 'ชื่อชิ้นส่วน', isDense: true),
                        onChanged: (v) => item['name'] = v,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.dangerColor),
                      onPressed: () => _removeClothingItem(idx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: item['colorName'],
                        decoration: const InputDecoration(labelText: 'สีชิ้นส่วน', isDense: true),
                        onChanged: (v) => item['colorName'] = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: item['colorHex'],
                        decoration: const InputDecoration(labelText: 'Hex', isDense: true),
                        onChanged: (v) => item['colorHex'] = v,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStylingTipsSection() {
    return _buildSectionCard(
      title: 'คำแนะนำสไตล์ลิสต์แยกตามสรีระ',
      icon: Icons.lightbulb_outline,
      trailing: TextButton.icon(
        onPressed: () {
          setState(() {
            _populateDefaultTips();
          });
        },
        icon: const Icon(Icons.auto_fix_high, size: 16),
        label: const Text('ใส่ค่าแนะนำอัตโนมัติ'),
      ),
      children: [
        ..._allShapes.map((shape) {
          final tip = _stylingTips[shape] ??= {
            'tipTitle': 'เคล็ดลับสำหรับหุ่น $shape',
            'tipContent': 'เลือกใส่เพื่อเสริมสัดส่วน',
            'highlightFeature': 'สมดุลรูปร่าง',
            'luckyColorSynergy': '',
          };

          final isTargetShape = _selectedShapes.contains(shape);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isTargetShape
                  ? AppTheme.primaryLightOf(context).withValues(alpha: 0.3)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isTargetShape ? AppTheme.primaryColor.withValues(alpha: 0.5) : AppTheme.borderOf(context),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isTargetShape ? AppTheme.primaryColor : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        shape,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isTargetShape ? '(หุ่นที่แนะนำสำหรับชุดนี้)' : '(คำแนะนำทางเลือก)',
                        style: TextStyle(
                          fontSize: 11,
                          color: isTargetShape ? AppTheme.primaryColor : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: tip['tipTitle'],
                  decoration: const InputDecoration(labelText: 'หัวข้อคำแนะนำ', isDense: true),
                  onChanged: (v) => tip['tipTitle'] = v,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: tip['tipContent'],
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'เนื้อหาคำแนะนำสไตล์ลิสต์', isDense: true),
                  onChanged: (v) => tip['tipContent'] = v,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: tip['highlightFeature'],
                        decoration: const InputDecoration(labelText: 'จุดเด่นที่เน้น', isDense: true),
                        onChanged: (v) => tip['highlightFeature'] = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: tip['luckyColorSynergy'],
                        decoration: const InputDecoration(labelText: 'พลังสีมงคล', isDense: true),
                        onChanged: (v) => tip['luckyColorSynergy'] = v,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
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
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }
}
