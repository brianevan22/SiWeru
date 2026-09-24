import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';
import '../../core/image_helper.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';
import '../../widgets/main_scaffold.dart';
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
  bool _uploadingFoto = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _waCtrl.text = user?.wa ?? '';
  }

  @override
  void dispose() {
    _waCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveWa() async {
    setState(() => _saving = true);
    try {
      final client = context.read<ApiClient>();
      final updated =
          await ProfileService(client).updateWa(_waCtrl.text.trim());
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

  Future<void> _gantiFoto() async {
    // Pilih dari galeri lalu potong agar pas; sekaligus jadi konfirmasi.
    final path = await pilihDanPotongFoto(
      context,
      sumber: ImageSource.gallery,
      judul: 'Sesuaikan Foto Profil',
    );
    if (path == null) return;

    setState(() => _uploadingFoto = true);
    try {
      final client = context.read<ApiClient>();
      final updated = await ProfileService(client).updateFoto(path);
      if (!mounted) return;
      context.read<AuthProvider>().updateUser(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diperbarui!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.firstError), backgroundColor: AppColors.red),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui foto. Coba lagi.'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingFoto = false);
    }
  }

  void _zoomFoto(String url) {
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
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text('Gagal memuat gambar.',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
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

  Widget _buildAvatar(String url) {
    final hasFoto = url.isNotEmpty;
    return Stack(
      children: [
        GestureDetector(
          onTap: hasFoto ? () => _zoomFoto(url) : null,
          child: CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
            backgroundImage: hasFoto ? NetworkImage(url) : null,
            child: !hasFoto
                ? const Icon(Icons.person,
                    size: 44, color: AppColors.primaryGreen)
                : null,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: AppColors.primaryGreen,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _uploadingFoto ? null : _gantiFoto,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: _uploadingFoto
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
      ],
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

    final fotoUrl = ApiConfig.fileUrl(user.fotoProfil);

    return MainScaffold(
      title: 'Profil Saya',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BubbleCard(
              child: Column(
                children: [
                  _buildAvatar(fotoUrl),
                  const SizedBox(height: 12),
                  Text(user.nama ?? user.username,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('@${user.username}',
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12)),
                  // Status KTP hanya relevan untuk warga, bukan admin.
                  if (!user.isAdmin) ...[
                    const SizedBox(height: 10),
                    _statusChip(user.ktpStatus),
                  ],
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
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
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
                        Text(user.wa ?? '-',
                            style: const TextStyle(fontSize: 13)),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => setState(() => _editing = true),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Riwayat pengajuan hanya untuk warga; admin memproses
            // pengajuan lewat Panel Admin, bukan mengajukan sendiri.
            if (!user.isAdmin) ...[
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
                  style:
                      const TextStyle(fontSize: 12.5, color: Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
