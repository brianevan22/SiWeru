import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
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
  String? _jenisSurat;
  PlatformFile? _dokumen;
  bool _submitting = false;

  StatusKtpResult? _statusKtp;
  bool _loadingStatus = true;

  static const _jenisOptions = {
    'SKCK': 'SKCK',
    'KEMATIAN': 'Surat Kematian',
    'SKTM': 'SKTM',
    'USAHA': 'Keterangan Usaha',
    'DOMISILI': 'Keterangan Domisili',
    'LAINNYA': 'Lainnya',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAccess());
  }

  Future<void> _checkAccess() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      // Sama seperti script.js: halaman terkunci, arahkan ke login.
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
      final status = await service.cekStatusKtp();
      if (mounted) setState(() => _statusKtp = status);
    } catch (_) {
      // biarkan _statusKtp null, tampilkan pesan gagal memuat
    } finally {
      if (mounted) setState(() => _loadingStatus = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _dokumen = result.files.first);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dokumen == null || _dokumen!.path == null) {
      _showSnack('Dokumen pendukung wajib diupload.', AppColors.red);
      return;
    }

    setState(() => _submitting = true);
    try {
      final client = context.read<ApiClient>();
      final service = SuratService(client);
      await service.ajukan(
        jenisSurat: _jenisSurat!,
        dokumenPath: _dokumen!.path!,
      );

      if (!mounted) return;
      _showSnack(
        'Berhasil! Dokumen PDF akan dikirimkan ke WhatsApp Anda.',
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
        else if (!_statusKtp!.bolehMengajukan)
          _statusBox(
            _statusKtp!.pesan,
            _statusKtp!.ktpStatus == 'invalid' ? Colors.red : Colors.orange,
          )
        else
          _buildForm(),
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
          DropdownButtonFormField<String>(
            value: _jenisSurat,
            items: _jenisOptions.entries
                .map((e) =>
                    DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => setState(() => _jenisSurat = v),
            validator: (v) => v == null ? 'Pilih jenis surat' : null,
            decoration: const InputDecoration(hintText: '-- Pilih Jenis --'),
          ),
          const SizedBox(height: 16),
          const Text('Upload Dokumen Pendukung',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
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
                  const Icon(Icons.attach_file, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _dokumen?.name ?? 'Pilih file (PDF/JPG/PNG, maks 4MB)',
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
