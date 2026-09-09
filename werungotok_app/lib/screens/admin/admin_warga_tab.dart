import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/admin_service.dart';
import '../../widgets/zoomable_image.dart';

class AdminWargaTab extends StatefulWidget {
  const AdminWargaTab({super.key});

  @override
  State<AdminWargaTab> createState() => _AdminWargaTabState();
}

class _AdminWargaTabState extends State<AdminWargaTab> {
  late Future<List<UserModel>> _future;
  final Set<int> _processing = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final service = AdminService(context.read<ApiClient>());
    setState(() {
      _future = service.listWarga();
    });
  }

  Future<void> _verifikasi(UserModel warga, String status) async {
    setState(() => _processing.add(warga.id));
    try {
      final service = AdminService(context.read<ApiClient>());
      await service.verifikasiWarga(warga.id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Status KTP ${warga.nama ?? warga.username} diperbarui!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      _reload();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.firstError), backgroundColor: AppColors.red),
      );
    } finally {
      if (mounted) setState(() => _processing.remove(warga.id));
    }
  }

  Widget _statusChip(String status) {
    final map = {
      'valid': (AppColors.primaryGreen, 'Valid'),
      'invalid': (AppColors.red, 'Ditolak'),
      'unverified': (Colors.orange, 'Menunggu'),
    };
    final (color, label) = map[status] ?? (Colors.grey, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: FutureBuilder<List<UserModel>>(
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
            return const Center(child: Text('Belum ada warga terdaftar.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, i) {
              final w = data[i];
              final isProcessing = _processing.contains(w.id);
              return BubbleCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w.nama ?? w.username,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Text('@${w.username} • ${w.wa ?? '-'}',
                                  style: const TextStyle(
                                      fontSize: 11.5, color: Colors.black54)),
                            ],
                          ),
                        ),
                        _statusChip(w.ktpStatus),
                      ],
                    ),
                    if (w.alamat != null) ...[
                      const SizedBox(height: 6),
                      Text(w.alamat!, style: const TextStyle(fontSize: 12.5)),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ZoomableImage(
                            imageUrl: ApiConfig.fileUrl(w.ktpPhoto),
                            height: 90,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ZoomableImage(
                            imageUrl: ApiConfig.fileUrl(w.pasFoto),
                            height: 90,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (isProcessing)
                      const Center(child: CircularProgressIndicator())
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _verifikasi(w, 'invalid'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.red,
                                side: const BorderSide(color: AppColors.red),
                              ),
                              child: const Text('Tolak',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _verifikasi(w, 'valid'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                              ),
                              child: const Text('Setujui',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
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
