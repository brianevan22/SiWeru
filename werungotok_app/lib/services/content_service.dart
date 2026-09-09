import '../core/api_client.dart';
import '../models/posyandu_model.dart';
import '../models/bank_sampah_model.dart';
import '../models/info_surat_model.dart';

/// Kumpulan service untuk konten publik (tanpa perlu login):
/// jadwal posyandu, info bank sampah, alur pelayanan & syarat surat.
class ContentService {
  final ApiClient client;
  ContentService(this.client);

  Future<PosyanduDataModel> posyandu() async {
    final res = await client.get('/posyandu');
    return PosyanduDataModel.fromJson(res);
  }

  Future<BankSampahDataModel> bankSampah() async {
    final res = await client.get('/bank-sampah');
    return BankSampahDataModel.fromJson(res);
  }

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
}
