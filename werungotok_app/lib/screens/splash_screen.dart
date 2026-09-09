import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import 'home/home_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();
    if (!mounted) return;

    // Sama seperti script.js: kalau admin login, langsung ke panel admin.
    if (auth.isLoggedIn && auth.isAdmin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_city, size: 72, color: AppColors.primaryGreen),
              SizedBox(height: 16),
              Text(
                'Werungotok',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
