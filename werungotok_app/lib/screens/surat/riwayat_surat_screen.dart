import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';
import '../../models/surat_model.dart';
import '../../services/surat_service.dart';
import '../../widgets/main_scaffold.dart';

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

  Color _statusColor(String status) {
    switch (status) {
      case 'selesai':
        return AppColors.primaryGreen;
      case 'ditolak':
        return AppColors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatTanggal(String iso) {
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

  Future<void> _unduhSurat(SuratModel s) async {
    final url = ApiConfig.fileUrl(s.fileHasil);
    if (url.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengunduh surat...')),
    );

    FileDownloader.downloadFile(
      url: url,
      name: 'surat_${s.namaSurat.replaceAll(' ', '_')}_${s.id}.pdf',
      onDownloadCompleted: (savedPath) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Surat tersimpan, membuka file...'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        OpenFilex.open(savedPath);
      },
      onDownloadError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh: $error'),
            backgroundColor: AppColors.red,
          ),
        );
      },
    );
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
            return Center(child: Text('Gagal memuat: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada pengajuan surat.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            itemCount: data.length,
            itemBuilder: (context, i) {
              final s = data[i];
              return BubbleCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(s.namaSurat,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(s.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s.status.toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(s.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Diajukan: ${_formatTanggal(s.createdAt)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                    if (s.catatanAdmin != null && s.catatanAdmin!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('Catatan admin: ${s.catatanAdmin}',
                            style: const TextStyle(fontSize: 12.5)),
                      ),
                    if (s.status == 'selesai' && s.fileHasil != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _unduhSurat(s),
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text('Unduh Surat PDF',
                                style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
