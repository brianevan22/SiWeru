import 'dart:ui';
import 'package:flutter/material.dart';

/// Palet warna diambil dari style.css template asli:
/// gradient body: #e0f2fe -> #fdf4ff -> #dcfce3
/// bubble-card: putih transparan + blur
class AppColors {
  static const bgBlue = Color(0xFFE0F2FE);
  static const bgPurple = Color(0xFFFDF4FF);
  static const bgGreen = Color(0xFFDCFCE3);

  static const primaryGreen = Color(0xFF16A34A); // green-600
  static const primaryBlue = Color(0xFF2563EB); // blue-600
  static const pink = Color(0xFFDB2777); // pink-600
  static const yellow = Color(0xFFCA8A04); // yellow-600
  static const red = Color(0xFFDC2626); // red-600
  static const textDark = Color(0xFF1F2937);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.textDark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.6),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      );
}

/// Background gradient dekat-identik dengan `body` di style.css.
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

/// Kartu efek "glass/bubble" persis seperti class `.bubble-card` di CSS asli.
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
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 25,
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
