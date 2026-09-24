import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';
import '../../core/image_helper.dart';
import '../../models/info_surat_model.dart';
import '../../models/info_surat_setting_model.dart';
import '../../models/surat_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../services/content_service.dart';
import '../../services/surat_service.dart';
import '../../widgets/main_scaffold.dart';
import '../auth/login_screen.dart';
import 'jenis_surat_form.dart';
import 'surat_form_screen.dart';

class InfoSuratScreen extends StatefulWidget {
  const InfoSuratScreen({super.key});

  @override
  State<InfoSuratScreen> createState() => _InfoSuratScreenState();
}

class _InfoSuratScreenState extends State<InfoSuratScreen> {
  late Future<_InfoSuratData> _future;
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = context.read<AuthProvider>().currentUser?.isAdmin ?? false;
    _future = _load();
  }

  Future<_InfoSuratData> _load() async {
    final client = context.read<ApiClient>();
    final content = ContentService(client);

    final alur = await content.alurPelayanan();
    final jenisSurat = _isAdmin
        ? await AdminService(client).listJenisSurat()
        : await SuratService(client).getJenisSurat();
    final setting = await content.infoSetting();
    return _InfoSuratData(alur: alur, jenisSurat: jenisSurat, setting: setting);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  // ============ AKSI ADMIN ============

  Future<void> _editFoto(bool alur) async {
    // Pilih dari galeri lalu potong. Layar crop sekaligus jadi konfirmasi,
    // jadi foto tidak langsung terganti bila tombol tak sengaja tertekan.
    final path = await pilihDanPotongFoto(
      context,
      sumber: ImageSource.gallery,
      judul: alur ? 'Sesuaikan Gambar Alur' : 'Sesuaikan Gambar Syarat',
    );
    if (path == null) return;

    try {
      await AdminService(context.read<ApiClient>()).saveInfoSetting(
        gambarAlurPath: alur ? path : null,
        gambarSyaratPath: alur ? null : path,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gambar diperbarui.'),
            backgroundColor: AppColors.primaryGreen),
      );
      _reload();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.firstError), backgroundColor: AppColors.red),
      );
    }
  }

  Future<void> _formAlur({AlurLangkahModel? existing}) async {
    final judulCtrl = TextEditingController(text: existing?.judulLangkah ?? '');
    final deskripsiCtrl =
        TextEditingController(text: existing?.deskripsi ?? '');

    final simpan = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Tambah Langkah' : 'Edit Langkah'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulCtrl,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  hintText: 'Contoh: Masyarakat',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deskripsiCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Keterangan',
                  hintText: 'Contoh: Membawa Pengantar RT/RW...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (simpan != true) return;

    if (judulCtrl.text.trim().isEmpty || deskripsiCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan keterangan wajib diisi.')),
      );
      return;
    }

    try {
      await AdminService(context.read<ApiClient>()).saveAlur(
        id: existing?.id,
        judul: judulCtrl.text.trim(),
        deskripsi: deskripsiCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Langkah disimpan.'),
            backgroundColor: AppColors.primaryGreen),
      );
      _reload();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.firstError), backgroundColor: AppColors.red),
      );
    }
  }

  Future<void> _hapusAlur(AlurLangkahModel a) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus langkah?'),
        content: Text('"${a.judulLangkah}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    try {
      await AdminService(context.read<ApiClient>()).deleteAlur(a.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Langkah dihapus.')));
      _reload();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.firstError), backgroundColor: AppColors.red),
      );
    }
  }

  void _formSurat({JenisSuratModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JenisSuratForm(existing: existing, onDone: _reload),
    );
  }

  Future<void> _hapusSurat(JenisSuratModel j) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus surat?'),
        content: Text('"${j.namaSurat}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    try {
      await AdminService(context.read<ApiClient>()).deleteJenisSurat(j.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Surat dihapus.')));
      _reload();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.firstError), backgroundColor: AppColors.red),
      );
    }
  }

  // ============ TAMPILAN ============

  void _openImage(ImageProvider provider, String title) {
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
                child:
                    Center(child: Image(image: provider, fit: BoxFit.contain)),
              ),
            ),
            Positioned(
              top: 40,
              left: 12,
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
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

  Widget _gambarBlok(
      String? networkPath, String assetPath, String title, bool alur) {
    final url = ApiConfig.fileUrl(networkPath);
    final ImageProvider provider = url.isNotEmpty
        ? NetworkImage(url)
        : AssetImage(assetPath) as ImageProvider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => _openImage(provider, title),
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: url.isEmpty
                      // Belum ada gambar dari admin: pakai bawaan aplikasi.
                      ? Image.asset(assetPath,
                          width: double.infinity, fit: BoxFit.contain)
                      // Tampilkan bawaan dulu (instan), lalu berganti halus
                      // ke gambar server begitu selesai dimuat.
                      : FadeInImage(
                          placeholder: AssetImage(assetPath),
                          image: NetworkImage(url),
                          width: double.infinity,
                          fit: BoxFit.contain,
                          fadeInDuration: const Duration(milliseconds: 250),
                          imageErrorBuilder: (_, __, ___) => Image.asset(
                              assetPath,
                              width: double.infinity,
                              fit: BoxFit.contain),
                        ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in_map_rounded,
                          color: Colors.white, size: 15),
                      SizedBox(width: 4),
                      Text('Ketuk untuk perbesar',
                          style:
                              TextStyle(color: Colors.white, fontSize: 10.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isAdmin) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _editFoto(alur),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Foto'),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue),
          ),
          const Text('Format JPG/PNG, ukuran maksimal 4 MB.',
              style: TextStyle(fontSize: 11, color: Colors.black45)),
        ],
      ],
    );
  }

  /// Sama seperti di beranda: wajib login dulu, lalu ke form pengajuan.
  void _buatSurat() {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Silakan login terlebih dahulu untuk membuat surat.')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SuratFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Baca ulang status admin setiap build agar selalu akurat
    // (mis. setelah auto-login selesai atau ganti akun).
    _isAdmin = context.watch<AuthProvider>().currentUser?.isAdmin ?? false;
    return MainScaffold(
      title: 'Informasi Surat',
      showBackButton: true,
      navIndex: NavTab.layanan,
      body: FutureBuilder<_InfoSuratData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Gagal memuat data: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          }
          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BubbleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.timeline_rounded,
                                    color: AppColors.primaryGreen),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text('Alur Pelayanan Digital',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          if (_isAdmin)
                            ElevatedButton.icon(
                              onPressed: () => _formAlur(),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Langkah',
                                  style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _gambarBlok(
                          data.setting.gambarAlur,
                          'assets/images/alur_pelayanan.png',
                          'Alur Pelayanan Digital',
                          true),
                      const Divider(height: 24),
                      ...List.generate(data.alur.length, (i) {
                        final langkah = data.alur[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.primaryBlue,
                                child: Text('${i + 1}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.poppins(
                                        color: Colors.black87, fontSize: 13.5),
                                    children: [
                                      TextSpan(
                                        text: '${langkah.judulLangkah}: ',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            fontSize: 13.5),
                                      ),
                                      TextSpan(text: langkah.deskripsi),
                                    ],
                                  ),
                                ),
                              ),
                              if (_isAdmin) ...[
                                InkWell(
                                  onTap: () => _formAlur(existing: langkah),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.edit,
                                        size: 16, color: AppColors.primaryBlue),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _hapusAlur(langkah),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.delete,
                                        size: 16, color: AppColors.red),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                      if (!_isAdmin) ...[
                        const SizedBox(height: 14),
                        GradientButton(
                          label: 'Buat Surat',
                          icon: Icons.edit_document,
                          onTap: _buatSurat,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BubbleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.fact_check_rounded,
                                    color: AppColors.primaryGreen),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text('Persyaratan Dokumen',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          if (_isAdmin)
                            ElevatedButton.icon(
                              onPressed: () => _formSurat(),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Tambah Surat',
                                  style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _gambarBlok(
                          data.setting.gambarSyarat,
                          'assets/images/syarat_surat.png',
                          'Persyaratan Dokumen',
                          false),
                      const Divider(height: 24),
                      if (data.jenisSurat.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Belum ada jenis surat.',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                        )
                      else
                        ...data.jenisSurat.map((j) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(j.namaSurat,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                      ),
                                      if (_isAdmin) ...[
                                        InkWell(
                                          onTap: () => _formSurat(existing: j),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(Icons.edit,
                                                size: 18,
                                                color: AppColors.primaryBlue),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => _hapusSurat(j),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(Icons.delete,
                                                size: 18, color: AppColors.red),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (j.keterangan != null &&
                                      j.keterangan!.trim().isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(j.keterangan!.trim(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                            fontStyle: FontStyle.italic)),
                                  ],
                                  const SizedBox(height: 6),
                                  if (j.syaratRequired.isEmpty)
                                    const Text(
                                      'Membawa Pengantar RT/RW dan identitas diri (KTP).',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.black54),
                                    )
                                  else
                                    ...j.syaratRequired.map((item) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 3),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 15,
                                                  color:
                                                      AppColors.primaryGreen),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                    formatSyaratLabel(item),
                                                    style: const TextStyle(
                                                        fontSize: 13)),
                                              ),
                                            ],
                                          ),
                                        )),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoSuratData {
  final List<AlurLangkahModel> alur;
  final List<JenisSuratModel> jenisSurat;
  final InfoSuratSettingModel setting;
  _InfoSuratData(
      {required this.alur, required this.jenisSurat, required this.setting});
}
