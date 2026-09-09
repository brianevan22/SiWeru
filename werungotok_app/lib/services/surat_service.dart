import '../core/api_client.dart';
import '../models/surat_model.dart';

class StatusKtpResult {
  final String ktpStatus;
  final bool bolehMengajukan;
  final String pesan;

  StatusKtpResult({
    required this.ktpStatus,
    required this.bolehMengajukan,
    required this.pesan,
  });

  factory StatusKtpResult.fromJson(Map<String, dynamic> json) {
    return StatusKtpResult(
      ktpStatus: json['ktp_status'] ?? 'unverified',
      bolehMengajukan: json['boleh_mengajukan'] ?? false,
      pesan: json['pesan'] ?? '',
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

  Future<List<SuratModel>> riwayat() async {
    final res = await client.get('/surat');
    return (res['data'] as List).map((e) => SuratModel.fromJson(e)).toList();
  }

  Future<SuratModel> ajukan({
    required String jenisSurat,
    required String dokumenPath,
  }) async {
    final res = await client.postMultipart(
      '/surat',
      fields: {'jenis_surat': jenisSurat},
      files: {'dokumen_pendukung': dokumenPath},
    );
    return SuratModel.fromJson(res['data']);
  }
}
