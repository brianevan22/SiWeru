import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/api_config.dart';
import '../core/app_theme.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/surat/info_surat_screen.dart';
import '../screens/surat/riwayat_surat_screen.dart';
import '../screens/profil/profil_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

/// Indeks tab bawah. -1 berarti halaman tanpa tab aktif.
class NavTab {
  static const none = -1;
  static const layanan = 0;
  static const beranda = 1;
  static const riwayat = 2;
}

class MainScaffold extends StatelessWidget {
  // title tetap diterima demi kompatibilitas pemanggil lama,
  // namun header kini selalu menampilkan "Kelurahan Werungotok".
  // ignore: unused_field
  final String title;
  final Widget body;
  final bool showBackButton;
  final List<Widget>? actions;
  final int navIndex;
  final bool showBottomNav;
  final Widget? floatingActionButton;

  const MainScaffold({
    super.key,
    this.title = '',
    required this.body,
    this.showBackButton = false,
    this.actions,
    this.navIndex = NavTab.none,
    this.showBottomNav = true,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return WillPopScope(
      onWillPop: () => _handleBack(context),
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          appBar: _GlassAppBar(
            showBackButton: showBackButton,
            user: auth.currentUser,
            actions: actions,
          ),
          body: SafeArea(bottom: false, child: body),
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: showBottomNav
              ? _BottomBar(currentIndex: navIndex, user: auth.currentUser)
              : null,
        ),
      ),
    );
  }

  /// Tombol kembali HP:
  /// - kalau ada halaman di belakang → kembali biasa
  /// - kalau tidak & bukan beranda → ke beranda
  /// - kalau di beranda → konfirmasi keluar aplikasi
  Future<bool> _handleBack(BuildContext context) async {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      return true; // biarkan pop normal
    }
    if (navIndex != NavTab.beranda) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      return false;
    }
    // Di beranda → tanya keluar aplikasi
    final keluar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar Aplikasi?'),
        content: const Text('Apakah Anda ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    return keluar ?? false;
  }
}

class _GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final UserModel? user;
  final List<Widget>? actions;

  const _GlassAppBar({
    required this.showBackButton,
    required this.user,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AppBar(
          backgroundColor: Colors.white.withOpacity(0.88),
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: PressableScale(
                    onTap: () {
                      final nav = Navigator.of(context);
                      if (nav.canPop()) {
                        nav.maybePop();
                      } else {
                        nav.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 20, color: AppColors.primaryGreen),
                    ),
                  ),
                ),
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  'assets/images/nganjuk_logo.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.location_city_rounded,
                      color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kelurahan Werungotok',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            ...?actions,
            _ProfileMenu(user: user),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final UserModel? user;
  const _ProfileMenu({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return PressableScale(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.greenLight],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Text('Login',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ),
      );
    }

    final u = user!;

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) async {
        if (value == 'profil') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfilScreen()),
          );
        } else if (value == 'admin') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else if (value == 'logout') {
          final yakin = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Keluar Akun?'),
              content: const Text('Anda akan keluar dari akun ini.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
          if (yakin != true) return;
          await context.read<AuthProvider>().logout();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profil',
          child: Row(children: [
            Icon(Icons.person_rounded, size: 19, color: AppColors.primaryGreen),
            SizedBox(width: 10),
            Text('Pengaturan'),
          ]),
        ),
        if (u.isAdmin)
          const PopupMenuItem(
            value: 'admin',
            child: Row(children: [
              Icon(Icons.dashboard_rounded,
                  size: 19, color: AppColors.primaryBlue),
              SizedBox(width: 10),
              Text('Panel Admin'),
            ]),
          ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 19, color: AppColors.red),
            SizedBox(width: 10),
            Text('Logout'),
          ]),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.primaryGreen, AppColors.lime],
          ),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white,
          backgroundImage: (u.fotoProfil != null && u.fotoProfil != '')
              ? CachedNetworkImageProvider(ApiConfig.fileUrl(u.fotoProfil))
              : null,
          child: (u.fotoProfil == null || u.fotoProfil == '')
              ? const Icon(Icons.person_rounded,
                  color: AppColors.primaryGreen, size: 22)
              : null,
        ),
      ),
    );
  }
}

/// Bar bawah 3 menu: Pelayanan Surat — Beranda (menonjol) — Riwayat.
/// Untuk admin, menu kanan menjadi Panel Admin.
class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final UserModel? user;

  const _BottomBar({required this.currentIndex, required this.user});

  void _go(BuildContext context, Widget page, {bool root = false}) {
    if (root) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => page),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => page),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = user?.isAdmin ?? false;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(14, 0, 14, 12 + bottomInset),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenDark.withOpacity(0.16),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            height: 78,
            color: Colors.white.withOpacity(0.93),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.description_rounded,
                    label: 'Layanan',
                    active: currentIndex == NavTab.layanan,
                    onTap: () => _go(context, const InfoSuratScreen()),
                  ),
                ),
                Expanded(
                  child: _CenterNavItem(
                    active: currentIndex == NavTab.beranda,
                    onTap: () => _go(context, const HomeScreen(), root: true),
                  ),
                ),
                Expanded(
                  child: isAdmin
                      ? _NavItem(
                          icon: Icons.dashboard_rounded,
                          label: 'Panel',
                          active: currentIndex == NavTab.riwayat,
                          onTap: () =>
                              _go(context, const AdminDashboardScreen()),
                        )
                      : _NavItem(
                          icon: Icons.history_rounded,
                          label: 'Riwayat',
                          active: currentIndex == NavTab.riwayat,
                          onTap: () {
                            if (user == null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            } else {
                              _go(context, const RiwayatSuratScreen());
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryGreen : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding:
                EdgeInsets.symmetric(horizontal: active ? 16 : 10, vertical: 6),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primaryGreen.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: color,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol Beranda di tengah — menonjol seperti aplikasi belanja.
class _CenterNavItem extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _CenterNavItem({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: OverflowBox(
        maxHeight: 100,
        child: Transform.translate(
          offset: const Offset(0, 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: active
                    ? [AppColors.primaryGreen, AppColors.lime]
                    : [AppColors.greenLight, AppColors.limeLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: Colors.white, width: 3.5),
            ),
            child:
                const Icon(Icons.home_rounded, color: Colors.white, size: 27),
          ),
        ),
      ),
    );
  }
}
