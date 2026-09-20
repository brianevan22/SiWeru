import 'package:flutter/material.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';

/// Avatar foto profil kecil untuk daftar (di samping nama).
class SmallAvatar extends StatelessWidget {
  final String? fotoProfil;
  final double radius;
  const SmallAvatar({super.key, required this.fotoProfil, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final url = ApiConfig.fileUrl(fotoProfil);
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty
          ? Icon(Icons.person, color: AppColors.primaryGreen, size: radius)
          : null,
    );
  }
}

/// Buka gambar dari URL secara penuh layar dengan zoom & geser.
void showZoomableNetworkImage(
    BuildContext context, String? path, String title) {
  final url = ApiConfig.fileUrl(path);
  if (url.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gambar tidak tersedia.')),
    );
    return;
  }
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
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stack) => const Center(
                    child: Text('Gagal memuat gambar.',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
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

/// Ubah ISO date "2026-09-18T16:55:19.000000Z" -> "18 Sep 2026, 16:55".
String formatTanggal(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  const bulan = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];
  final d = dt.toLocal();
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${bulan[d.month]} ${d.year}, $hh:$mm';
}

/// Warna status pengajuan surat.
Color statusColor(String status) {
  switch (status) {
    case 'selesai':
      return AppColors.primaryGreen;
    case 'ditolak':
      return AppColors.red;
    default:
      return Colors.orange;
  }
}
