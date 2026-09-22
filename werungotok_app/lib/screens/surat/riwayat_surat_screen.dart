import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';
import '../../models/surat_model.dart';
import '../../services/surat_service.dart';
import '../../widgets/main_scaffold.dart';

Color statusColorRiwayat(String status) {
  switch (status) {
    case 'selesai':
      return AppColors.primaryGreen;
    case 'ditolak':
      return AppColors.red;
    default:
      return Colors.orange;
  }
}

String formatTanggalRiwayat(String iso) {
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

class RiwayatSuratScreen extends StatefulWidget {
  const RiwayatSuratScreen({super.key});

  @override
  State<RiwayatSuratScreen> createState() => _RiwayatSuratScreenState();
}

class _RiwayatSuratScreenState extends State<RiwayatSuratScreen> {
  late Future<List<SuratModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = SuratService(context.read<ApiClient>()).riwayat();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Riwayat Surat',
      showBackButton: true,
      navIndex: NavTab.riwayat,
      body: FutureBuilder<List<SuratModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Gagal memuat: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          }
          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(
                child: Text('Belum ada pengajuan surat.',
                    style: TextStyle(color: Colors.white)));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            itemCount: data.length,
            itemBuilder: (context, i) {
              final s = data[i];
              // Kartu ringkas: nama + tanggal + status. Klik untuk detail.
              return BubbleCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => RiwayatDetailScreen(surat: s)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.namaSurat,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(
                                'Diajukan: ${formatTanggalRiwayat(s.createdAt)}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColorRiwayat(s.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColorRiwayat(s.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.black38),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Detail pengajuan sisi warga: info surat + Lihat/Download surat hasil.
/// Tanpa KTP. Kalau ditolak, hanya menampilkan alasan (tanpa tombol).
class RiwayatDetailScreen extends StatelessWidget {
  final SuratModel surat;
  const RiwayatDetailScreen({super.key, required this.surat});

  Future<void> _lihatSurat(BuildContext context) async {
    final url = ApiConfig.fileUrl(surat.fileHasil);
    if (url.isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _unduhSurat(BuildContext context) {
    final url = ApiConfig.fileUrl(surat.fileHasil);
    if (url.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengunduh surat...')),
    );
    FileDownloader.downloadFile(
      url: url,
      name: 'surat_${surat.namaSurat.replaceAll(' ', '_')}_${surat.id}.pdf',
      onDownloadCompleted: (savedPath) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Surat tersimpan, membuka file...'),
              backgroundColor: AppColors.primaryGreen),
        );
        OpenFilex.open(savedPath);
      },
      onDownloadError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal mengunduh: $error'),
              backgroundColor: AppColors.red),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = surat;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Detail Pengajuan',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BubbleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Detail Surat',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColorRiwayat(s.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s.status.toUpperCase(),
                          style: TextStyle(
                              color: statusColorRiwayat(s.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _row('Jenis', s.namaSurat),
                _row('Keperluan', s.keperluan.isEmpty ? '-' : s.keperluan),
                _row('Diajukan', formatTanggalRiwayat(s.createdAt)),
                if (s.catatanAdmin != null && s.catatanAdmin!.isNotEmpty)
                  _row('Catatan', s.catatanAdmin!),
                const SizedBox(height: 20),
                // Aksi menyesuaikan status
                if (s.status == 'selesai' && s.fileHasil != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _lihatSurat(context),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Lihat Surat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _unduhSurat(context),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download Surat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ] else if (s.status == 'ditolak') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      s.catatanAdmin != null && s.catatanAdmin!.isNotEmpty
                          ? 'Pengajuan ditolak. Alasan: ${s.catatanAdmin}'
                          : 'Pengajuan ditolak oleh admin.',
                      style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 13,
                          height: 1.4),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      'Pengajuan sedang diproses. Surat hasil akan muncul di '
                      'sini setelah selesai.',
                      style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                          height: 1.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 90,
              child: Text(label,
                  style:
                      const TextStyle(fontSize: 12.5, color: Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
