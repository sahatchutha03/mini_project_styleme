import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/style_filter_provider.dart';
import '../../config/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? accessDeniedMessage;

  const LoginScreen({super.key, this.accessDeniedMessage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@styleme.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;
  String? _accessDeniedMessage;

  @override
  void initState() {
    super.initState();
    _accessDeniedMessage = widget.accessDeniedMessage;
    if (widget.accessDeniedMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.block, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.accessDeniedMessage!,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.dangerColor,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _accessDeniedMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success && authProvider.user != null && authProvider.user!.defaultBodyShape.isNotEmpty) {
      Provider.of<StyleFilterProvider>(context, listen: false)
          .setBodyShape(authProvider.user!.defaultBodyShape);
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'เข้าสู่ระบบไม่สำเร็จ'),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // โลโก้แอป
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.checkroom, size: 50, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'StyleMe',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryOf(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'The Perfect Fit — ออกแบบสไตล์ที่ใช่ตามตัวคุณ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryOf(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ข้อความแจ้งเตือนปฏิเสธการเข้าถึง Admin
                  if (_accessDeniedMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.dangerColor.withValues(alpha: 0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.dangerColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.gpp_bad_rounded, color: AppTheme.dangerColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _accessDeniedMessage!,
                                  style: const TextStyle(
                                    color: AppTheme.dangerColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'เฉพาะผู้ดูแลระบบ (Admin) เท่านั้นที่สามารถเข้าถึงได้',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ช่องกรอก Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'อีเมล (Email)',
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

                  // ช่องกรอก Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'รหัสผ่าน (Password)',
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
                        return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ปุ่มเข้าสู่ระบบ
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _submitLogin,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('เข้าสู่ระบบ (Login)'),
                  ),
                  const SizedBox(height: 16),

                  // ลิงก์ไปหน้าสมัครสมาชิก
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ยังไม่มีบัญชีผู้ใช้? ',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'สมัครสมาชิกใหม่',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'บัญชีทดลองเข้าสู่ระบบ (Demo Accounts):',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.admin_panel_settings, size: 16, color: AppTheme.primaryColor),
                        label: const Text('Admin (ผู้ดูแลระบบ)', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setState(() {
                            _emailController.text = 'admin@styleme.com';
                            _passwordController.text = '123456';
                            _accessDeniedMessage = null;
                          });
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.person, size: 16, color: AppTheme.secondaryColor),
                        label: const Text('User (สมาชิกทดลอง)', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setState(() {
                            _emailController.text = 'test_user@gmail.com';
                            _passwordController.text = '123456';
                            _accessDeniedMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
