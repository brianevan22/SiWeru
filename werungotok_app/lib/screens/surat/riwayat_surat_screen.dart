import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Riwayat Surat',
      showBackButton: true,
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
            return const Center(
                child: Text('Belum ada pengajuan surat.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
                        Text(s.jenisSurat,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
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
                    Text('Diajukan: ${s.createdAt}',
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
                        child: ElevatedButton.icon(
                          onPressed: () => launchUrl(
                            Uri.parse(ApiConfig.fileUrl(s.fileHasil)),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                          label: const Text('Unduh Surat PDF',
                              style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 10),
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
