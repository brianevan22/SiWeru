import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_button.dart';
import '../admin/admin_dashboard_screen.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => auth.isAdmin
              ? const AdminDashboardScreen()
              : const HomeScreen(),
        ),
        (route) => false,
      );
    } on ApiException catch (e) {
      _showError(e.firstError);
    } catch (e) {
      _showError('Gagal login! Username tidak terdaftar atau password salah.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: BubbleCard(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fingerprint,
                          size: 40, color: AppColors.primaryBlue),
                      const SizedBox(height: 8),
                      const Text(
                        'Login Warga',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 24),
                      LoadingButton(
                        isLoading: _loading,
                        label: 'Masuk',
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum punya akun? '),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()),
                            ),
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
