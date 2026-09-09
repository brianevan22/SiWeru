import '../core/api_client.dart';
import '../models/user_model.dart';
import '../models/surat_model.dart';

class AdminService {
  final ApiClient client;
  AdminService(this.client);

  Future<List<UserModel>> listWarga() async {
    final res = await client.get('/admin/warga');
    return (res['data'] as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> verifikasiWarga(int wargaId, String status) async {
    // status: 'valid' atau 'invalid'
    await client.postMultipart(
      '/admin/warga/$wargaId/verifikasi',
      fields: {'ktp_status': status},
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
}
