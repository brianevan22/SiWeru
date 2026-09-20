import '../core/api_client.dart';
import '../models/surat_model.dart';

class StatusKtpResult {
  final String ktpStatus;
  final bool bolehMengajukan;
  final String pesan;
  final String? catatan;

  StatusKtpResult({
    required this.ktpStatus,
    required this.bolehMengajukan,
    required this.pesan,
    this.catatan,
  });

  factory StatusKtpResult.fromJson(Map<String, dynamic> json) {
    return StatusKtpResult(
      ktpStatus: json['ktp_status'] ?? 'unverified',
      bolehMengajukan: json['boleh_mengajukan'] ?? false,
      pesan: json['pesan'] ?? '',
      catatan: json['catatan'],
    );
  }
}

class SuratService {
  final ApiClient client;
  SuratService(this.client);

  Future<StatusKtpResult> cekStatusKtp() async {
    final res = await client.get('/surat/status-ktp');
    return StatusKtpResult.fromJson(res);
  }

  /// Unggah ulang KTP (setelah ditolak) untuk diverifikasi kembali.
  Future<void> uploadKtpUlang(String ktpPath) async {
    await client.postMultipart(
      '/profile/ktp',
      files: {'ktp_photo': ktpPath},
    );
  }

  Future<List<JenisSuratModel>> getJenisSurat() async {
    final res = await client.get('/jenis-surat');
    final List data = res['data'] ?? res;
    return data.map((e) => JenisSuratModel.fromJson(e)).toList();
  }

  Future<List<SuratModel>> riwayat() async {
    final res = await client.get('/surat');
    return (res['data'] as List).map((e) => SuratModel.fromJson(e)).toList();
  }

  Future<SuratModel> ajukan({
    required String jenisSurat,
    required String keperluan,
    required String clientTime,
    required String dokumenPath,
  }) async {
    final res = await client.postMultipart(
      '/surat',
      fields: {
        'jenis_surat': jenisSurat,
        'keperluan': keperluan,
        'client_time': clientTime,
      },
      files: {'dokumen_pendukung': dokumenPath},
    );
    return SuratModel.fromJson(res['data']);
  }
}
