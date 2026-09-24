import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../core/image_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _waCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Uint8List? _ktpBytes;
  String? _ktpFilename;
  Uint8List? _fotoProfilBytes;
  String? _fotoProfilFilename;

  Future<void> _pickImage(bool isKtp) async {
    // KTP langsung dari kamera agar foto asli; profil boleh dari galeri.
    // Setelah dipilih, foto dipotong dulu agar pas & sebagai konfirmasi.
    final path = await pilihDanPotongFoto(
      context,
      sumber: isKtp ? ImageSource.camera : ImageSource.gallery,
      judul: isKtp ? 'Sesuaikan Foto KTP' : 'Sesuaikan Foto Profil',
    );
    if (path == null) return;

    final file = File(path);
    final bytes = await file.readAsBytes();
    final namaFile = path.split(Platform.pathSeparator).last;

    setState(() {
      if (isKtp) {
        _ktpBytes = bytes;
        _ktpFilename = namaFile;
      } else {
        _fotoProfilBytes = bytes;
        _fotoProfilFilename = namaFile;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ktpBytes == null || _fotoProfilBytes == null) {
      _showError('Foto KTP dan Foto Profil wajib diupload.');
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      await auth.register(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
        nama: _namaCtrl.text.trim(),
        wa: _waCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        alamat: _alamatCtrl.text.trim(),
        ktpBytes: _ktpBytes!,
        ktpFilename: _ktpFilename!,
        fotoProfilBytes: _fotoProfilBytes!,
        fotoProfilFilename: _fotoProfilFilename!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran Berhasil! Silakan Login.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on ApiException catch (e) {
      _showError(e.firstError);
    } catch (e) {
      _showError('Gagal memproses pendaftaran. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.red),
    );
  }

  Widget _uploadBox(
      String label, IconData icon, Uint8List? bytes, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: bytes == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: AppColors.primaryGreen),
                      const SizedBox(height: 6),
                      Text(label,
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center),
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(bytes,
                      fit: BoxFit.cover, width: double.infinity),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: BubbleCard(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Daftar Akun Warga',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _namaCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nama Lengkap (KTP)'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _waCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'No. WhatsApp Aktif'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(labelText: 'Email Aktif'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _alamatCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          labelText: 'Alamat (Sesuai KTP)'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _uploadBox(
                            'Foto KTP\n(Kamera)',
                            Icons.camera_alt_rounded,
                            _ktpBytes,
                            () => _pickImage(true)),
                        const SizedBox(width: 12),
                        _uploadBox(
                            'Foto Profil\n(Galeri)',
                            Icons.photo_library_rounded,
                            _fotoProfilBytes,
                            () => _pickImage(false)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Username (Min 8 Huruf, Tanpa Spasi)'),
                      validator: (v) {
                        if (v == null || v.length < 8) {
                          return 'Minimal 8 karakter';
                        }
                        if (v.contains(' ')) return 'Tanpa spasi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password (Min 8 Karakter)',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 8)
                          ? 'Minimal 8 karakter'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    LoadingButton(
                      isLoading: _loading,
                      label: 'Daftar Sekarang',
                      color: AppColors.primaryGreen,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
