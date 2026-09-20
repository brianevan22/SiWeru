import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna diselaraskan dengan logo Werungotok Service:
/// hijau tua -> hijau terang, dengan aksen lime.
class AppColors {
  // ===== Warna utama (dari logo) =====
  static const greenDark = Color(0xFF0E6B2A);
  static const primaryGreen = Color(0xFF17963B);
  static const greenLight = Color(0xFF2FBF55);
  static const lime = Color(0xFF8BD130);
  static const limeLight = Color(0xFFA8E24D);

  // ===== Warna pendukung =====
  static const primaryBlue = Color(0xFF1E6FD9);
  static const pink = Color(0xFFDB2777);
  static const yellow = Color(0xFFCA8A04);
  static const red = Color(0xFFDC2626);
  static const textDark = Color(0xFF14311F);
  static const textMuted = Color(0xFF5B7265);

  // ===== Latar gradient hijau natural yang lembut =====
  static const bgBlue = Color(0xFFE4F3E6);
  static const bgPurple = Color(0xFFD6EEDA);
  static const bgGreen = Color(0xFFC7E7CD);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          secondary: AppColors.lime,
        ),
        // Font aplikasi: Poppins (via google_fonts).
        // Ukuran teks dinaikkan agar lebih jelas dibaca di HP.
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineMedium: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark),
          titleLarge: GoogleFonts.poppins(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark),
          titleMedium: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
          bodyLarge:
              GoogleFonts.poppins(fontSize: 16, color: AppColors.textDark),
          bodyMedium:
              GoogleFonts.poppins(fontSize: 15, color: AppColors.textDark),
          bodySmall:
              GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textMuted),
          labelLarge:
              GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.textDark,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 2,
            shadowColor: AppColors.primaryGreen.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.35)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.75),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          hintStyle:
              const TextStyle(fontSize: 14.5, color: AppColors.textMuted),
          labelStyle: const TextStyle(fontSize: 15, color: AppColors.textMuted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppColors.primaryGreen, width: 1.6),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          contentTextStyle: const TextStyle(fontSize: 14.5),
        ),
        chipTheme: ChipThemeData(
          labelStyle: const TextStyle(fontSize: 13.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
}

/// Latar gradient hijau natural yang lembut dan terang.
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgBlue, AppColors.bgPurple, AppColors.bgGreen],
        ),
      ),
      child: child,
    );
  }
}

/// Kartu efek "glass" dengan sudut membulat seperti logo.
class BubbleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const BubbleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withOpacity(0.9)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greenDark.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Animasi masuk: muncul perlahan sambil naik sedikit.
/// Dipakai untuk kartu-kartu agar halaman terasa hidup.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int delayMs;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.offsetY = 24,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        // Tunda halus tanpa timer: bagian awal animasi dipakai sebagai jeda.
        final d = delayMs / (500 + delayMs);
        final p = t <= d ? 0.0 : (t - d) / (1 - d);
        return Opacity(
          opacity: p.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, offsetY * (1 - p)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Tombol/kartu yang mengecil sedikit saat ditekan — memberi umpan balik.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Tombol utama bergaya gradient hijau-lime seperti logo.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool expanded;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: expanded ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryGreen, AppColors.greenLight],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
