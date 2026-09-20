import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/admin_service.dart';
import 'admin_shared.dart';

class AdminWargaTab extends StatefulWidget {
  const AdminWargaTab({super.key});

  @override
  State<AdminWargaTab> createState() => _AdminWargaTabState();
}

class _AdminWargaTabState extends State<AdminWargaTab> {
  late Future<List<UserModel>> _future;

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

  Future<void> _openDetail(UserModel warga) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminWargaDetailScreen(warga: warga)),
    );
    if (changed == true) _reload();
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
              // Kartu ringkas: foto profil kecil + nama + status.
              // Detail (KTP, riwayat, tombol verifikasi) muncul saat diklik.
              return BubbleCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openDetail(w),
                  child: Row(
                    children: [
                      SmallAvatar(fotoProfil: w.fotoProfil, radius: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.nama ?? w.username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('@${w.username}',
                                style: const TextStyle(
                                    fontSize: 11.5, color: Colors.black54)),
                          ],
                        ),
                      ),
                      _statusChip(w.ktpStatus),
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

/// Halaman detail warga: profil lengkap, KTP, riwayat surat, dan
/// tombol Tolak/Setujui untuk verifikasi KTP.
class AdminWargaDetailScreen extends StatefulWidget {
  final UserModel warga;
  const AdminWargaDetailScreen({super.key, required this.warga});

  @override
  State<AdminWargaDetailScreen> createState() => _AdminWargaDetailScreenState();
}

class _AdminWargaDetailScreenState extends State<AdminWargaDetailScreen> {
  bool _processing = false;
  bool _changed = false;
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.warga.ktpStatus;
  }

  Future<void> _verifikasi(String status, {String? catatan}) async {
    setState(() => _processing = true);
    try {
      final service = AdminService(context.read<ApiClient>());
      await service.verifikasiWarga(widget.warga.id, status, catatan: catatan);
      if (!mounted) return;
      setState(() {
        _status = status;
        _changed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'valid' ? 'KTP disetujui.' : 'KTP ditolak.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.firstError), backgroundColor: AppColors.red),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  /// Tolak KTP: minta alasan dulu, alasan tampil di akun warga.
  Future<void> _tolak() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tolak KTP'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Alasan penolakan (mis. foto buram, alamat tidak sesuai)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (ctrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan penolakan wajib diisi.')),
      );
      return;
    }
    _verifikasi('invalid', catatan: ctrl.text.trim());
  }

  Widget _statusChip(String status) {
    final map = {
      'valid': (AppColors.primaryGreen, 'KTP Valid'),
      'invalid': (AppColors.red, 'KTP Ditolak'),
      'unverified': (Colors.orange, 'Menunggu Verifikasi'),
    };
    final (color, label) = map[status] ?? (Colors.grey, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.warga;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_changed);
        return false;
      },
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Detail Warga',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: BubbleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profil
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => showZoomableNetworkImage(
                              context, w.fotoProfil, 'Foto Profil'),
                          child:
                              SmallAvatar(fotoProfil: w.fotoProfil, radius: 46),
                        ),
                        const SizedBox(height: 10),
                        Text(w.nama ?? w.username,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('@${w.username}',
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 10),
                        _statusChip(_status),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Data diri
                  _sectionTitle('Data Diri'),
                  _infoRow('Email', w.email ?? '-'),
                  _infoRow('Nomor WA', w.wa ?? '-'),
                  _infoRow('Alamat', w.alamat ?? '-'),
                  const SizedBox(height: 20),
                  // KTP — tombol, tidak tampil langsung agar rapi
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: (w.ktpPhoto != null && w.ktpPhoto!.isNotEmpty)
                          ? () => showZoomableNetworkImage(
                              context, w.ktpPhoto, 'Foto KTP')
                          : null,
                      icon: const Icon(Icons.badge_outlined, size: 18),
                      label: const Text('Lihat KTP'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Riwayat surat
                  _sectionTitle('Riwayat Pengajuan Surat'),
                  const SizedBox(height: 8),
                  if (w.riwayatSurat.isEmpty)
                    const Text('Belum ada pengajuan surat.',
                        style: TextStyle(fontSize: 13, color: Colors.black54))
                  else
                    ...w.riwayatSurat.map((s) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.namaSurat,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(formatTanggal(s.createdAt),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      statusColor(s.status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(s.status.toUpperCase(),
                                    style: TextStyle(
                                        color: statusColor(s.status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10)),
                              ),
                            ],
                          ),
                        )),
                  const SizedBox(height: 24),
                  // Tombol verifikasi
                  if (_processing)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _tolak(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red,
                              side: const BorderSide(color: AppColors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Tolak'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _verifikasi('valid'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Setujui'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));

  Widget _infoRow(String label, String value) {
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
