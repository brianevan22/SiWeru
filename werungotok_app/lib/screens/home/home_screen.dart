import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';
import '../../models/info_surat_setting_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../services/content_service.dart';
import '../../widgets/main_scaffold.dart';
import '../surat/info_surat_screen.dart';
import '../surat/surat_form_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isAdmin = user?.isAdmin ?? false;

    return MainScaffold(
      title: 'Beranda',
      navIndex: NavTab.beranda,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Sambutan =====
            FadeSlideIn(
              child: BubbleCard(
                padding:
                    const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          height: 1.25,
                        ),
                        children: [
                          const TextSpan(text: 'Pelayanan Digital\n'),
                          TextSpan(
                            text: 'Kelurahan Werungotok',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user == null
                          ? 'Layanan mandiri masyarakat yang cepat, transparan, dan inovatif.'
                          : 'Halo, ${user.nama ?? user.username}. Ada yang bisa kami bantu hari ini?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ===== Kartu layanan surat =====
            FadeSlideIn(
              delayMs: 120,
              child: BubbleCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              AppColors.primaryGreen,
                              AppColors.greenLight
                            ]),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.mail_rounded,
                              color: Colors.white, size: 23),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pelayanan Surat',
                                  style: TextStyle(
                                      fontSize: 18.5,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 2),
                              Text(
                                'Alur, syarat, dan pengajuan surat.',
                                style: TextStyle(
                                    fontSize: 13, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _zoomGambar(
                          context,
                          'assets/images/alur_pelayanan.png',
                          'Alur Pelayanan Digital'),
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'assets/images/alur_pelayanan.png',
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.zoom_in_map_rounded,
                                      color: Colors.white, size: 15),
                                  SizedBox(width: 4),
                                  Text('Ketuk untuk perbesar',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10.5)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isAdmin)
                      Row(
                        children: [
                          Expanded(
                            child: _SoftButton(
                              label: 'Lihat Informasi',
                              icon: Icons.menu_book_rounded,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const InfoSuratScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GradientButton(
                              label: 'Kelola Surat',
                              icon: Icons.dashboard_rounded,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminDashboardScreen(initialTab: 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _SoftButton(
                              label: 'Lihat Syarat',
                              icon: Icons.fact_check_rounded,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const InfoSuratScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GradientButton(
                              label: 'Buat Surat',
                              icon: Icons.edit_document,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const SuratFormScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ===== Kartu Posyandu =====
            const FadeSlideIn(
              delayMs: 180,
              child: _PosyanduCard(),
            ),
            const SizedBox(height: 18),

            // ===== Info singkat =====
            FadeSlideIn(
              delayMs: 240,
              child: BubbleCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.lime.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.lightbulb_rounded,
                          color: AppColors.primaryGreen, size: 21),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Pastikan KTP sudah terverifikasi admin sebelum mengajukan surat. '
                        'Hasil surat dikirim dalam bentuk PDF.',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Buka gambar aset penuh layar dengan zoom & geser.
void _zoomGambar(BuildContext context, String assetPath, String title) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5,
              child: Center(
                child: Image.asset(assetPath, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 12,
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
          Positioned(
            top: 32,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Tombol sekunder bergaya lembut, senada tema.
class _SoftButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SoftButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: AppColors.primaryGreen),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu Posyandu: menampilkan gambar jadwal (dari server jika admin sudah
/// mengunggah, kalau belum pakai aset bawaan), bisa di-zoom, plus tombol
/// Edit Foto untuk admin.
class _PosyanduCard extends StatefulWidget {
  const _PosyanduCard();

  @override
  State<_PosyanduCard> createState() => _PosyanduCardState();
}

class _PosyanduCardState extends State<_PosyanduCard> {
  late Future<InfoSuratSettingModel> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentService(context.read<ApiClient>()).infoSetting();
  }

  void _reload() {
    setState(() {
      _future = ContentService(context.read<ApiClient>()).infoSetting();
    });
  }

  Future<void> _editFoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    try {
      await AdminService(context.read<ApiClient>())
          .saveInfoSetting(gambarPosyanduPath: path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Foto jadwal posyandu diperbarui.'),
            backgroundColor: AppColors.primaryGreen),
      );
      _reload();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.firstError), backgroundColor: AppColors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().currentUser?.isAdmin ?? false;

    return BubbleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primaryGreen, AppColors.lime]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.vaccines_rounded,
                    color: Colors.white, size: 23),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Posyandu',
                        style: TextStyle(
                            fontSize: 18.5, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Jadwal kegiatan Posyandu terbaru.',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<InfoSuratSettingModel>(
            future: _future,
            builder: (context, snapshot) {
              final url = ApiConfig.fileUrl(snapshot.data?.gambarPosyandu);
              final ImageProvider provider = url.isNotEmpty
                  ? NetworkImage(url)
                  : const AssetImage('assets/images/jadwal_posyandu.jpg')
                      as ImageProvider;
              return InkWell(
                onTap: () =>
                    _zoomGambarProvider(context, provider, 'Jadwal Posyandu'),
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image(
                        image: provider,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 140,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Text('Gambar jadwal belum tersedia'),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in_map_rounded,
                                color: Colors.white, size: 15),
                            SizedBox(width: 4),
                            Text('Ketuk untuk perbesar',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10.5)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (isAdmin) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _editFoto,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Foto Jadwal'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text('Format JPG/PNG, ukuran maksimal 4 MB.',
                style: TextStyle(fontSize: 11, color: Colors.black45)),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lime.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_rounded,
                    size: 17, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Apabila jadwal berubah, akan diinformasikan melalui '
                    'PKK dan kader Posyandu.',
                    style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textDark.withOpacity(0.85),
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Zoom untuk ImageProvider (aset maupun network).
void _zoomGambarProvider(
    BuildContext context, ImageProvider provider, String title) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5,
              child: Center(child: Image(image: provider, fit: BoxFit.contain)),
            ),
          ),
          Positioned(
            top: 40,
            left: 12,
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ),
          Positioned(
            top: 32,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    ),
  );
}
