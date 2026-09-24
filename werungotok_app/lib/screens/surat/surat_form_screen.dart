import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../core/image_helper.dart';
import '../../models/surat_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/surat_service.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/main_scaffold.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class SuratFormScreen extends StatefulWidget {
  const SuratFormScreen({super.key});

  @override
  State<SuratFormScreen> createState() => _SuratFormScreenState();
}

class _SuratFormScreenState extends State<SuratFormScreen> {
  final _formKey = GlobalKey<FormState>();
  JenisSuratModel? _selectedJenisSurat;
  List<JenisSuratModel> _listJenisSurat = [];
  final _keperluanController = TextEditingController();
  PlatformFile? _dokumen;
  // Berkas per syarat: kunci = syarat_key, nilai = file terpilih.
  final Map<String, PlatformFile> _berkas = {};
  bool _submitting = false;

  StatusKtpResult? _statusKtp;
  bool _loadingStatus = true;
  bool _uploadingKtp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAccess());
  }

  @override
  void dispose() {
    _keperluanController.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Future.microtask(() {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Halaman ini terkunci. Silakan Login terlebih dahulu!'),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return;
    }

    try {
      final client = context.read<ApiClient>();
      final service = SuratService(client);

      final results = await Future.wait([
        service.cekStatusKtp(),
        service.getJenisSurat(),
      ]);

      if (mounted) {
        setState(() {
          _statusKtp = results[0] as StatusKtpResult;
          _listJenisSurat = results[1] as List<JenisSuratModel>;
        });
      }
    } catch (_) {
      // biarkan _statusKtp null, tampilkan pesan gagal memuat
    } finally {
      if (mounted) setState(() => _loadingStatus = false);
    }
  }

  Future<void> _uploadKtpUlang() async {
    // Ambil dari kamera lalu potong agar pas & sebagai konfirmasi.
    final path = await pilihDanPotongFoto(
      context,
      sumber: ImageSource.camera,
      judul: 'Sesuaikan Foto KTP',
    );
    if (path == null) return;

    setState(() => _uploadingKtp = true);
    try {
      final client = context.read<ApiClient>();
      await SuratService(client).uploadKtpUlang(path);
      if (!mounted) return;
      _showSnack(
        'KTP berhasil diunggah ulang. Menunggu verifikasi admin.',
        AppColors.primaryGreen,
      );
      // Muat ulang status → berubah jadi "menunggu verifikasi".
      await _checkAccess();
    } on ApiException catch (e) {
      _showSnack(e.firstError, AppColors.red);
    } catch (e) {
      _showSnack('Gagal mengunggah KTP. Coba lagi.', AppColors.red);
    } finally {
      if (mounted) setState(() => _uploadingKtp = false);
    }
  }

  /// Pilih berkas untuk satu syarat. Menerima PDF maupun foto.
  /// Kalau yang dipilih foto, dipotong dulu agar rapi dan terbaca.
  Future<void> _pickBerkas(String syaratKey) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;
    var file = result.files.first;

    if (file.path != null && adalahGambar(file.path!)) {
      final dipotong =
          await potongFoto(context, file.path!, judul: 'Sesuaikan Berkas');
      if (dipotong == null) return; // dibatalkan
      file = PlatformFile(
        name: dipotong.split(Platform.pathSeparator).last,
        path: dipotong,
        size: await File(dipotong).length(),
      );
    }
    setState(() => _berkas[syaratKey] = file);
  }

  /// Berkas tunggal untuk surat yang tidak punya daftar syarat.
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;
    var file = result.files.first;

    if (file.path != null && adalahGambar(file.path!)) {
      final dipotong =
          await potongFoto(context, file.path!, judul: 'Sesuaikan Berkas');
      if (dipotong == null) return;
      file = PlatformFile(
        name: dipotong.split(Platform.pathSeparator).last,
        path: dipotong,
        size: await File(dipotong).length(),
      );
    }
    setState(() => _dokumen = file);
  }

  /// Ubah "pengantar_rt_rw" -> "Pengantar RT/RW" agar mudah dibaca.
  String _formatSyaratLabel(String key) {
    const upper = {
      'rt',
      'rw',
      'kk',
      'ktp',
      'fc',
      'skck',
      'sktm',
      'rs',
      'bbm',
      'nik',
      'wa'
    };
    final words = key
        .toLowerCase()
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    final formatted = words
        .map((w) => upper.contains(w)
            ? w.toUpperCase()
            : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
    // Rapikan pasangan umum
    return formatted
        .replaceAll('RT RW', 'RT/RW')
        .replaceAll('KK KTP', 'KK/KTP');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final jenis = _selectedJenisSurat;
    if (jenis == null) {
      _showSnack('Pilih jenis surat terlebih dahulu.', AppColors.red);
      return;
    }

    final syarat = jenis.syaratRequired;
    final pakaiSyarat = syarat.isNotEmpty;

    if (pakaiSyarat) {
      // Pastikan semua syarat sudah diunggah.
      for (final key in syarat) {
        final f = _berkas[key];
        if (f == null || f.path == null) {
          _showSnack('Berkas "${_formatSyaratLabel(key)}" belum diunggah.',
              AppColors.red);
          return;
        }
      }
    } else if (_dokumen == null || _dokumen!.path == null) {
      _showSnack('Berkas pendukung wajib diunggah.', AppColors.red);
      return;
    }

    final yakin = await _konfirmasi(
      judul: 'Kirim Pengajuan?',
      pesan: jenis.perluMaterai
          ? 'Surat ini memerlukan materai. Setelah diproses, Anda akan '
              'dihubungi admin lewat WhatsApp untuk datang ke kelurahan '
              'menandatangani dan menempel materai. Lanjutkan?'
          : 'Pastikan jenis surat, keperluan, dan berkas sudah benar sebelum dikirim.',
      labelYa: 'Kirim',
      warnaYa: AppColors.primaryBlue,
    );
    if (yakin != true) return;

    setState(() => _submitting = true);
    try {
      final client = context.read<ApiClient>();
      final service = SuratService(client);
      await service.ajukan(
        jenisSurat: jenis.kode,
        keperluan: _keperluanController.text.trim(),
        clientTime: DateTime.now().toUtc().toIso8601String(),
        berkas:
            pakaiSyarat ? {for (final k in syarat) k: _berkas[k]!.path!} : null,
        dokumenPath: pakaiSyarat ? null : _dokumen!.path!,
      );

      if (!mounted) return;
      _showSnack(
        jenis.perluMaterai
            ? 'Pengajuan berhasil. Anda akan dihubungi admin untuk urusan materai.'
            : 'Proses pengajuan surat berhasil, menunggu proses validasi.',
        AppColors.primaryGreen,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      _showSnack(e.firstError, AppColors.red);
    } catch (e) {
      _showSnack('Gagal mengirim pengajuan. Coba lagi.', AppColors.red);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<bool?> _konfirmasi({
    required String judul,
    required String pesan,
    required String labelYa,
    required Color warnaYa,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(judul),
        content: Text(pesan),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: warnaYa),
            child: Text(labelYa),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Pengajuan Surat',
      showBackButton: true,
      navIndex: NavTab.layanan,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          child: BubbleCard(
            padding: const EdgeInsets.all(24),
            child: _loadingStatus
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  )
                : _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text('Pengajuan Surat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 20),
        if (_statusKtp == null)
          _statusBox(
            'Gagal memuat status KTP. Periksa koneksi ke server.',
            Colors.red,
          )
        else if (_statusKtp!.ktpStatus == 'invalid')
          _buildKtpDitolak()
        else if (!_statusKtp!.bolehMengajukan)
          _statusBox(_statusKtp!.pesan, Colors.orange)
        else
          _buildForm(),
      ],
    );
  }

  /// Ditampilkan saat KTP ditolak: alasan dari admin + tombol unggah ulang.
  Widget _buildKtpDitolak() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cancel_rounded,
                      color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text('KTP Ditolak Admin',
                      style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Alasan: ${_statusKtp!.pesan}',
                  style: TextStyle(
                      color: Colors.red.shade800, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Silakan unggah ulang foto KTP yang jelas untuk diverifikasi kembali oleh admin.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        LoadingButton(
          isLoading: _uploadingKtp,
          label: 'Upload Ulang KTP',
          color: AppColors.primaryBlue,
          onPressed: _uploadKtpUlang,
        ),
      ],
    );
  }

  Widget _statusBox(String pesan, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        pesan,
        style: TextStyle(
            color: color.shade800, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Pilih Jenis Surat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<JenisSuratModel>(
            isExpanded: true,
            value: _selectedJenisSurat,
            items: _listJenisSurat
                .map((item) => DropdownMenuItem<JenisSuratModel>(
                      value: item,
                      child: Text(
                        item.namaSurat,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ))
                .toList(),
            onChanged: (v) => setState(() {
              _selectedJenisSurat = v;
              // Berkas direset karena syaratnya berbeda tiap jenis surat.
              _berkas.clear();
              _dokumen = null;
            }),
            validator: (v) => v == null ? 'Pilih jenis surat' : null,
            decoration: const InputDecoration(hintText: '-- Pilih Jenis --'),
          ),
          if (_selectedJenisSurat != null &&
              _selectedJenisSurat!.syaratRequired.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Syarat Dokumen yang Harus Dilengkapi:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ..._selectedJenisSurat!.syaratRequired.map(
                    (syarat) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 14, color: AppColors.primaryBlue),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatSyaratLabel(syarat),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Peringatan bila surat memerlukan materai.
          if (_selectedJenisSurat?.perluMaterai == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sticky_note_2_rounded,
                      size: 18, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Surat ini memerlukan materai. Sebelum surat jadi, Anda '
                      'akan dihubungi admin melalui WhatsApp untuk datang ke '
                      'kelurahan menandatangani dan menempel materai.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text('Keperluan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _keperluanController,
            maxLines: 3,
            maxLength: 1000,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'Tuliskan keperluan pengajuan surat Anda',
              alignLabelWithHint: true,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Keperluan wajib diisi';
              }
              if (v.trim().length < 5) {
                return 'Jelaskan keperluan lebih rinci';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          const Text('Upload Berkas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: Colors.orange.shade800),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Unggah setiap berkas sesuai kolomnya. Boleh berupa foto '
                    '(JPG/PNG) atau PDF, maksimal 4 MB per berkas.',
                    style:
                        TextStyle(fontSize: 12, color: Colors.orange.shade900),
                  ),
                ),
              ],
            ),
          ),
          // Kolom upload mengikuti syarat jenis surat yang dipilih.
          if (_selectedJenisSurat == null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_upward_rounded,
                      size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pilih jenis surat terlebih dahulu untuk melihat berkas '
                      'apa saja yang perlu diunggah.',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade700,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            )
          else if (_selectedJenisSurat!.syaratRequired.isNotEmpty)
            ..._selectedJenisSurat!.syaratRequired.map(
              (key) => _uploadBox(
                label: _formatSyaratLabel(key),
                file: _berkas[key],
                onTap: () => _pickBerkas(key),
              ),
            )
          else
            _uploadBox(
              label: 'Berkas Pendukung',
              file: _dokumen,
              onTap: _pickFile,
            ),
          const SizedBox(height: 24),
          LoadingButton(
            isLoading: _submitting,
            label: 'Kirim Permohonan',
            color: AppColors.primaryBlue,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  /// Satu kotak upload untuk satu berkas.
  Widget _uploadBox({
    required String label,
    required PlatformFile? file,
    required VoidCallback onTap,
  }) {
    final sudah = file != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: sudah
                    ? Colors.green.shade50
                    : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: sudah
                        ? AppColors.primaryGreen.withOpacity(0.5)
                        : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                      sudah
                          ? Icons.check_circle_rounded
                          : Icons.upload_file_rounded,
                      size: 20,
                      color: sudah ? AppColors.primaryGreen : Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      file?.name ?? 'Pilih foto atau PDF',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: sudah ? AppColors.textDark : Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (sudah)
                    const Text('Ganti',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
