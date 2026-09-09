import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/main_scaffold.dart';
import '../../widgets/zoomable_image.dart';
import '../surat/riwayat_surat_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _waCtrl = TextEditingController();
  bool _saving = false;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _waCtrl.text = user?.wa ?? '';
  }

  Future<void> _saveWa() async {
    setState(() => _saving = true);
    try {
      final client = context.read<ApiClient>();
      final updated = await ProfileService(client).updateWa(_waCtrl.text.trim());
      if (!mounted) return;
      context.read<AuthProvider>().updateUser(updated);
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor WhatsApp berhasil diperbarui!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.firstError), backgroundColor: AppColors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _statusChip(String status) {
    final map = {
      'valid': (AppColors.primaryGreen, 'KTP Terverifikasi'),
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
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const MainScaffold(
        title: 'Profil',
        showBackButton: true,
        body: Center(child: Text('Anda belum login.')),
      );
    }

    return MainScaffold(
      title: 'Profil Saya',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BubbleCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
                    backgroundImage: (user.pasFoto != null && user.pasFoto!.isNotEmpty)
                        ? NetworkImage(ApiConfig.fileUrl(user.pasFoto))
                        : null,
                    child: (user.pasFoto == null || user.pasFoto!.isEmpty)
                        ? const Icon(Icons.person,
                            size: 40, color: AppColors.primaryGreen)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(user.nama ?? user.username,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('@${user.username}',
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 10),
                  _statusChip(user.ktpStatus),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BubbleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Data Diri',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                  _infoRow('Email', user.email ?? '-'),
                  _infoRow('Alamat', user.alamat ?? '-'),
                  const SizedBox(height: 12),
                  const Text('Nomor WhatsApp',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  if (_editing)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _waCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                                hintText: 'Nomor WhatsApp aktif'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : IconButton(
                                icon: const Icon(Icons.check,
                                    color: AppColors.primaryGreen),
                                onPressed: _saveWa,
                              ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(user.wa ?? '-', style: const TextStyle(fontSize: 13)),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => setState(() => _editing = true),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (user.ktpPhoto != null && user.ktpPhoto!.isNotEmpty) ...[
              const SizedBox(height: 16),
              BubbleCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Foto KTP Terdaftar',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ZoomableImage(imageUrl: ApiConfig.fileUrl(user.ktpPhoto)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RiwayatSuratScreen()),
              ),
              icon: const Icon(Icons.history),
              label: const Text('Riwayat Pengajuan Surat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12.5, color: Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
