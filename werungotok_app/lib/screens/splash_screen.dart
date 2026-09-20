import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _init();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    // Beri waktu animasi tampil sebentar agar tidak berkedip.
    final hasil = await Future.wait([
      auth.tryAutoLogin(),
      Future.delayed(const Duration(milliseconds: 1600)),
    ]);
    if (!mounted) return;
    // Semua peran diarahkan ke beranda.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
    hasil.length; // hindari peringatan variabel tak terpakai
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.greenDark,
              AppColors.primaryGreen,
              AppColors.greenLight,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Lingkaran dekoratif lembut di latar
            Positioned(
              top: -90,
              right: -70,
              child: _blob(230, Colors.white.withOpacity(0.08)),
            ),
            Positioned(
              bottom: -110,
              left: -80,
              child: _blob(280, AppColors.limeLight.withOpacity(0.15)),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo: muncul membesar + denyut halus
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _logoCtrl,
                      curve: Curves.elasticOut,
                    ),
                    child: FadeTransition(
                      opacity: _logoCtrl,
                      child: AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (context, child) {
                          final s = 1 + (_pulseCtrl.value * 0.04);
                          return Transform.scale(scale: s, child: child);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(38),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(38),
                            child: Image.asset(
                              'assets/images/siweru.png',
                              width: 160,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 160,
                                height: 160,
                                color: Colors.white,
                                child: const Icon(Icons.location_city_rounded,
                                    size: 80, color: AppColors.primaryGreen),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeSlideIn(
                    delayMs: 300,
                    child: Column(
                      children: [
                        const Text(
                          'Si Weru',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pelayanan Surat Kelurahan',
                          style: TextStyle(
                            fontSize: 14.5,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeSlideIn(
                    delayMs: 600,
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor: AlwaysStoppedAnimation(
                            AppColors.limeLight.withOpacity(0.95)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Nama kelurahan di bawah
            Positioned(
              left: 0,
              right: 0,
              bottom: 36,
              child: FadeSlideIn(
                delayMs: 800,
                child: Text(
                  'Kelurahan Werungotok — Nganjuk',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
