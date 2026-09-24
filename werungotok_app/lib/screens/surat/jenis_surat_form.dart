import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../models/surat_model.dart';
import '../../services/admin_service.dart';

/// Daftar syarat baku (kode -> label). Admin bisa mencentang ini,
/// atau menambah syarat bebas lewat kolom teks.
const Map<String, String> kSyaratBaku = {
  'pengantar_rt': 'Pengantar RT',
  'pengantar_rw': 'Pengantar RW',
  'fc_kk': 'FC KK',
  'fc_ktp': 'FC KTP',
  'fc_kk_ktp': 'FC KK/KTP',
  'surat_pernyataan': 'Surat Pernyataan',
  'materai': 'Materai',
  'pas_foto': 'Pas Foto',
};

String formatSyaratLabel(String key) {
  if (kSyaratBaku.containsKey(key)) return kSyaratBaku[key]!;
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
  if (words.isEmpty) return key;
  final formatted = words
      .map((w) => upper.contains(w)
          ? w.toUpperCase()
          : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
  return formatted.replaceAll('RT RW', 'RT/RW').replaceAll('KK KTP', 'KK/KTP');
}

/// Bottom sheet form tambah/edit jenis surat.
/// Panggil lewat showModalBottomSheet; setelah simpan memanggil onDone.
class JenisSuratForm extends StatefulWidget {
  final JenisSuratModel? existing;
  final VoidCallback onDone;
  const JenisSuratForm({super.key, this.existing, required this.onDone});

  @override
  State<JenisSuratForm> createState() => _JenisSuratFormState();
}

class _JenisSuratFormState extends State<JenisSuratForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _keteranganCtrl = TextEditingController();
  final _syaratBebasCtrl = TextEditingController();
  final Set<String> _syaratBaku = {};
  final List<String> _syaratBebas = [];
  bool _perluMaterai = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _namaCtrl.text = e.namaSurat;
      _keteranganCtrl.text = e.keterangan ?? '';
      _perluMaterai = e.perluMaterai;
      for (final s in e.syaratRequired) {
        if (kSyaratBaku.containsKey(s)) {
          _syaratBaku.add(s);
        } else {
          _syaratBebas.add(s);
        }
      }
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _keteranganCtrl.dispose();
    _syaratBebasCtrl.dispose();
    super.dispose();
  }

  void _tambahSyaratBebas() {
    final t = _syaratBebasCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _syaratBebas.add(t);
      _syaratBebasCtrl.clear();
    });
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    // Ikutkan juga syarat bebas yang masih di kolom ketik tapi belum ditambah.
    final sisa = _syaratBebasCtrl.text.trim();
    final bebas = [..._syaratBebas, if (sisa.isNotEmpty) sisa];
    final syarat = [..._syaratBaku, ...bebas];

    setState(() => _saving = true);
    try {
      await AdminService(context.read<ApiClient>()).saveJenisSurat(
        id: widget.existing?.id,
        namaSurat: _namaCtrl.text.trim(),
        keterangan: _keteranganCtrl.text.trim().isEmpty
            ? null
            : _keteranganCtrl.text.trim(),
        syarat: syarat,
        isActive: true,
        perluMaterai: _perluMaterai,
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onDone();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existing == null
              ? 'Surat ditambahkan.'
              : 'Surat diperbarui.'),
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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.existing == null ? 'Tambah Surat' : 'Edit Surat',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Surat',
                    hintText: 'Contoh: Surat Keterangan Tidak Mampu',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _keteranganCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan (opsional)',
                    hintText: 'Penjelasan singkat tentang surat ini',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Syarat Dokumen',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                const Text('Centang syarat baku:',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                ...kSyaratBaku.entries.map((e) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _syaratBaku.contains(e.key),
                      title:
                          Text(e.value, style: const TextStyle(fontSize: 13)),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _syaratBaku.add(e.key);
                        } else {
                          _syaratBaku.remove(e.key);
                        }
                      }),
                    )),
                const SizedBox(height: 8),
                const Text('Tambah syarat lain (ketik lalu Enter):',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _syaratBebasCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Dokumen pendukung',
                          isDense: true,
                        ),
                        onSubmitted: (_) => _tambahSyaratBebas(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: AppColors.primaryGreen),
                      onPressed: _tambahSyaratBebas,
                    ),
                  ],
                ),
                if (_syaratBebas.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _syaratBebas
                        .map((s) => Chip(
                              label:
                                  Text(s, style: const TextStyle(fontSize: 12)),
                              onDeleted: () =>
                                  setState(() => _syaratBebas.remove(s)),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 8),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _perluMaterai,
                  activeColor: AppColors.primaryGreen,
                  title: const Text('Surat ini memerlukan materai',
                      style: TextStyle(fontSize: 13)),
                  subtitle: const Text(
                      'Warga akan diberi tahu untuk datang ke kelurahan '
                      'menandatangani & menempel materai.',
                      style: TextStyle(fontSize: 11, color: Colors.black54)),
                  onChanged: (v) => setState(() => _perluMaterai = v ?? false),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _simpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
