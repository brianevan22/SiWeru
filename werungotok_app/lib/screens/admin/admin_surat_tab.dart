import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';
import '../../models/surat_model.dart';
import '../../services/admin_service.dart';
import 'admin_shared.dart';

class AdminSuratTab extends StatefulWidget {
  const AdminSuratTab({super.key});

  @override
  State<AdminSuratTab> createState() => _AdminSuratTabState();
}

class _AdminSuratTabState extends State<AdminSuratTab> {
  late Future<List<SuratModel>> _future;
  String? _filter; // null = semua

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final service = AdminService(context.read<ApiClient>());
    setState(() {
      _future = service.listSurat(status: _filter);
    });
  }

  Future<void> _openDetail(SuratModel surat) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminSuratDetailScreen(surat: surat),
      ),
    );
    if (changed == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('Semua', null),
                _filterChip('Diproses', 'diproses'),
                _filterChip('Selesai', 'selesai'),
                _filterChip('Ditolak', 'ditolak'),
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: FutureBuilder<List<SuratModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Gagal memuat: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white)));
                }
                final data = snapshot.data!;
                if (data.isEmpty) {
                  return const Center(
                      child: Text('Tidak ada pengajuan surat.',
                          style: TextStyle(color: Colors.white)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final s = data[i];
                    // Kartu ringkas: foto profil kecil + nama + status +
                    // tombol Lihat Berkas. KTP & proses ada di detail.
                    return BubbleCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openDetail(s),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SmallAvatar(
                                    fotoProfil: s.fotoPemohon, radius: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(s.namaSurat,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      Text(
                                        s.namaPemohon ?? 'Warga',
                                        style: const TextStyle(
                                            fontSize: 11.5,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        statusColor(s.status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    s.status.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor(s.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Diajukan: ${formatTanggal(s.createdAt)}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black45)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String? value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        selectedColor: AppColors.primaryGreen,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textDark,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (_) {
          setState(() => _filter = value);
          _reload();
        },
      ),
    );
  }
}

/// Halaman detail pengajuan surat: info pemohon, KTP, berkas, dan
/// tombol proses (selesai/tolak + upload hasil).
class AdminSuratDetailScreen extends StatefulWidget {
  final SuratModel surat;
  const AdminSuratDetailScreen({super.key, required this.surat});

  @override
  State<AdminSuratDetailScreen> createState() => _AdminSuratDetailScreenState();
}

class _AdminSuratDetailScreenState extends State<AdminSuratDetailScreen> {
  bool _changed = false;
  late String _status;
  String? _catatan;

  @override
  void initState() {
    super.initState();
    _status = widget.surat.status;
    _catatan = widget.surat.catatanAdmin;
  }

  Future<void> _lihatBerkas(String? path) async {
    final url = ApiConfig.fileUrl(path);
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berkas tidak tersedia.')));
      return;
    }
    if (url.toLowerCase().endsWith('.pdf')) {
      final ok =
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak bisa membuka PDF: $url')));
      }
    } else {
      showZoomableNetworkImage(context, path, 'Berkas Pendukung');
    }
  }

  /// Unduh berkas ke folder Download HP dengan notifikasi.
  Future<void> _downloadBerkas(String? path) async {
    final url = ApiConfig.fileUrl(path);
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berkas tidak tersedia.')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengunduh berkas...')),
    );
    FileDownloader.downloadFile(
      url: url,
      name: 'berkas_surat_${widget.surat.id}.pdf',
      onDownloadCompleted: (savedPath) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berkas tersimpan, membuka file...'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        OpenFilex.open(savedPath);
      },
      onDownloadError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh: $error'),
            backgroundColor: AppColors.red,
          ),
        );
      },
    );
  }

  void _openProses() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProsesSuratSheet(
        surat: widget.surat,
        onDone: (status, catatan) {
          setState(() {
            _status = status;
            _catatan = catatan;
            _changed = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.surat;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_changed);
        return false;
      },
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Detail Pengajuan',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: BubbleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => showZoomableNetworkImage(
                            context, s.fotoPemohon, 'Foto Profil'),
                        child:
                            SmallAvatar(fotoProfil: s.fotoPemohon, radius: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.namaPemohon ?? 'Warga',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(s.waPemohon ?? '-',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor(_status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_status.toUpperCase(),
                            style: TextStyle(
                                color: statusColor(_status),
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Detail Surat'),
                  _infoRow('Jenis', s.namaSurat),
                  _infoRow(
                      'Keperluan', s.keperluan.isEmpty ? '-' : s.keperluan),
                  _infoRow('Alamat', s.alamatPemohon ?? '-'),
                  _infoRow('Diajukan', formatTanggal(s.createdAt)),
                  if (_catatan != null && _catatan!.isNotEmpty)
                    _infoRow('Catatan', _catatan!),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          (s.ktpPemohon != null && s.ktpPemohon!.isNotEmpty)
                              ? () => showZoomableNetworkImage(
                                  context, s.ktpPemohon, 'Foto KTP')
                              : null,
                      icon: const Icon(Icons.badge_outlined, size: 18),
                      label: const Text('Lihat KTP Warga'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _lihatBerkas(s.dokumenPendukung),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Lihat Berkas'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadBerkas(s.dokumenPendukung),
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download Berkas'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_status == 'diproses') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _openProses,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Proses Surat'),
                      ),
                    ),
                  ],
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

/// Bottom sheet form untuk admin memproses 1 pengajuan surat:
/// pilih status (selesai/ditolak), catatan, dan upload PDF hasil jika selesai.
class _ProsesSuratSheet extends StatefulWidget {
  final SuratModel surat;
  final void Function(String status, String? catatan) onDone;

  const _ProsesSuratSheet({required this.surat, required this.onDone});

  @override
  State<_ProsesSuratSheet> createState() => _ProsesSuratSheetState();
}

class _ProsesSuratSheetState extends State<_ProsesSuratSheet> {
  String _status = 'selesai';
  final _catatanCtrl = TextEditingController();
  PlatformFile? _pdfFile;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pdfFile = result.files.first;
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    if (_status == 'selesai' && (_pdfFile == null || _pdfFile!.path == null)) {
      setState(() => _error = 'Upload file PDF hasil surat terlebih dahulu.');
      return;
    }
    setState(() => _error = null);

    final yakin = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kirim ke Warga?'),
        content: Text(_status == 'selesai'
            ? 'Surat akan ditandai SELESAI dan hasilnya dikirim ke warga.'
            : 'Pengajuan akan ditandai DITOLAK dan warga akan diberi tahu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: _status == 'selesai'
                    ? AppColors.primaryGreen
                    : AppColors.red),
            child: const Text('Ya, Kirim'),
          ),
        ],
      ),
    );
    if (yakin != true) return;

    setState(() => _saving = true);
    try {
      final service = AdminService(context.read<ApiClient>());
      final catatan =
          _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim();
      await service.prosesSurat(
        suratId: widget.surat.id,
        status: _status,
        catatanAdmin: catatan,
        fileHasilPath: _pdfFile?.path,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onDone(_status, catatan);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Surat berhasil dikirim ke warga!'),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Proses: ${widget.surat.namaSurat}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    value: 'selesai',
                    groupValue: _status,
                    contentPadding: EdgeInsets.zero,
                    title:
                        const Text('Selesai', style: TextStyle(fontSize: 13)),
                    onChanged: (v) => setState(() {
                      _status = v!;
                      _error = null;
                    }),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: 'ditolak',
                    groupValue: _status,
                    contentPadding: EdgeInsets.zero,
                    title:
                        const Text('Ditolak', style: TextStyle(fontSize: 13)),
                    onChanged: (v) => setState(() {
                      _status = v!;
                      _error = null;
                    }),
                  ),
                ),
              ],
            ),
            if (_status == 'selesai') ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickPdf,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _pdfFile?.name ?? 'Upload PDF hasil surat',
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _catatanCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan untuk warga (opsional)',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: Colors.red.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: TextStyle(
                              color: Colors.red.shade800, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Kirim ke Warga'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
