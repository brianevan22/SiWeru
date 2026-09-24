import 'dart:convert';
import '../core/api_client.dart';
import '../models/user_model.dart';
import '../models/surat_model.dart';
import '../models/info_surat_setting_model.dart';

class AdminService {
  final ApiClient client;
  AdminService(this.client);

  Future<List<UserModel>> listWarga() async {
    final res = await client.get('/admin/warga');
    return (res['data'] as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> verifikasiWarga(int wargaId, String status,
      {String? catatan}) async {
    // status: 'valid' atau 'invalid'
    await client.postMultipart(
      '/admin/warga/$wargaId/verifikasi',
      fields: {
        'ktp_status': status,
        if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      },
    );
  }

  Future<List<SuratModel>> listSurat({String? status}) async {
    final res = await client.get('/admin/surat', query: {
      if (status != null) 'status': status,
    });
    return (res['data'] as List).map((e) => SuratModel.fromJson(e)).toList();
  }

  Future<void> prosesSurat({
    required int suratId,
    required String status, // selesai | ditolak
    String? catatanAdmin,
    String? fileHasilPath,
  }) async {
    await client.postMultipart(
      '/admin/surat/$suratId/proses',
      fields: {
        'status': status,
        if (catatanAdmin != null) 'catatan_admin': catatanAdmin,
      },
      files: fileHasilPath != null ? {'file_hasil': fileHasilPath} : null,
    );
  }

  // ============ KELOLA JENIS SURAT ============

  Future<List<JenisSuratModel>> listJenisSurat() async {
    final res = await client.get('/admin/jenis-surat');
    return (res['data'] as List)
        .map((e) => JenisSuratModel.fromJson(e))
        .toList();
  }

  /// Tambah (id null) atau ubah (id terisi) jenis surat.
  /// Kode dibuat otomatis oleh server dari nama surat.
  Future<void> saveJenisSurat({
    int? id,
    required String namaSurat,
    String? keterangan,
    required List<String> syarat,
    required bool isActive,
    bool perluMaterai = false,
  }) async {
    final fields = <String, String>{
      'nama_surat': namaSurat,
      'keterangan': keterangan ?? '',
      'syarat_required': jsonEncode(syarat),
      'is_active': isActive ? '1' : '0',
      'perlu_materai': perluMaterai ? '1' : '0',
      if (id != null) '_method': 'PUT',
    };
    final path = id == null ? '/admin/jenis-surat' : '/admin/jenis-surat/$id';
    await client.postMultipart(path, fields: fields);
  }

  Future<void> deleteJenisSurat(int id) async {
    await client.postMultipart(
      '/admin/jenis-surat/$id',
      fields: {'_method': 'DELETE'},
    );
  }

  // ============ KELOLA LANGKAH ALUR ============

  Future<void> saveAlur({
    int? id,
    required String judul,
    required String deskripsi,
  }) async {
    final fields = <String, String>{
      'judul_langkah': judul,
      'deskripsi': deskripsi,
      if (id != null) '_method': 'PUT',
    };
    final path = id == null ? '/admin/alur' : '/admin/alur/$id';
    await client.postMultipart(path, fields: fields);
  }

  Future<void> deleteAlur(int id) async {
    await client.postMultipart(
      '/admin/alur/$id',
      fields: {'_method': 'DELETE'},
    );
  }

  // ============ KELOLA INFO SURAT (gambar & keterangan) ============

  Future<InfoSuratSettingModel> getInfoSetting() async {
    final res = await client.get('/admin/info-surat');
    return InfoSuratSettingModel.fromJson(res['data']);
  }

  Future<void> saveInfoSetting({
    String? keterangan,
    String? gambarAlurPath,
    String? gambarSyaratPath,
    String? gambarPosyanduPath,
  }) async {
    final fields = <String, String>{};
    if (keterangan != null) fields['keterangan'] = keterangan;

    final files = <String, String>{};
    if (gambarAlurPath != null) files['gambar_alur'] = gambarAlurPath;
    if (gambarSyaratPath != null) files['gambar_syarat'] = gambarSyaratPath;
    if (gambarPosyanduPath != null) {
      files['gambar_posyandu'] = gambarPosyanduPath;
    }

    await client.postMultipart(
      '/admin/info-surat',
      fields: fields,
      files: files.isEmpty ? null : files,
    );
  }
}
