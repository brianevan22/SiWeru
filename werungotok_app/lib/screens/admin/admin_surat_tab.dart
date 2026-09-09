import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../models/surat_model.dart';
import '../../services/admin_service.dart';

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

  Color _statusColor(String status) {
    switch (status) {
      case 'selesai':
        return AppColors.primaryGreen;
      case 'ditolak':
        return AppColors.red;
      default:
        return Colors.orange;
    }
  }

  void _openProsesDialog(SuratModel surat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProsesSuratSheet(
        surat: surat,
        onDone: _reload,
      ),
    );
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
                  return Center(child: Text('Gagal memuat: ${snapshot.error}'));
                }
                final data = snapshot.data!;
                if (data.isEmpty) {
                  return const Center(
                      child: Text('Tidak ada pengajuan surat.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final s = data[i];
                    return BubbleCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.jenisSurat,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    Text(
                                      '${s.namaPemohon ?? "Warga"} • ${s.waPemohon ?? "-"}',
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
                                      _statusColor(s.status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  s.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _statusColor(s.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Diajukan: ${s.createdAt}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black45)),
                          if (s.status == 'diproses') ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _openProsesDialog(s),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                ),
                                child: const Text('Proses Surat',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ],
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

/// Bottom sheet form untuk admin memproses 1 pengajuan surat:
/// pilih status (selesai/ditolak), catatan, dan upload PDF hasil jika selesai.
class _ProsesSuratSheet extends StatefulWidget {
  final SuratModel surat;
  final VoidCallback onDone;

  const _ProsesSuratSheet({required this.surat, required this.onDone});

  @override
  State<_ProsesSuratSheet> createState() => _ProsesSuratSheetState();
}

class _ProsesSuratSheetState extends State<_ProsesSuratSheet> {
  String _status = 'selesai';
  final _catatanCtrl = TextEditingController();
  PlatformFile? _pdfFile;
  bool _saving = false;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pdfFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    if (_status == 'selesai' && (_pdfFile == null || _pdfFile!.path == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload file PDF hasil surat terlebih dahulu.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final service = AdminService(context.read<ApiClient>());
      await service.prosesSurat(
        suratId: widget.surat.id,
        status: _status,
        catatanAdmin:
            _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim(),
        fileHasilPath: _pdfFile?.path,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onDone();
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
            Text('Proses: ${widget.surat.jenisSurat}',
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
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: 'ditolak',
                    groupValue: _status,
                    contentPadding: EdgeInsets.zero,
                    title:
                        const Text('Ditolak', style: TextStyle(fontSize: 13)),
                    onChanged: (v) => setState(() => _status = v!),
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
