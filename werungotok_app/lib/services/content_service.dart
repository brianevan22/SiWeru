import '../core/api_client.dart';
import '../models/info_surat_model.dart';
import '../models/info_surat_setting_model.dart';

/// Kumpulan service untuk konten publik (tanpa perlu login):
/// alur pelayanan, syarat surat, serta gambar & keterangan Info Surat.
class ContentService {
  final ApiClient client;
  ContentService(this.client);

  Future<List<AlurLangkahModel>> alurPelayanan() async {
    final res = await client.get('/info-surat/alur');
    return (res['langkah'] as List)
        .map((e) => AlurLangkahModel.fromJson(e))
        .toList();
  }

  Future<List<SyaratSuratModel>> syaratSurat() async {
    final res = await client.get('/info-surat/syarat');
    return (res['syarat'] as List)
        .map((e) => SyaratSuratModel.fromJson(e))
        .toList();
  }

  Future<InfoSuratSettingModel> infoSetting() async {
    final res = await client.get('/info-surat/settings');
    return InfoSuratSettingModel.fromJson(res['data']);
  }
}
