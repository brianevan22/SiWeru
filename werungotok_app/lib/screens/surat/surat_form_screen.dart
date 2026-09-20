import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
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
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (picked == null || picked.files.isEmpty) return;
    final path = picked.files.first.path;
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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _dokumen = result.files.first);
    }
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
    if (_selectedJenisSurat == null) {
      _showSnack('Pilih jenis surat terlebih dahulu.', AppColors.red);
      return;
    }
    if (_dokumen == null || _dokumen!.path == null) {
      _showSnack('Dokumen pendukung wajib diupload.', AppColors.red);
      return;
    }

    setState(() => _submitting = true);
    try {
      final client = context.read<ApiClient>();
      final service = SuratService(client);
      await service.ajukan(
        jenisSurat: _selectedJenisSurat!.kode,
        keperluan: _keperluanController.text.trim(),
        clientTime: DateTime.now().toUtc().toIso8601String(),
        dokumenPath: _dokumen!.path!,
      );

      if (!mounted) return;
      _showSnack(
        'Proses pengajuan surat berhasil, menunggu proses validasi.',
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
            onChanged: (v) => setState(() => _selectedJenisSurat = v),
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
            margin: const EdgeInsets.only(bottom: 8),
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
                    'Gabungkan semua berkas persyaratan menjadi satu file PDF, '
                    'lalu unggah di sini.',
                    style:
                        TextStyle(fontSize: 12, color: Colors.orange.shade900),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _dokumen?.name ?? 'Pilih file PDF (maks 4MB)',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
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
}
