import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/api_config.dart';
import '../core/app_theme.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/surat/info_surat_screen.dart';
import '../screens/posyandu/posyandu_screen.dart';
import '../screens/bank_sampah/bank_sampah_screen.dart';
import '../screens/profil/profil_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

/// Pengganti header.js + renderHeader() dari template HTML.
/// Dipakai membungkus semua halaman supaya tampilan header/drawer konsisten.
class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;
  final List<Widget>? actions;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: const _SidebarDrawer(),
        appBar: _GlassAppBar(
          title: title,
          showBackButton: showBackButton,
          user: auth.currentUser,
          actions: actions,
        ),
        body: SafeArea(child: body),
      ),
    );
  }
}

class _GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final UserModel? user;
  final List<Widget>? actions;

  const _GlassAppBar({
    required this.title,
    required this.showBackButton,
    required this.user,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: Colors.white.withOpacity(0.85),
          elevation: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              const Icon(Icons.location_city, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            ...?actions,
            _ProfileMenu(user: user),
            const SizedBox(width: 8),
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
      return TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        ),
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('Login'),
      );
    }

    // Disalin ke variabel lokal supaya Dart bisa melakukan null-promotion
    // (field publik seperti `user` tidak bisa dipromosikan otomatis).
    final u = user!;

    return PopupMenuButton<String>(
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
        const PopupMenuItem(value: 'profil', child: Text('Pengaturan')),
        if (u.isAdmin)
          const PopupMenuItem(value: 'admin', child: Text('Panel Admin')),
        const PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
          backgroundImage: (u.pasFoto != null && u.pasFoto != '')
              ? CachedNetworkImageProvider(ApiConfig.fileUrl(u.pasFoto))
              : null,
          child: (u.pasFoto == null || u.pasFoto == '')
              ? const Icon(Icons.person, color: AppColors.primaryGreen)
              : null,
        ),
      ),
    );
  }
}

class _SidebarDrawer extends StatelessWidget {
  const _SidebarDrawer();

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label, Color color, Widget page) {
      return ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
        },
      );
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/nganjuk_logo.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Werungotok',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            item(Icons.mark_email_read, 'Pelayanan Surat', AppColors.primaryBlue,
                const InfoSuratScreen()),
            item(Icons.child_care, 'Posyandu', AppColors.pink,
                const PosyanduScreen()),
            item(Icons.recycling, 'Bank Sampah', AppColors.yellow,
                const BankSampahScreen()),
            const Divider(),
            item(Icons.home, 'Beranda', AppColors.primaryGreen,
                const HomeScreen()),
          ],
        ),
      ),
    );
  }
}
