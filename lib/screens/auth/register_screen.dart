import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/style_filter_provider.dart';
import '../../config/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedBodyShape = 'Pear';
  bool _obscurePassword = true;

  final List<Map<String, String>> _bodyShapes = [
    {'key': 'Pear', 'label': 'ลูกแพร์ (Pear)'},
    {'key': 'Hourglass', 'label': 'นาฬิกาทราย (Hourglass)'},
    {'key': 'Apple', 'label': 'แอปเปิ้ล (Apple)'},
    {'key': 'Rectangle', 'label': 'ทรงตรง (Rectangle)'},
    {'key': 'Inverted Triangle', 'label': 'สามเหลี่ยมคว่ำ (Inverted Triangle)'},
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      defaultBodyShape: _selectedBodyShape,
    );

    if (!mounted) return;

    if (success) {
      Provider.of<StyleFilterProvider>(context, listen: false)
          .setBodyShape(_selectedBodyShape);
      try {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } catch (_) {}
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'สมัครสมาชิกไม่สำเร็จ'),
          backgroundColor: AppTheme.dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'สร้างบัญชี StyleMe ใหม่',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'กรอกข้อมูลเพื่อรับคำแนะนำสไตล์และสีมงคลเฉพาะคุณ',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
                const SizedBox(height: 28),

                // ชื่อ-นามสกุล
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ-นามสกุล',
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'พิมพ์ลดา วาณิชย์',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกชื่อ-นามสกุล';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // อีเมล
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'อีเมล',
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'example@email.com',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }
                    if (!value.contains('@')) {
                      return 'รูปแบบอีเมลไม่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // รหัสผ่าน
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }
                    if (value.length < 6) {
                      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // เลือกลักษณะรูปร่างเริ่มต้น
                const Text(
                  'เลือกลักษณะรูปร่างของคุณ:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBodyShape,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.accessibility_new_outlined),
                  ),
                  items: _bodyShapes.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['key'],
                      child: Text(
                        item['label']!,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedBodyShape = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),

                // ปุ่มยืนยันสมัครสมาชิก
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _submitRegister,
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                        : const Text('ลงทะเบียนและเข้าสู่ระบบ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
